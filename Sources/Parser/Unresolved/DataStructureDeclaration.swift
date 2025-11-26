import Lexer

struct DataStructureDeclaration {
    var name: Located<String>
    var fields: [VariableDeclaration]
    var staticSection: StaticSection?
    var nested: [DataStructureDeclaration] = []
}

extension DataStructureDeclaration: ParseableStatement {
    static func isNext(in stream: TokenStream) -> Bool {
        return stream.peek()?.value == "data"
    }

    var asStatement: UnresolvedStatement {
        return .dataStructureDeclaration(self)
    }

    init(parsing stream: TokenStream) throws {
        _ = try stream.next().requiring { $0.value == "data" }
        let nameToken = try stream.next().requiring { $0.kind == .identifier }
        _ = try stream.next().requiring { $0.value == "{" }
        var fields: [VariableDeclaration] = []
        var staticSection: StaticSection? = nil
        var nested: [DataStructureDeclaration] = []

        while let t = stream.peek(), t.value != "}" && t.value != "static" {
            // Support inline anonymous structures in field type position
            // Look ahead: identifier ":" "{"
            let lookahead = stream.clone()
            if let nameTok = lookahead.next(), nameTok.kind == .identifier,
               lookahead.peek()?.value == ":" {
                _ = lookahead.next() // consume ':'
                if lookahead.peek()?.value == "{" {
                    // Parse an inline anonymous type
                    // Consume name and ':' from the real stream
                    let fieldNameToken = try stream.next().requiring { $0.kind == .identifier }
                    _ = try stream.next().requiring { $0.value == ":" }
                    _ = try stream.next().requiring { $0.value == "{" }

                    var innerFields: [VariableDeclaration] = []
                    while let it = stream.peek(), it.value != "}" {
                        try innerFields.append(VariableDeclaration(parsing: stream, defaultSemantics: .isolated))
                        if stream.peek()?.value == "," {
                            _ = stream.next()
                        } else if stream.peek(skippingNewlines: false)?.value == "\n" {
                            _ = stream.next(skippingNewlines: false)
                        }
                    }
                    _ = try stream.next().requiring { $0.value == "}" }

                    // Synthesize a nested type name based on the parent and field
                    let synthesizedName = "\(nameToken.value)$\(fieldNameToken.value)"

                    // Record the nested declaration to be resolved later
                    let nestedDecl = DataStructureDeclaration(
                        name: (synthesizedName, fieldNameToken.location),
                        fields: innerFields,
                        staticSection: nil
                    )
                    // Append to a temporary list; we'll assign to self later
                    nested.append(nestedDecl)

                    // Create a field variable with the synthesized type name
                    let fieldVar = VariableDeclaration(
                        name: (fieldNameToken.value, fieldNameToken.location),
                        semantics: (.isolated, fieldNameToken.location),
                        type: (synthesizedName, fieldNameToken.location),
                        initializer: nil
                    )
                    fields.append(fieldVar)

                    // Handle separators for the outer field list
                    if stream.peek()?.value == "," {
                        _ = stream.next()
                    } else if stream.peek(skippingNewlines: false)?.value == "\n" {
                        _ = stream.next(skippingNewlines: false)
                    }
                    continue
                }
            }

            // Fallback to the existing variable declaration parsing
            try fields.append(VariableDeclaration(parsing: stream, defaultSemantics: .isolated))

            if stream.peek()?.value == "," {
                _ = stream.next()
            } else if stream.peek(skippingNewlines: false)?.value == "\n" {
                _ = stream.next(skippingNewlines: false)
            }
        }

        if stream.peek()?.value == "static" {
            while let t = stream.peek(), t.value != "}" {
                _ = stream.next()
                _ = try stream.next().requiring { $0.value == ":" }

                var fields: [VariableDeclaration] = []
                var methods: [FunctionDeclaration] = []
                while let t = stream.peek(), !sectionEnders.contains(t.value)  {
                    if FunctionDeclaration.isNext(in: stream) {
                        try methods.append(FunctionDeclaration(parsing: stream))
                    } else if VariableDeclaration.isNext(in: stream) {
                        try fields.append(VariableDeclaration(parsing: stream))
                    } else {
                        throw ParserError.invalidToken(t)
                    }
                }
                staticSection = StaticSection(fields: fields, methods: methods)
            }
        }
        _ = try stream.next().requiring { $0.value == "}" }
        self.init(name: (nameToken.value, nameToken.location), fields: fields, staticSection: staticSection)
        self.nested = nested
    }

    func resolveDataStructure(in scope: Scope) throws -> DataStructure {
        // First resolve and register any synthesized nested data structures so field types can be resolved
        for nestedDecl in nested {
            let nestedData = try nestedDecl.resolveDataStructure(in: scope)
            scope.register(type: nestedData)
        }

        let result = DataStructure(
            name: name.value,
            fields: try fields.map { try $0.resolveVariable(in: scope) },
            companion: try staticSection.map {
                try CompanionObject(
                    name: "\(name.value)_static",
                    fields: $0.fields.map { try $0.resolveVariable(in: scope) },
                    methods: $0.methods.map { try $0.resolveFunction(in: scope) },
                )
            }
        )

        if let staticSection {
            let companionObject = CompanionObject(name: "\(name.value)_static")
            companionObject.fields = try staticSection.fields.map { try $0.resolveVariable(in: scope) }
            scope.register(type: companionObject)
            scope.register(variable: Variable(name: name.value, semantics: .immutable, type: .companionObject(companionObject)))

            companionObject.methods = try staticSection.methods.map { try $0.resolveFunction(in: scope) }
            result.companion = companionObject
            scope.register(type: companionObject)
            scope.register(variable: Variable(name: name.value, semantics: .immutable, type: .companionObject(companionObject), initialValue: nil))

            companionObject.fields = try staticSection.fields.map { try $0.resolveVariable(in: scope) }
            companionObject.methods = try staticSection.methods.map { try $0.resolveFunction(in: scope) }
        }

        return result
    }
}

import Lexer

struct VariableDeclaration {
    var name: Located<String>
    var semantics: Located<Semantics>
    var type: Located<String>?
    var initializer: Located<Expression>?
}

extension VariableDeclaration {
    static func parse(stream: TokenStream) throws -> VariableDeclaration {
        let keywordToken = try stream.next().requiring { $0.kind == .keyword }
        guard let semantics = Semantics(rawValue: keywordToken.value) else { throw ParserError.invalidToken(keywordToken) }
        let nameToken = try stream.next().requiring { $0.kind == .identifier }
        let name = Located<String>(value: nameToken.value, location: nameToken.location)
        let type: Located<String>?
        if stream.peek()?.value == ":" {
            _ = try stream.next().requiring { $0.value == ":" }
            let typeToken = try stream.next().requiring { $0.kind == .builtinType }
            type = .init(value: typeToken.value, location: typeToken.location)
        } else {
            type = nil
        }
        let initializer: Located<Expression>?

        if stream.peek()?.value == "=" {
            _ = try stream.next().requiring { $0.value == "=" }
            let initializerToken = try stream.next().required()

            if initializerToken.value == "true" {
                initializer = .init(value: .boolean(true), location: initializerToken.location)
            } else if initializerToken.value == "false" {
                initializer = .init(value: .boolean(false), location: initializerToken.location)
            } else if initializerToken.value.contains(".") {
                initializer = .init(value: .real(Double(initializerToken.value)!), location: initializerToken.location)
            } else if initializerToken.value.hasPrefix("0x") {
                initializer = .init(value: .bitfield(UInt64(initializerToken.value[initializerToken.value.index(initializerToken.value.startIndex, offsetBy: 2)...], radix: 16)!), location: initializerToken.location)
            } else if initializerToken.value.hasPrefix("0b") {
                initializer = .init(value: .bitfield(UInt64(initializerToken.value[initializerToken.value.index(initializerToken.value.startIndex, offsetBy: 2)...], radix: 2)!), location: initializerToken.location)
            } else {
                initializer = .init(value: .integer(Int64(initializerToken.value)!), location: initializerToken.location)
            }
        } else {
            initializer = nil
        }

        return VariableDeclaration(
            name: name,
            semantics: .init(value: semantics, location: keywordToken.location),
            type: type,
            initializer: initializer
        )
    }
}

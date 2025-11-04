import Lexer

public func parse(_ source: String) throws -> [Statement] {
    let scope = Scope()
    let stream = TokenStream(source: source)
    let unresolveds = try parse(stream)
    return try unresolveds.map {
        try $0.resolve(in: scope)
    }
}

func parse(_ stream: TokenStream) throws -> [UnresolvedStatement] {
    let parseables: [StatementParseable.Type] = [
        PrintStatement.self,
        VariableDeclaration.self,
        DataStructureDeclaration.self,
        ObjectDeclaration.self,
        FunctionDeclaration.self,
        FunctionCall.self,
    ]

    var result: [UnresolvedStatement] = []

    while stream.peek() != nil {
        if stream.peek()?.value == "}" { break }

        guard let type = parseables.first(where: { $0.isNext(in: stream) }) else { throw ParserError.invalidToken(try stream.peek().required()) }
        let unresolved = try type.init(parsing: stream)
        result.append(unresolved.asStatement)
    }
    return result
}

public enum ParserError: Error {
    case unexpectedEOF
    case invalidToken(Token)
    case unresolvedType(FileLocation)
    case unknownVariable(String, FileLocation)
    case unknownFunction(String, FileLocation)
    case typeMismatch(declared: String, inferred: String, location: FileLocation)
}

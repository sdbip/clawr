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
            initializer = try Expression.parse(stream: stream)
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

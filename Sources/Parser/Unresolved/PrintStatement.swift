import Lexer

struct PrintStatement {
    var expression: Expression
}

extension PrintStatement {
    static func parse(stream: TokenStream) throws -> PrintStatement {
        _ = try stream.next().requiring { $0.value == "print" }
        return try PrintStatement(expression: Expression.parse(stream: stream).value)
    }
}

import Lexer

struct PrintStatement {
    var expression: UnresolvedExpression
}

extension PrintStatement: StatementParseable {
    static func isNext(in stream: TokenStream) -> Bool {
        return stream.peek()?.value == "print"
    }

    init(parsing stream: TokenStream, in scope: Scope) throws {
        _ = try stream.next().requiring { $0.value == "print" }
        try self.init(expression: UnresolvedExpression.parse(stream: stream))
    }

    func resolve(in scope: Scope) throws -> Statement {
        return try .printStatement(expression.resolve(in: scope))
    }
}

import Lexer

struct PrintStatement {
    var expression: UnresolvedExpression
}

extension PrintStatement: StatementParseable {
    static func isNext(in stream: TokenStream) -> Bool {
        return stream.peek()?.value == "print"
    }

    var asStatement: UnresolvedStatement {
        return .printStatement(expression)
    }

    init(parsing stream: TokenStream) throws {
        _ = try stream.next().requiring { $0.value == "print" }
        try self.init(expression: UnresolvedExpression.parse(stream: stream))
    }
}

import Lexer

protocol StatementParseable {
    static func isNext(in stream: TokenStream) -> Bool
    var asStatement: UnresolvedStatement { get }
    init(parsing stream: TokenStream) throws
}

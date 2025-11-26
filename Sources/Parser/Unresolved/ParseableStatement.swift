import Lexer

protocol ParseableStatement {
    static func isNext(in stream: TokenStream) -> Bool
    var asStatement: UnresolvedStatement { get }
    init(parsing stream: TokenStream) throws
}

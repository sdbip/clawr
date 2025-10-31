import Lexer

struct Located<T> {
    var value: T
    var location: FileLocation
}

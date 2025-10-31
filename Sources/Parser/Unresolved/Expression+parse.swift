import Lexer

extension Expression {
    static func parse(stream: TokenStream) throws -> Located<Expression> {
        let token = try stream.next().required()

        return try .init(value: expr(), location: token.location)

        func expr() throws -> Expression {
            switch token.value {
            case "true": .boolean(true)
            case "false": .boolean(false)
            case let v where v.allSatisfy { $0.isWholeNumber || $0 == "." } && v.contains("."): .real(Double(v)!)
            case let v where v.allSatisfy { $0.isWholeNumber }: .integer(Int64(v)!)
            case let v where v.hasPrefix("0x") && v.dropFirst(2).allSatisfy { $0.isHexDigit }: .bitfield(UInt64(v.dropFirst(2), radix: 16)!)
            case let v where v.hasPrefix("0b") && v.dropFirst(2).allSatisfy { $0 == "1" || $0 == "0" }: .bitfield(UInt64(v.dropFirst(2), radix: 2)!)
            default: throw ParserError.invalidToken(token)
            }
        }
    }
}

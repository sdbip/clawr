import Lexer

enum UnresolvedExpression {
    case boolean(Bool)
    case integer(Int64)
    case real(Double)
    case bitfield(UInt64)
    case identifier(String)
}

extension UnresolvedExpression {
    static func parse(stream: TokenStream) throws -> Located<UnresolvedExpression> {
        let token = try stream.next().required()

        return try (value: expr(), location: token.location)

        func expr() throws -> UnresolvedExpression {
            switch token.value {
            case "true": return .boolean(true)
            case "false": return .boolean(false)
            case let v where token.kind == .decimal:
                if let i = Int64(v.replacing("_", with: "")) {
                    return .integer(i)
                } else if let r = Double(v.replacing("_", with: "")) {
                    return .real(r)
                }
                throw ParserError.invalidToken(token)

            case let v where token.kind == .binary:
                if v.hasPrefix("0x"), let b = UInt64(v.dropFirst(2).replacing("_", with: ""), radix: 16) {
                    return .bitfield(b)
                } else if v.hasPrefix("0b"), let b = UInt64(v.dropFirst(2).replacing("_", with: ""), radix: 2) {
                    return .bitfield(b)
                }
                throw ParserError.invalidToken(token)

            case let v where token.kind == .identifier:
                return .identifier(v)

            default:
                throw ParserError.invalidToken(token)
            }
        }
    }

    func resolve(in scope: Scope, location: FileLocation) throws -> Expression {

        switch self {
        case .boolean(let b): return .boolean(b)
        case .integer(let i): return .integer(i)
        case .real(let b): return .real(b)
        case .bitfield(let b): return .bitfield(b)
        case .identifier(let v):
            guard let variable = scope.variable(forName: v) else { throw ParserError.unknownVariable(v,  location) }
            return .identifier(v, type: variable.type)
        }
    }
}

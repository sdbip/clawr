import Lexer

struct FunctionCall {
    var target: String
    var arguments: [Located<Labeled<UnresolvedExpression>>]
}

extension FunctionCall: StatementParseable {
    static func isNext(in stream: TokenStream) -> Bool {
        return true
    }

    init(parsing stream: TokenStream, in scope: Scope) throws {
        let name = try stream.next().requiring { $0.kind == .identifier }.value
        _ = try stream.next().requiring { $0.value == "("}
        var arguments: [Located<Labeled<UnresolvedExpression>>] = []
        while stream.peek()?.value != ")" {
            let expression = try UnresolvedExpression.parse(stream: stream)
            arguments.append((.unlabeled(expression.value), location: expression.location))
            if stream.peek()?.value == "," {
                _ = stream.next()
            } else {
                break
            }
        }
        _ = try stream.next().requiring { $0.value == ")" }
        self.init(target: name, arguments: arguments)
    }

    func resolve(in scope: Scope) throws -> Statement {
        return try .functionCall(target, arguments: arguments.map {
            let value = try $0.value.value.resolve(in: scope, location: $0.location)
            switch $0.value {
            case .labeled(_, label: let label): return .labeled(value, label: label)
            case .unlabeled(_): return .unlabeled(value)
            }
        })
    }
}

import Lexer

struct FunctionCall {
    var target: Located<String>
    var arguments: [Labeled<UnresolvedExpression>]
}

extension FunctionCall: StatementParseable {
    static func isNext(in stream: TokenStream) -> Bool {
        return true
    }

    init(parsing stream: TokenStream, in scope: Scope) throws {
        let nameToken = try stream.next().requiring { $0.kind == .identifier }
        let name = nameToken.value
        _ = try stream.next().requiring { $0.value == "("}
        var arguments: [Labeled<UnresolvedExpression>] = []
        while stream.peek()?.value != ")" {
            let expression = try UnresolvedExpression.parse(stream: stream)
            arguments.append(.unlabeled(expression))
            if stream.peek()?.value == "," {
                _ = stream.next()
            } else {
                break
            }
        }
        _ = try stream.next().requiring { $0.value == ")" }
        self.init(target: (name, location: nameToken.location), arguments: arguments)
    }

    func resolve(in scope: Scope) throws -> Statement {
        return try .functionCall(target.value, arguments: arguments.map {
            let value = try $0.value.resolve(in: scope)
            switch $0 {
            case .labeled(_, label: let label): return .labeled(value, label: label)
            case .unlabeled(_): return .unlabeled(value)
            }
        })
    }
}

enum UnresolvedStatement {
    case variableDeclaration(VariableDeclaration)
    case functionDeclaration(Located<String>, returns: Located<String>?, parameters: [Labeled<VariableDeclaration>], body: FunctionBody)
    case functionCall(Located<String>, arguments: [Labeled<UnresolvedExpression>])
    case dataStructureDeclaration(Located<String>, fields: [VariableDeclaration])
    case printStatement(UnresolvedExpression)
    case returnStatement(UnresolvedExpression)
}

extension UnresolvedStatement {
    func resolve(in scope: Scope) throws -> Statement {
        switch self {

        case .variableDeclaration(let decl):
            return try .variableDeclaration(decl.resolveVariable(in: scope), initializer: decl.initializer?.resolve(in: scope))

        case .functionDeclaration(let name, returns: let returnType, parameters: let parameters, body: let body):
            let parameters = try parameters.map {
                return try $0.map { try $0.resolveVariable(in: scope) }
            }
            let bodyScope = Scope(parent: scope, parameters: parameters.map(\.value))
            let x = try body.resolve(in: bodyScope, declaredReturnType: returnType?.value)
            let (resolvedReturnType, body) = x
            return try .functionDeclaration(
                name.value,
                returns: resolvedReturnType,
                parameters: parameters,
                body: body
            )

        case .functionCall(let name, arguments: let arguments):
            return try .functionCall(name.value, arguments: arguments.map {
                return try $0.map { try $0.resolve(in: scope) }
            })

        case .dataStructureDeclaration(let name, fields: let fields):
            return .dataStructureDeclaration(
                name.value,
                fields: try fields.map { try $0.resolveVariable(in: scope) }
            )

        case .printStatement(let expression):
            return try .printStatement(expression.resolve(in: scope))

        case .returnStatement(let expression):
            return try .returnStatement(expression.resolve(in: scope))
        }
    }
}

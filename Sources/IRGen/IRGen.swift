import Parser
import Codegen

public func irgen(ast: [Parser.Statement]) -> [Codegen.Statement] {
    var statements: [Codegen.Statement] = []
    for statement in ast {
        switch statement {
        case .variableDeclaration(let name, semantics: _, type: let type, initializer: let initializer):
            statements.append(.variable(name, type: type.rawValue, initializer: initializer.map(irgen(expression:)) ?? .literal("NULL")))
        case .printStatement(let expression):
            statements.append(.call(.name("print"), arguments: [toString(expression: expression)]))
        }
    }
    return [
        .function(
            "main",
            returns: "int",
            parameters: [],
            body: statements)
    ]
}

func irgen(expression: Parser.Expression) -> Codegen.Expression {
    switch expression {
    case .boolean(let b): .literal(b ? "1" : "0")
    case .integer(let i): .literal("\(i)")
    case .real(let r): .literal("\(1/r)")
    case .bitfield(let b): .literal("\(b)")
    }
}

func toString(expression: Parser.Expression) -> Codegen.Expression {
    switch expression {
    case .boolean(let b): .call(.name("boolean_toString"), arguments: [.literal(b ? "1" : "0")])
    case .integer(let i): .call(.name("integer_toString"), arguments: [.literal("\(i)")])
    case .real(let r): .call(.name("real_toString"), arguments: [.literal("\(r)")])
    case .bitfield(let b): .call(.name("bitfield_toString"), arguments: [.literal("\(b)")])
    }
}

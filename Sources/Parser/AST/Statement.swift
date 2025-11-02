public enum Statement: Equatable {
    case variableDeclaration(Variable, initializer: Expression?)
    case functionDeclaration(String, returns: ResolvedType?, parameters: [Labeled<Variable>], body: [Statement])
    case functionCall(String, arguments: [Labeled<Expression>])
    case dataStructureDeclaration(String, fields: [Variable])
    case printStatement(Expression)
    case returnStatement(Expression)
}

public enum ResolvedType: Equatable {
    case builtin(BuiltinType)
    case data(DataStructure)

    public var name: String {
        switch self {
        case .builtin(let t): t.rawValue
        case .data(let d): d.name
        }
    }
}

public enum BuiltinType: String, Sendable {
    case boolean
    case integer
    case real
    case bitfield
    case string
    case regex
}

public struct Variable: Equatable {
    public var name: String
    public var semantics: Semantics
    public var type: ResolvedType

    public init(name: String, semantics: Semantics, type: ResolvedType) {
        self.name = name
        self.semantics = semantics
        self.type = type
    }
}

public struct DataStructure: Equatable {
    public var name: String
    public var fields: [Variable]

    public init(name: String, fields: [Variable]) {
        self.name = name
        self.fields = fields
    }
}

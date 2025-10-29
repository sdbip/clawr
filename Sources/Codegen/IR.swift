public enum IR {
    case data(name: String, fields: any Sequence<Field>)
    case traitDeclaration(name: String, methods: [Function])
    case traitImplementations(target: String, traits: [Trait])
}

public struct Trait {
    public var name: String
    public var methods: [String]

    public init(name: String, methods: [String]) {
        self.name = name
        self.methods = methods
    }
}

public struct Function {
    public var name: String
    public var returnType: String
    public var parameters: [Field]

    public init(name: String, returnType: String, parameters: [Field]) {
        self.name = name
        self.returnType = returnType
        self.parameters = parameters
    }
}

public struct Field {
    public var type: String
    public var name: String

    public init(type: String, name: String) {
        self.type = type
        self.name = name
    }
}

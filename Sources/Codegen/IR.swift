public enum Statement {
    case data(name: String, fields: any Sequence<Field>)
    case vtable(String, methods: [Function])
    case traitDescriptor(name: String)
    case dataType(target: String, traits: [Trait])
    case variable(String, type: String, initializer: Expression)
    case assign(Reference, value: Expression)
    case function(String, returns: String, parameters: [Field], body: [Statement])
    case call(Reference, arguments: [Expression])
    case `return`(Expression)
}

public indirect enum Expression {
    case literal(String)
    case reference(Reference)
    case call(Reference, arguments: [Expression])
    case vtable(methods: [NamedReference])
}

public indirect enum Reference {
    case cast(Reference, type: String)
    case name(String)
    case field(target: Reference, name: String, isPointer: Bool)
}

public struct NamedReference {
    public var name: String
    public var reference: Reference

    public init(name: String, reference: Reference) {
        self.name = name
        self.reference = reference
    }
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

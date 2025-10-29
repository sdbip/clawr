public enum IR {
    case data(name: String, fields: any Sequence<Field>)
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

public struct Field {
    public var type: String
    public var name: String

    public init(type: String, name: String) {
        self.type = type
        self.name = name
    }
}

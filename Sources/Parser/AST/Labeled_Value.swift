public enum Labeled<Value> {
    case unlabeled(Value)
    case labeled(Value, label: String)

    public var label: String? {
        switch self {
        case .unlabeled(_): nil
        case .labeled(_, label: let label): label
        }
    }

    public var value: Value {
        switch self {
        case .labeled(let value, label: _),
             .unlabeled(let value): value
        }
    }

    func map<T>(_ transform: (Value) throws -> T) rethrows -> Labeled<T> {
        switch self {
        case .labeled(let value, label: let label):
            return try .labeled(transform(value), label: label)
        case .unlabeled(let value):
            return try .unlabeled(transform(value))
        }
    }
}

extension Labeled: Equatable where Value: Equatable {}

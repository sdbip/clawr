public indirect enum Indirect<T: Equatable>: Equatable {
    case value(T)

    public var value: T {
        switch self {
        case .value(let v): v
        }
    }
}

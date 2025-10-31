public enum Expression: Equatable {
    case integer(Int64)
    case real(Double)
}

extension Expression {
    var type: String {
        switch self {
        case .integer(_): "integer"
        case .real(_): "real"
        }
    }
}

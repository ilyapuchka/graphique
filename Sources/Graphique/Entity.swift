public protocol GQLEntity {
    associatedtype GQLEntityKeyPaths: GQLEntityKeyPath
}

public extension GQLEntity {
    var __typename: String {
        return "\(type(of: self))"
    }
}

public struct Unit: GQLEntity {
    public struct GQLEntityKeyPaths: GQLEntityKeyPath {
        public init() {}
    }
}


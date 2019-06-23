public protocol GQLEntity {
    associatedtype GQLEntityKeyPaths: GQLEntityKeyPath
}

public extension GQLEntity {
    var __typename: String {
        return "\(type(of: self))"
    }
}


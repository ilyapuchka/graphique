public protocol GQLEntityKeyPath {
    init()
}

func keyPathLookup<T: GQLEntity, U>(_ keyPath: KeyPath<T, U>) -> String {
    let mirror = Mirror(reflecting: T.GQLEntityKeyPaths())
    let allKeyPaths = mirror.children
    if let label = allKeyPaths.first(where: { $0.value as? KeyPath<T, U> == keyPath })?.label {
        return label
    } else if keyPath == \T.__typename {
        return "__typename"
    } else {
        preconditionFailure("Key path is not defined in \(T.self).GQLEntityKeyPaths")
    }
}

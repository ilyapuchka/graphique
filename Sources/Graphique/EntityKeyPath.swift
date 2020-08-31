public protocol GQLEntityKeyPath {
    init()
}

private var lookupCache = [String: Mirror.Children]()

func keyPathLookup<T: GQLEntity, U>(_ keyPath: KeyPath<T, U>) -> String {
    let cacheKey = String(reflecting: T.self)
    let allKeyPaths = lookupCache[cacheKey, default: Mirror(reflecting: T.GQLEntityKeyPaths()).children]
    lookupCache[cacheKey] = allKeyPaths
    if let label = allKeyPaths.first(where: { $0.value as? KeyPath<T, U> == keyPath })?.label {
        return label
    } else if keyPath == \T.__typename {
        return "__typename"
    } else {
        preconditionFailure("Key path is not defined in \(T.self).GQLEntityKeyPaths")
    }
}

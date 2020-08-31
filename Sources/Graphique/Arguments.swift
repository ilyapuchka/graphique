public protocol GQLObjectQueryArgumentsRepresentable {
    var argumentValue: String { get }
}

public extension GQLObjectQueryArgumentsRepresentable {
    var argumentValue: String { "\(self)" }
}

public extension GQLObjectQueryArgumentsRepresentable where Self: RawRepresentable {
    var argumentValue: String { "\(self.rawValue)" }
}

public extension GQLObjectQueryArgumentsRepresentable where Self: GQLEntity {
    var argumentValue: String {
        let mirror = Mirror(reflecting: Self.GQLEntityKeyPaths())
        return """
        {\n\t\(mirror.children.compactMap { (child) -> String? in
            guard let key = child.label else { return nil }
            guard let keyPath = child.value as? AnyKeyPath else { return nil }
            guard let value = self[keyPath: keyPath] else { return nil }
            return "\(key): \((value as? GQLObjectQueryArgumentsRepresentable)?.argumentValue ?? value)"
        }.joined(separator: ",\n\t"))\n}
        """
    }
}

extension String: GQLObjectQueryArgumentsRepresentable {
    public var argumentValue: String { "\"\(self)\"" }
}

public struct GQLObjectQueryArguments<Root: GQLEntity>: CustomStringConvertible {
    let arguments: [String]
    
    static func +(lhs: GQLObjectQueryArguments, rhs: GQLObjectQueryArguments) -> GQLObjectQueryArguments {
        return GQLObjectQueryArguments(arguments: lhs.arguments + rhs.arguments)
    }
    
    static func empty() -> GQLObjectQueryArguments {
        return GQLObjectQueryArguments(arguments: [])
    }
    
    public var description: String {
        guard !arguments.isEmpty else { return "" }
        return "(\(arguments.joined(separator: ", ")))"
    }
}

public func ==<T: GQLEntity, U: GQLObjectQueryArgumentsRepresentable>(lhs: KeyPath<T, U>, rhs: U) -> GQLObjectQueryArguments<T> {
    return GQLObjectQueryArguments(arguments: ["\(keyPathLookup(lhs)): \(rhs.argumentValue)"])
}

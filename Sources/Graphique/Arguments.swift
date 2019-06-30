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

@_functionBuilder
public struct GQLObjectQueryArgumentsBuilder<Root: GQLEntity> {
    public static func buildBlock<F1: GQLObjectQueryArgumentsRepresentable>(_ filter1: (KeyPath<Root, F1>, F1)) -> GQLObjectQueryArguments<Root> {
        return GQLObjectQueryArguments(
            arguments: [
                "\(keyPathLookup(filter1.0)): \(filter1.1.argumentValue)",
            ]
        )
    }
    public static func buildBlock<F1: GQLObjectQueryArgumentsRepresentable, F2: GQLObjectQueryArgumentsRepresentable>(_ filter1: (KeyPath<Root, F1>, F1), _ filter2: (KeyPath<Root, F2>, F2)) -> GQLObjectQueryArguments<Root> {
        return GQLObjectQueryArguments(
            arguments: [
                "\(keyPathLookup(filter1.0)): \(filter1.1.argumentValue)",
                "\(keyPathLookup(filter2.0)): \(filter2.1.argumentValue)",
            ]
        )
    }
    public static func buildBlock<F1: GQLObjectQueryArgumentsRepresentable, F2: GQLObjectQueryArgumentsRepresentable, F3: GQLObjectQueryArgumentsRepresentable>(_ filter1: (KeyPath<Root, F1>, F1), _ filter2: (KeyPath<Root, F2>, F2), _ filter3: (KeyPath<Root, F3>, F3)) -> GQLObjectQueryArguments<Root> {
        return GQLObjectQueryArguments(
            arguments: [
                "\(keyPathLookup(filter1.0)): \(filter1.1.argumentValue)",
                "\(keyPathLookup(filter2.0)): \(filter2.1.argumentValue)",
                "\(keyPathLookup(filter3.0)): \(filter3.1.argumentValue)",
            ]
        )
    }
}

public func arguments<Root: GQLEntity>(@GQLObjectQueryArgumentsBuilder<Root> _ argumentsBlock: () -> GQLObjectQueryArguments<Root>) -> GQLObjectQueryArguments<Root> {
    return argumentsBlock()
}

// workaround for single element
public func arguments<Root: GQLEntity, F1: GQLObjectQueryArgumentsRepresentable>(_ filter1: () -> (KeyPath<Root, F1>, F1)) -> GQLObjectQueryArguments<Root> {
    let filter = filter1()
    return GQLObjectQueryArguments(
        arguments: [
            "\(keyPathLookup(filter.0)): \(filter.1.argumentValue)",
        ]
    )
}


enum GQLQueryKind {
    case query
    case mutation
}

public struct GQLQuery<Root: GQLEntity>: CustomStringConvertible {
    let kind: GQLQueryKind
    let name: String
    let queries: [GQLObjectQuery<Root>]
    
    public var description: String {
        var result = queries
            .map {
                $0.description
                    .split(separator: "\n")
                    .joined(separator: "\n\t")
            }
            .joined(separator: "\n\t")
        
        let allFragments = queries.flatMap { $0.fields.fragments }
        
        let fragments = [String: String](zip(
            allFragments.map { $0.name },
            allFragments.map { $0.description }
        ), uniquingKeysWith: { $1 })
            .sorted { $0.key > $1.key }
            .map { $0.value }
            .joined(separator: "\n\t")
        
        var name = self.name
        if !name.isEmpty {
            if let index = name.firstIndex(where: { $0 == "(" }) {
                name = String(name.prefix(upTo: index))
            }
            name += " "
        }

        result = "\(kind) \(name){\n\t\(result)\n}"
        if !fragments.isEmpty {
            result += "\n\n" + fragments
        }
        return result
    }
}

@_functionBuilder
public struct GQLQueryBuilder<T: GQLEntity> {
    public static func buildBlock(_ content: GQLObjectQuery<T>) -> GQLQuery<T> {
        return GQLQuery(kind: .query, name: "", queries: [content])
    }
    public static func buildBlock(_ content: GQLObjectQuery<T>...) -> GQLQuery<T> {
        return GQLQuery(kind: .query, name: "", queries: content)
    }
}

// workaround for function builders not using single element builder
public func query<T>(_ name: String = #function, _ queryBlock: () -> GQLObjectQuery<T>) -> GQLQuery<T> {
    return GQLQuery(kind: .query, name: name, queries: [queryBlock()])
}

public func query<T>(_ name: String = #function, @GQLQueryBuilder<T> _ queryBlock: () -> GQLQuery<T>) -> GQLQuery<T> {
    return GQLQuery(kind: .query, name: name, queries: queryBlock().queries)
}

// workaround for function builders not using single element builder
public func mutation<T>(_ name: String = #function, _ queryBlock: () -> GQLObjectQuery<T>) -> GQLQuery<T> {
    return GQLQuery(kind: .mutation, name: name, queries: [queryBlock()])
}

public func mutation<T>(_ name: String = #function, @GQLQueryBuilder<T> _ queryBlock: () -> [GQLObjectQuery<T>]) -> GQLQuery<T> {
    return GQLQuery(kind: .mutation, name: name, queries: queryBlock())
}

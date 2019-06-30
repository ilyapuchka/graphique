public struct GQLQuery<Root: GQLEntity>: CustomStringConvertible {
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
        
        let allFragments = queries
            .flatMap { $0.fields.fragments }
            .filter { !$0.isInline }
        
        let fragments = [String: String](zip(
            allFragments.map { $0.name },
            allFragments.map { $0.description }
        ), uniquingKeysWith: { $1 })
            .sorted { $0.key > $1.key }
            .map { $0.value }
            .joined(separator: "\n\t")
        
        var name = self.name
        if !name.isEmpty, let index = name.firstIndex(where: { $0 == "(" }) {
            name = String(name.prefix(upTo: index))
        }
        if !name.isEmpty {
            name += " "
        }

        result = "query \(name){\n\t\(result)\n}"
        if !fragments.isEmpty {
            result += "\n\n" + fragments
        }
        return result
    }
}

@_functionBuilder
public struct GQLQueryBuilder<T: GQLEntity> {
    public static func buildBlock(_ content: GQLObjectQuery<T>) -> GQLQuery<T> {
        return GQLQuery(name: "", queries: [content])
    }
    public static func buildBlock(_ content: GQLObjectQuery<T>...) -> GQLQuery<T> {
        return GQLQuery(name: "", queries: content)
    }
}

// workaround for function builders not using single element builder
public func query<T>(_ name: String = #function, _ queryBlock: () -> GQLObjectQuery<T>) -> GQLQuery<T> {
    return GQLQuery(name: name, queries: [queryBlock()])
}

public func query<T>(_ name: String = #function, @GQLQueryBuilder<T> _ queryBlock: () -> GQLQuery<T>) -> GQLQuery<T> {
    return GQLQuery(name: name, queries: queryBlock().queries)
}

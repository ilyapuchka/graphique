public struct GQLMutation<T: GQLInput>: CustomStringConvertible {
    let name: String
    let query: GQLMutationQuery<T>
    
    init(name: String, query: GQLMutationQuery<T>) {
        self.name = name
        self.query = query
    }
    
    public var description: String {
        var name = self.name
        if !name.isEmpty, let index = name.firstIndex(where: { $0 == "(" }) {
            name = String(name.prefix(upTo: index))
        }
        if !name.isEmpty {
            name += " "
        }
        let query = self.query.description
            .split(separator: "\n")
            .joined(separator: "\n\t")

        return "mutation \(name){\n\t\(query)\n}"
    }
}

public func mutation<T: GQLInput>(_ name: String = #function, _ queryBlock: () -> GQLMutationQuery<T>) -> GQLMutation<T> {
    return GQLMutation(name: name, query: queryBlock())
}

public struct Mutation<T: GQLInput>: ExpressibleByStringLiteral {
    let name: String
    public init(_ name: String) {
        self.name = name
    }
    public init(stringLiteral name: String) {
        self.name = name
    }
    public func callAsFunction(
        _ arguments: GQLObjectQueryArguments<T>...,
        @GQLMutationQueryBuilder<T> queryBlock: () -> GQLMutationQuery<T>
    ) -> GQLMutationQuery<T> {
        GQLMutationQuery(name: name, arguments, queryBlock)
    }

    public func callAsFunction(
        _ arguments: GQLObjectQueryArguments<T>...
    ) -> GQLMutationQuery<T> {
        GQLMutationQuery(name: name, arguments: arguments.reduce(.empty(), +), fields: .empty())
    }
}

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


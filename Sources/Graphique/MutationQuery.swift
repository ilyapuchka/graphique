public struct GQLMutationQuery<T: GQLInput>: CustomStringConvertible {
    let name: String
    let arguments: GQLObjectQueryArguments<T>
    let fields: GQLObjectQueryFields<T.Result>
    
    public init(name: String = #function, _ queryBlock: () -> GQLMutationQuery<T>) {
        let query = queryBlock()
        self.init(
            name: name,
            arguments: query.arguments,
            fields: query.fields
        )
    }
    
    init(
        name: String = "",
        arguments: GQLObjectQueryArguments<T>,
        fields: GQLObjectQueryFields<T.Result> = .empty()
    ) {
        var name = name
        if let index = name.firstIndex(where: { $0 == "(" }) {
            name = String(name.prefix(upTo: index))
        }
        self.name = name
        self.arguments = arguments
        self.fields = fields
    }
    
    public var description: String {
        var fields = self.fields.description
        if !fields.isEmpty {
            fields = fields
                .split(separator: "\n")
                .joined(separator: "\n\t")
            fields = " {\n\t\(fields)\n}"
        }
        return "\(name)\(arguments)\(fields)"
    }
}

@_functionBuilder
public struct GQLMutationQueryBuilder<T: GQLInput> {
    public static func buildBlock(_ arguments: GQLObjectQueryArguments<T>, _ fields: GQLObjectQueryFields<T.Result>) -> GQLMutationQuery<T> {
        return GQLMutationQuery(name: "", arguments: arguments, fields: fields)
    }
}

public extension GQLMutationQueryBuilder where T.Result == Unit {
    static func buildBlock<F1: GQLObjectQueryArgumentsRepresentable>(_ filter1: (KeyPath<T, F1>, F1)) -> GQLMutationQuery<T> {
        return GQLMutationQuery(
            arguments: GQLObjectQueryArguments(
                arguments: [
                    "\(keyPathLookup(filter1.0)): \(filter1.1.argumentValue)",
                ]
            )
        )
    }
    static func buildBlock<F1: GQLObjectQueryArgumentsRepresentable, F2: GQLObjectQueryArgumentsRepresentable>(_ filter1: (KeyPath<T, F1>, F1), _ filter2: (KeyPath<T, F2>, F2)) -> GQLMutationQuery<T> {
        return GQLMutationQuery(
            arguments: GQLObjectQueryArguments(
                arguments: [
                    "\(keyPathLookup(filter1.0)): \(filter1.1.argumentValue)",
                    "\(keyPathLookup(filter2.0)): \(filter2.1.argumentValue)",
                ]
            )
        )
    }
    static func buildBlock<F1: GQLObjectQueryArgumentsRepresentable, F2: GQLObjectQueryArgumentsRepresentable, F3: GQLObjectQueryArgumentsRepresentable>(_ filter1: (KeyPath<T, F1>, F1), _ filter2: (KeyPath<T, F2>, F2), _ filter3: (KeyPath<T, F3>, F3)) -> GQLMutationQuery<T> {
        return GQLMutationQuery(
            arguments: GQLObjectQueryArguments(
                arguments: [
                    "\(keyPathLookup(filter1.0)): \(filter1.1.argumentValue)",
                    "\(keyPathLookup(filter2.0)): \(filter2.1.argumentValue)",
                    "\(keyPathLookup(filter3.0)): \(filter3.1.argumentValue)",
                ]
            )
        )
    }
}

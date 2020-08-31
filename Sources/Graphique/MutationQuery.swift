public struct GQLMutationQuery<T: GQLInput>: CustomStringConvertible {
    let name: String
    let arguments: GQLObjectQueryArguments<T>
    let fields: GQLObjectQueryFields<T.Result>
    
    public init(
        name: String = #function,
        _ arguments: [GQLObjectQueryArguments<T>],
        _ queryBlock: () -> GQLMutationQuery<T>
    ) {
        let query = queryBlock()
        self.init(
            name: name,
            arguments: arguments.reduce(.empty(), +),
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

public extension GQLMutationQuery where T.Result == Graphique.Unit {
    init(name: String = #function, _ arguments: [GQLObjectQueryArguments<T>]) {
        self.init(
            name: name,
            arguments: arguments.reduce(.empty(), +),
            fields: .empty()
        )
    }
}

extension GQLMutationQuery {
    init(query: GQLObjectQuery<T.Result>) {
        self.init(
            arguments: .empty(),
            fields: query.fields
        )
    }
}

@_functionBuilder
public struct GQLMutationQueryBuilder<T: GQLInput> {
    public static func buildExpression<U>(_ kp: KeyPath<T.Result, U>) -> GQLObjectQuery<T.Result> {
        GQLObjectQuery(name: "", fields: GQLObjectQueryFields(fields: [keyPathLookup(kp)]))
    }

    public static func buildBlock(_ query: GQLObjectQuery<T.Result>) -> GQLMutationQuery<T> {
        GQLMutationQuery<T>(query: query)
    }

    public static func buildBlock(_ query: GQLObjectQuery<T.Result>...) -> GQLMutationQuery<T> {
        GQLMutationQuery(query: query.reduce(.empty(), +))
    }
}

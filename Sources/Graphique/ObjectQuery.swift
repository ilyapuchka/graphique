public struct GQLObjectQuery<Root: GQLEntity>: CustomStringConvertible {
    let name: String
    let alias: String?
    let arguments: GQLObjectQueryArguments<Root>
    let fields: GQLObjectQueryFields<Root>
    
    static func +(lhs: GQLObjectQuery, rhs: GQLObjectQuery) -> GQLObjectQuery {
        return GQLObjectQuery(
            name: lhs.name,
            arguments: lhs.arguments + rhs.arguments,
            fields: lhs.fields + rhs.fields
        )
    }
    
    static func empty() -> GQLObjectQuery {
        return GQLObjectQuery(name: "", arguments: .empty(), fields: .empty())
    }
    
    public init(name: String = #function, _ arguments: [GQLObjectQueryArguments<Root>] = [], _ queryBlock: () -> GQLObjectQuery<Root>) {
        let query = queryBlock()
        self.init(
            name: name,
            alias: query.alias,
            arguments: arguments.reduce(.empty(), +) + query.arguments,
            fields: query.fields
        )
    }

    init(name: String = #function, _ arguments: [GQLObjectQueryArguments<Root>] = [], fields: GQLObjectQueryFields<Root>) {
        self.init(
            name: name,
            alias: nil,
            arguments: arguments.reduce(.empty(), +),
            fields: fields
        )
    }

    public init<T1>(name: String = #function,  _ arguments: [GQLObjectQueryArguments<Root>] = [], _ keyPath: KeyPath<Root, T1>) {
        self.init(
            name: name,
            alias: nil,
            arguments: arguments.reduce(.empty(), +),
            fields: GQLObjectQueryFields<Root>(fields: [keyPathLookup(keyPath)])
        )
    }

    init(
        name: String = "",
        alias: String? = nil,
        arguments: GQLObjectQueryArguments<Root> = .empty(),
        fields: GQLObjectQueryFields<Root>
    ) {
        var name = name
        if let index = name.firstIndex(where: { $0 == "(" }) {
            name = String(name.prefix(upTo: index))
        }
        self.name = name
        self.alias = alias
        self.arguments = arguments
        self.fields = fields
    }
    
    public var description: String {
        let fields = self.fields.description
            .split(separator: "\n")
            .joined(separator: "\n\t")

		var result = "\(name)\(arguments.description) {\n\t\(fields)\n}"
        
        if let alias = alias {
            result = "\(alias): \(result)"
        }
        
        return result
    }
}

@_functionBuilder
public struct GQLObjectQueryBuilder<Root: GQLEntity> {
    public static func buildExpression(_ fields: GQLObjectQueryFields<Root>) -> GQLObjectQueryFields<Root> {
        fields
    }
    public static func buildExpression<T>(_ kp: KeyPath<Root, T>) -> GQLObjectQueryFields<Root> {
        GQLObjectQueryFields(fields: [keyPathLookup(kp)])
    }

    public static func buildBlock(_ fields: GQLObjectQueryFields<Root>) -> GQLObjectQuery<Root> {
        GQLObjectQuery(name: "", fields: fields)
    }
    public static func buildBlock(_ fields: GQLObjectQueryFields<Root>...) -> GQLObjectQuery<Root> {
        GQLObjectQuery(name: "", fields: fields.reduce(GQLObjectQueryFields(fields: []), +))
    }
}

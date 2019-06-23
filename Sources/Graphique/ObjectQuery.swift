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
    
    public init(name: String = #function, _ queryBlock: () -> GQLObjectQuery<Root>) {
        let query = queryBlock()
        self.init(
            name: name,
            alias: query.alias,
            arguments: query.arguments,
            fields: query.fields
        )
    }

    public init(name: String = #function, fields: GQLObjectQueryFields<Root>) {
        self.init(
            name: name,
            alias: nil,
            fields: fields
        )
    }

    public init<T1>(name: String = #function, keyPath: KeyPath<Root, T1>) {
        self.init(
            name: name,
            alias: nil,
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
    public static func buildBlock(_ rest: GQLObjectQueryFields<Root>) -> GQLObjectQuery<Root> {
        return GQLObjectQuery(name: "", fields: rest)
    }

    public static func buildBlock(_ rest: GQLObjectQueryFields<Root>...) -> GQLObjectQuery<Root> {
        return GQLObjectQuery(
            name: "",
            fields: rest.reduce(GQLObjectQueryFields(fields: []), +)
        )
    }
    public static func buildBlock<T1>(_ kp1: KeyPath<Root, T1>) -> GQLObjectQuery<Root> {
        return GQLObjectQuery(
            fields: GQLObjectQueryFields(
                fields: [
                    keyPathLookup(kp1)
                ])
        )
    }
    public static func buildBlock<T1>(_ kp1: KeyPath<Root, T1>, _ rest: GQLObjectQueryFields<Root>...) -> GQLObjectQuery<Root> {
        return GQLObjectQuery(
            name: "",
            fields: rest.reduce(GQLObjectQueryFields(
                fields: [
                    keyPathLookup(kp1)
                ]), +)
        )
    }
    public static func buildBlock<T1, T2>(_ kp1: KeyPath<Root, T1>, _ kp2: KeyPath<Root, T2>, _ rest: GQLObjectQueryFields<Root>...) -> GQLObjectQuery<Root> {
        return GQLObjectQuery(
            name: "",
            fields: rest.reduce(GQLObjectQueryFields(
                fields: [
                    keyPathLookup(kp1),
                    keyPathLookup(kp2)
                ]), +)
        )
    }
    public static func buildBlock<T1, T2, T3>(_ kp1: KeyPath<Root, T1>, _ kp2: KeyPath<Root, T2>, _ kp3: KeyPath<Root, T3>, _ rest: GQLObjectQueryFields<Root>...) -> GQLObjectQuery<Root> {
        return GQLObjectQuery(
            name: "",
            fields: rest.reduce(GQLObjectQueryFields(
                fields: [
                    keyPathLookup(kp1),
                    keyPathLookup(kp2),
                    keyPathLookup(kp3)
                ]), +)
        )
    }

    public static func buildBlock(_ arguments: GQLObjectQueryArguments<Root>, _ fields: GQLObjectQueryFields<Root>) -> GQLObjectQuery<Root> {
        return GQLObjectQuery(name: "", arguments: arguments, fields: fields)
    }
}

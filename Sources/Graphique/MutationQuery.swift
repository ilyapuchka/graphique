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
    public static func buildBlock<T1>(_ kp1: KeyPath<T.Result, T1>, _ rest: GQLObjectQuery<T.Result>...) -> GQLMutationQuery<T> {
        return GQLMutationQuery(
            query: rest.reduce(GQLObjectQuery(name: "", fields: GQLObjectQueryFields(
                fields: [
                    keyPathLookup(kp1)
            ])), +)
        )
    }
    public static func buildBlock<T1, T2>(_ kp1: KeyPath<T.Result, T1>, _ kp2: KeyPath<T.Result, T2>, _ rest: GQLObjectQuery<T.Result>...) -> GQLMutationQuery<T> {
        return GQLMutationQuery(
            query: rest.reduce(GQLObjectQuery(name: "", fields: GQLObjectQueryFields(
                fields: [
                    keyPathLookup(kp1),
                    keyPathLookup(kp2)
            ])), +)
        )
    }
    public static func buildBlock<T1, T2, T3>(_ kp1: KeyPath<T.Result, T1>, _ kp2: KeyPath<T.Result, T2>, _ kp3: KeyPath<T.Result, T3>, _ rest: GQLObjectQuery<T.Result>...) -> GQLMutationQuery<T> {
        return GQLMutationQuery(
            query: rest.reduce(GQLObjectQuery(name: "", fields: GQLObjectQueryFields(
                fields: [
                    keyPathLookup(kp1),
                    keyPathLookup(kp2),
                    keyPathLookup(kp3)
            ])), +)
        )
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

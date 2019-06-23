public struct GQLObjectQueryFields<Root: GQLEntity>: CustomStringConvertible {
    let fields: [String]
    let lenses: [GQLObjectQueryLens<Root>]
    let fragments: [GQLObjectQueryFragment<Root>]
    
    init(
        fields: [String],
        lenses: [GQLObjectQueryLens<Root>] = [],
        fragments: [GQLObjectQueryFragment<Root>] = []
    ) {
        self.fields = fields
        self.lenses = lenses
        self.fragments = fragments
    }
    
    static func +(lhs: GQLObjectQueryFields, rhs: GQLObjectQueryFields) -> GQLObjectQueryFields {
        return GQLObjectQueryFields(
            fields: lhs.fields + rhs.fields,
            lenses: lhs.lenses + rhs.lenses,
            fragments: lhs.fragments + rhs.fragments
        )
    }
    
    static func empty() -> GQLObjectQueryFields {
        return GQLObjectQueryFields(fields: [], lenses: [], fragments: [])
    }
    
    public var description: String {
        var result = ""
        if !fields.isEmpty {
            result += fields.joined(separator: "\n")
        }
        if !fragments.isEmpty {
            result += "\n" + fragments
                .map { "...\($0.name)" }
                .joined(separator: "\n")
        }
        if !lenses.isEmpty {
            result += "\n" + lenses
                .map { $0.description }
                .joined(separator: "\n")
        }

        return result
    }
}


@_functionBuilder
public struct GQLObjectQueryFieldsBuilder<Root: GQLEntity> {
    public static func buildBlock(_ rest: GQLObjectQueryFields<Root>...) -> GQLObjectQueryFields<Root> {
        return rest.reduce(GQLObjectQueryFields(fields: []), +)
    }
    public static func buildBlock<T1>(_ kp1: KeyPath<Root, T1>, _ rest: GQLObjectQueryFields<Root>...) -> GQLObjectQueryFields<Root> {
        return rest.reduce(GQLObjectQueryFields(
            fields: [
                keyPathLookup(kp1)
            ]), +)
    }
    public static func buildBlock<T1, T2>(_ kp1: KeyPath<Root, T1>, _ kp2: KeyPath<Root, T2>, _ rest: GQLObjectQueryFields<Root>...) -> GQLObjectQueryFields<Root> {
        return rest.reduce(GQLObjectQueryFields(
            fields: [
                keyPathLookup(kp1),
                keyPathLookup(kp2)
            ]), +)
    }
    public static func buildBlock<T1, T2, T3>(_ kp1: KeyPath<Root, T1>, _ kp2: KeyPath<Root, T2>, _ kp3: KeyPath<Root, T3>, _ rest: GQLObjectQueryFields<Root>...) -> GQLObjectQueryFields<Root> {
        return rest.reduce(GQLObjectQueryFields(
            fields: [
                keyPathLookup(kp1),
                keyPathLookup(kp2),
                keyPathLookup(kp3)
            ]), +)
    }
}

public func fields<Root: GQLEntity>(@GQLObjectQueryFieldsBuilder<Root> _ fieldsBlock: () -> GQLObjectQueryFields<Root>) -> GQLObjectQueryFields<Root> {
    return fieldsBlock()
}

// workaround for single argument
public func fields<Root: GQLEntity, T1>(_ kp1: () -> KeyPath<Root, T1>) -> GQLObjectQueryFields<Root> {
    return GQLObjectQueryFields(
        fields: [
            keyPathLookup(kp1())
        ])
}

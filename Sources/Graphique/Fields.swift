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
                .map {
                    var result = "...\($0.name)"
                    if $0.isInline {
                        result += " " + $0.description
                    }
                    return result
                }
                .joined(separator: "\n")
        }
        if !lenses.isEmpty {
            result += "\n" + lenses
                .map { $0.description }
                .joined(separator: "\n")
        }

        return result
    }
    
    func map<T>(to type: T.Type = T.self) -> GQLObjectQueryFields<T> {
        return GQLObjectQueryFields<T>(
            fields: fields,
            lenses: lenses.map { $0.map() },
            fragments: fragments.map { $0.map() }
        )
    }
}


@_functionBuilder
public struct GQLObjectQueryFieldsBuilder<Root: GQLEntity> {
    public static func buildExpression(_ fields: GQLObjectQueryFields<Root>) -> GQLObjectQueryFields<Root> {
        fields
    }
    public static func buildExpression<T>(_ kp: KeyPath<Root, T>) -> GQLObjectQueryFields<Root> {
        GQLObjectQueryFields(fields: [keyPathLookup(kp)])
    }
    public static func buildBlock(_ fields: GQLObjectQueryFields<Root>) -> GQLObjectQueryFields<Root> {
        fields
    }
    public static func buildBlock(_ fields: GQLObjectQueryFields<Root>...) -> GQLObjectQueryFields<Root> {
        fields.reduce(GQLObjectQueryFields(fields: []), +)
    }
}

public func fields<Root: GQLEntity>(@GQLObjectQueryFieldsBuilder<Root> _ fieldsBlock: () -> GQLObjectQueryFields<Root>) -> GQLObjectQueryFields<Root> {
    return fieldsBlock()
}

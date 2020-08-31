public struct GQLObjectQueryLens<Root: GQLEntity>: CustomStringConvertible {
    let field: String
    // TODO: lens should process other lenses and fragments
    // so this property should be probably compiled query
    // or somehow should erase lensed types,
    // so it should be possible to have `fields: [AnyGQLObjectQueryFields]`
    let fields: CustomStringConvertible
    
    public var description: String {
        return "\(field)\(fields)"
    }
    
    func map<T>(to type: T.Type = T.self) -> GQLObjectQueryLens<T> {
        return GQLObjectQueryLens<T>(
            field: field,
            fields: fields
        )
    }
}

public func lens<Root: GQLEntity, T: GQLEntity>(
    _ keyPath: KeyPath<Root, T>,
    _ arguments: GQLObjectQueryArguments<T>...,
    @GQLObjectQueryBuilder<T> query: () -> GQLObjectQuery<T>
) -> GQLObjectQuery<Root> {
    return GQLObjectQuery(name: "", fields: GQLObjectQueryFields<Root>(
        fields: [],
        lenses: [
            GQLObjectQueryLens<Root>(
                field: keyPathLookup(keyPath),
                fields: GQLObjectQuery(name: "", arguments, query)
            )
        ]
    ))
}

public func lens<Root: GQLEntity, T: GQLEntity>(
    _ keyPath: KeyPath<Root, T>,
    _ arguments: GQLObjectQueryArguments<T>...,
    @GQLObjectQueryBuilder<T> query: () -> GQLObjectQuery<T>
) -> GQLObjectQueryFields<Root> {
    return GQLObjectQueryFields<Root>(
        fields: [],
        lenses: [
            GQLObjectQueryLens<Root>(
                field: keyPathLookup(keyPath),
                fields: GQLObjectQuery(name: "", arguments, query)
            )
        ]
    )
}

public func lens<Root: GQLEntity, T: Collection>(
    _ keyPath: KeyPath<Root, T>,
    _ arguments: GQLObjectQueryArguments<T.Element>...,
    @GQLObjectQueryBuilder<T.Element> query: () -> GQLObjectQuery<T.Element>
) -> GQLObjectQuery<Root> where T.Element: GQLEntity {
    return GQLObjectQuery(name: "", fields: GQLObjectQueryFields<Root>(
        fields: [],
        lenses: [
            GQLObjectQueryLens<Root>(
                field: keyPathLookup(keyPath),
                fields: GQLObjectQuery(name: "", arguments, query)
            )
        ]
    ))
}

public func lens<Root: GQLEntity, T: Collection>(
    _ keyPath: KeyPath<Root, T>,
    _ arguments: GQLObjectQueryArguments<T.Element>...,
    @GQLObjectQueryBuilder<T.Element> query: () -> GQLObjectQuery<T.Element>
) -> GQLObjectQueryFields<Root> where T.Element: GQLEntity {
    return GQLObjectQueryFields<Root>(
        fields: [],
        lenses: [
            GQLObjectQueryLens<Root>(
                field: keyPathLookup(keyPath),
                fields: GQLObjectQuery(name: "", arguments, query)
            )
        ]
    )
}

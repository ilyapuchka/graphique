public struct GQLObjectQueryLens<Root: GQLEntity>: CustomStringConvertible {
    let field: String
    // TODO: lens should process other lenses and fragments
    // so this property should be probably compiled query
    // or somehow should erase lensed types,
    // so it should be possible to have `fields: [AnyGQLObjectQueryFields]`
    //let fields: [String]
    let fields: CustomStringConvertible
    
    public var description: String {
        if fields is GQLObjectQuery<Root> {
            return "\(field)\(fields)"
        } else {
            let fields = self.fields.description
                .split(separator: "\n")
                .joined(separator: "\n\t")
            
            return "\(field) {\n\t\(fields)\n}"
        }
    }
}

public func lens<Root: GQLEntity, T: GQLEntity>(_ keyPath: KeyPath<Root, T>, @GQLObjectQueryBuilder<T> _ query: () -> GQLObjectQuery<T>) -> GQLObjectQueryFields<Root> {
    return GQLObjectQueryFields<Root>(
        fields: [],
        lenses: [
            GQLObjectQueryLens<Root>(
                field: keyPathLookup(keyPath),
                fields: query()
            )
        ]
    )
}

public func lens<Root: GQLEntity, T: Collection>(_ keyPath: KeyPath<Root, T>, @GQLObjectQueryBuilder<T.Element> _ query: () -> GQLObjectQuery<T.Element>) -> GQLObjectQueryFields<Root> where T.Element: GQLEntity {
    return GQLObjectQueryFields<Root>(
        fields: [],
        lenses: [
            GQLObjectQueryLens<Root>(
                field: keyPathLookup(keyPath),
                fields: query()
            )
        ]
    )
}

// workaround for single element
public func lens<Root: GQLEntity, T: Collection, U>(_ keyPath: KeyPath<Root, T>,  _ kp1: () -> KeyPath<T.Element, U>) -> GQLObjectQueryFields<Root> where T.Element: GQLEntity {
    return GQLObjectQueryFields<Root>(
        fields: [],
        lenses: [
            GQLObjectQueryLens<Root>(
                field: keyPathLookup(keyPath),
                fields: GQLObjectQueryFields<T.Element>(
                    fields: [keyPathLookup(kp1())]
                )
            )
        ]
    )
}

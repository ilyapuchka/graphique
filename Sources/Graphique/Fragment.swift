public struct GQLObjectQueryFragment<Root: GQLEntity>: CustomStringConvertible {
    let name: String
    let fields: GQLObjectQueryFields<Root>
    
    var isInline: Bool {
        return name.hasPrefix(" on ")
    }
    
    public var description: String {
        let fields = self.fields.description
            .split(separator: "\n")
            .joined(separator: "\n\t")

        if isInline {
            return "{\n\t\(fields)\n}"
        } else {
            return "fragment \(name) on \(Root.self) {\n\t\(fields)\n}"
        }
    }
    
    func map<T>(to type: T.Type = T.self) -> GQLObjectQueryFragment<T> {
        return GQLObjectQueryFragment<T>(
            name: name,
            fields: fields.map()
        )
    }
}

public func fragment<T>(_ name: String = #function, @GQLObjectQueryFieldsBuilder<T> _ queryBlock: () -> GQLObjectQueryFields<T>) -> GQLObjectQueryFragment<T> {
    return GQLObjectQueryFragment<T>(name: name, fields: queryBlock())
}

public func fragment<T>(_ name: String, on: T.Type, @GQLObjectQueryFieldsBuilder<T> _ queryBlock: () -> GQLObjectQueryFields<T>) -> GQLObjectQueryFragment<T> {
    return GQLObjectQueryFragment<T>(name: name, fields: queryBlock())
}

prefix operator ...
public prefix func ...<T>(_ value: GQLObjectQueryFragment<T>) -> GQLObjectQuery<T> {
    return GQLObjectQuery(fields: GQLObjectQueryFields(fields: [], fragments: [value]))
}

/// Does not enforce `SubType: T` as it's not expressible with Swift generics
public func on<T: GQLEntity, U: GQLEntity>(_ type: U.Type, @GQLObjectQueryFieldsBuilder<U> _ query: () -> GQLObjectQueryFields<U>) -> GQLObjectQueryFragment<T> {
    return GQLObjectQueryFragment<T>(
        name: " on \(U.self)",
        fields: query().map()
    )
}

// workaround for single argument
public func on<T: GQLEntity, U: GQLEntity, V>(_ type: U.Type, _ kp1: () -> KeyPath<U, V>) -> GQLObjectQueryFragment<T> {
    return GQLObjectQueryFragment<T>(
        name: " on \(U.self)",
        fields: fields(kp1).map()
    )
}


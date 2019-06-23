public struct GQLObjectQueryFragment<Root: GQLEntity>: CustomStringConvertible {
    let name: String
    let fields: GQLObjectQueryFields<Root>
    
    public var description: String {
        let fields = self.fields.description
            .split(separator: "\n")
            .joined(separator: "\n\t")
        
        return "fragment \(name) on \(Root.self) {\n\t\(fields)\n}"
    }
}

public func fragment<T>(_ name: String = #function, @GQLObjectQueryFieldsBuilder<T> _ queryBlock: () -> GQLObjectQueryFields<T>) -> GQLObjectQueryFragment<T> {
    return GQLObjectQueryFragment<T>(name: name, fields: queryBlock())
}

public func fragment<T>(_ name: String, on: T.Type, @GQLObjectQueryFieldsBuilder<T> _ queryBlock: () -> GQLObjectQueryFields<T>) -> GQLObjectQueryFragment<T> {
    return GQLObjectQueryFragment<T>(name: name, fields: queryBlock())
}

prefix operator ...
public prefix func ...<T>(_ value: GQLObjectQueryFragment<T>) -> GQLObjectQueryFields<T> {
    return GQLObjectQueryFields(fields: [], fragments: [value])
}

public prefix func ...<T>(on: (T.Type, query: GQLObjectQueryFields<T>)) -> GQLObjectQueryFields<T> {
    return on.query
}


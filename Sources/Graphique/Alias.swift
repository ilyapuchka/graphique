public func alias<T>(_ alias: String, _ query: GQLObjectQuery<T>) -> GQLObjectQuery<T> {
    return GQLObjectQuery(name: query.name, alias: alias, arguments: query.arguments, fields: query.fields)
}

public func == <T>(lhs: String, rhs: GQLObjectQuery<T>) -> GQLObjectQuery<T> {
    return alias(lhs, rhs)
}

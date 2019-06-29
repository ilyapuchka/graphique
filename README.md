# graphique

This library attempts to implement GraphQL query DSL using Swift 5.1 function builders.

To start you define your models as regular Swift types:

```swift
import Graphique

struct Hero {
  let id: String
  let name: String
  let episode: Episode
  let friends: [Hero]
}

enum Episode: String {
  case newHope = "NEWHOPE"
  case empire = "EMPIRE"
  case jedi = "JEDI"
}
```

To use these models with `Graphique` you need to:

- Implement `GQLEntity` protocol on the models you want to query by defining a mapping for your entity key paths 

```swift
extension Hero: GQLEntity {
  struct GQLEntityKeyPaths: GQLEntityKeyPath {
    let id              = \Hero.id
    let name            = \Hero.name
    let episode         = \Hero.episode
    let friends         = \Hero.friends
  }
}
```

`GQLEntityKeyPaths` type will be used to convert key paths you use in a query to strings using `Mirror`. I.e. here `\Hero.id` will be converted to `"id"`, `\Hero.name` will be converted to `"name"`. This is needed because Swift does not provide any introspection on `KeyPath` type.

- Conform types you want to use as query arguments to `GQLObjectQueryArgumentsRepresentable`

```swift
extension Episode: GQLObjectQueryArgumentsRepresentable {}
```

This conformance is used to convert argument values you use in a query to strings (default implementation is provided by the library so there is no need for you to add any implementation details).

- Define your "root" query function

```swift
func hero(@GQLObjectQueryBuilder<Hero> _ queryBlock: () -> GQLObjectQuery<Hero>) -> GQLObjectQuery<Hero> {
  return GQLObjectQuery(queryBlock)
}
```

You will use this function in a query to specify the actualy type of a query you want to perform. All your root query functions will look identical. I.e. if you want to query all episodes you will add the following function:

```swift
func episode(@GQLObjectQueryBuilder<Episode> _ queryBlock: () -> GQLObjectQuery<Episode>) -> GQLObjectQuery<Episode> {
  return GQLObjectQuery(queryBlock)
}
```

With that you can start building your queries.

### Basic query

```graphql
// GraphQL

query {
  hero {
    name
    friends {
      name
    }
  }
}

// Swift

query("") {
  hero {
    \.name
    lens(\.friends) {
      \.name
    }
  }
}
```

### Arguments

```graphql
// GraphQL

query {
  hero(episode: JEDI) {
    name
  }
}

// Swift

query("") {
  hero {
    arguments {
      (\.episode, .jedi)
    }
    fields {
      \.name
    }
  }
}
```

### Aliases

```graphql
// GraphQL

query {
  empireHero: hero(episode: EMPIRE) {
    id
    name
  }
  jediHero: hero(episode: JEDI) {
    id
    name
  }
}

// Swift

query("") {
  "empireHero" == hero {
    arguments {
      (\.episode, .empire)
    }
    fields {
      \.id
      \.name
    }
  }
  "jediHero" == hero {
    arguments {
      (\.episode, .jedi)
    }
    fields {
      \.id
      \.name
    }
  }
}
```

### Fragments

```graphql
// GraphQL

query {
  leftComparison: hero(episode: EMPIRE) {
    ...comparisonFields
  }
  rightComparison: hero(episode: JEDI) {
    ...comparisonFields
  }
}

fragment comparisonFields on Hero {
  id
  name
  friends {
    id
    name
  }
}

// Swift

let comparisonFields = fragment("comparisonFields", on: Hero.self) {
  \.id
  \.name

  lens(\.friends) {
    \.id
    \.name
  }
}

// or

var comparisonFields: GQLObjectQueryFragment<Hero> {
  fragment {
    \.id
    \.name

    lens(\.friends) {
      \.id
      \.name
    }
  }
}

query("") {
  "leftComparison" == hero {
    arguments {
      (\.episode, .empire)
    }
    ...comparisonFields
  }
  "rightComparison" == hero {
    arguments {
      (\.episode, .jedi)
    }
    fields {
      ...comparisonFields
    }
  }
}
```

#### Using variables inside fragments

TBD

### Operation name

```graphql
// GraphQL

query HeroQuery {
  hero(episode: JEDI) {
    id
    name
  }
}

// Swift

query("HeroQuery") {
  hero {
    arguments {
      (\.episode, .jedi)
    }
    fields {
      \.id
      \.name
    }
  }
}

// or

func HeroQuery() -> GQLQuery<Hero> {
  query {
    hero {
      arguments {
        (\.episode, .jedi)
      }
      fields {
        \.id
        \.name
      }
    }
  }
}
```

In the last example the query will get the name of the function where it is defined.

### Variables

```graphql
// GraphQL

query HeroQuery($episode: Episode = JEDI) {
  hero(episode: $episode) {
    name
  }
}

// Swift

func HeroQuery(episode: Episode = .jedi) -> GQLQuery<Hero> {
  query {
    hero {
      arguments {
        (\.episode, episode)
      }
      fields {
        \.name
      }
    }
  }
}
```

Note that the resulting query will have its parameters replaced with actuall values you pass to the query function, so if you call `let query = HeroQuery()` it will create a query

```graphql
query HeroQuery {
  hero(episode: jedi) {
    name
  }
}
```

### Directives

TBD

### Mutations

TBD

### Inline Fragments 

```graphql
// GraphQL

query {
  hero {
    name
    ... on Droid {
      primaryFunction
    }
    ... on Human {
      height
    }
  }
}

// Swift

query("") {
  hero {
    \.name
    ...on(Droid.self) {
      \.primaryFunction
    }
    ...on(Human.self) {
      \.height
    }
  }
}
```

### Meta fields

```graphql
// GrahpQL

query {
  hero {
    __typename
    name
  }
}

// Swift

query {
  hero {
    \.__typename
    \.name
  }
}
```

### Limitations

- as of Xcode 11 beta 1 functional builders do not properly work with single element (FB6159639), for that reason you have to add this overload for your root query functions:

```swift
func hero<T>(_ queryBlock: () -> KeyPath<Hero, T>) -> GQLObjectQuery<Hero> {
  return GQLObjectQuery(keyPath: queryBlock())
}
```

- inline fragments do not enforce types to be related, e.g. `Droid` and `Human` to be subtypes of `Hero`.
- to use inline fragments you'll need to use classes for models, not structs



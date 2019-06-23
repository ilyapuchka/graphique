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

extension Hero: GQLEntity {
    struct GQLEntityKeyPaths: GQLEntityKeyPath {
        let id              = \Hero.id
        let name            = \Hero.name
        let episode         = \Hero.episode
        let friends         = \Hero.friends
    }
}

extension Episode: GQLObjectQueryArgumentsRepresentable {}

func hero(@GQLObjectQueryBuilder<Hero> _ queryBlock: () -> GQLObjectQuery<Hero>) -> GQLObjectQuery<Hero> {
    return GQLObjectQuery(queryBlock)
}

// workaround for single argument
func hero<T1>(_ queryBlock: () -> KeyPath<Hero, T1>) -> GQLObjectQuery<Hero> {
    return GQLObjectQuery(keyPath: queryBlock())
}


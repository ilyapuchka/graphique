import Graphique

class Hero {
    let id: String = ""
    let name: String = ""
    let episode: Episode = .empire
    let friends: [Hero] = []
}

class Droid: Hero {
    let primaryFunction: String = ""
}

class Human: Hero {
    let height: Int = 0
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

        let primaryFunction = \Droid.primaryFunction
        let height          = \Human.height
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


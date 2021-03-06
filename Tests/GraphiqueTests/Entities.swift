import Graphique

let hero: Query<Hero> = "hero"

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

struct Review {
    let commentary: String
    let stars: Int
}

let createReview: Mutation<CreateReview<Review>> = "createReview"

struct CreateReview<T: GQLEntity> {
    let episode: Episode
    let review: Review
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

extension Review: GQLEntity {
    struct GQLEntityKeyPaths: GQLEntityKeyPath {
        let commentary  = \Review.commentary
        let stars       = \Review.stars
    }
}

extension Review: GQLObjectQueryArgumentsRepresentable {}

extension CreateReview: GQLInput {
    typealias Result = T

    struct GQLEntityKeyPaths: GQLEntityKeyPath {
        let episode = \CreateReview.episode
        let review  = \CreateReview.review
    }
}

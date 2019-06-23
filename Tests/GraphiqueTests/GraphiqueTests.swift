import XCTest
import Graphique

final class GraphiqueTests: XCTestCase {
    
    func testFields() {
        let heroQuery = query("") {
            hero {
				\.name
            }
        }
		
		XCTAssertEqual(
			heroQuery.description,
			"""
			query {
				hero {
					name
				}
			}
			"""
		)
    }
	
	func testMultipleFields() {
		let heroQuery = query("") {
			hero {
				\.name
				lens(\.friends) {
					\.name
				}
			}
		}
		
		XCTAssertEqual(
			heroQuery.description,
			"""
			query {
				hero {
					name
					friends {
						name
					}
				}
			}
			"""
		)
	}

	func testArguments() {
		let heroQuery = query("") {
			hero {
				arguments {
					(\.episode, .jedi)
				}
				fields {
					\.name
				}
			}
		}
		
		XCTAssertEqual(
			heroQuery.description,
			"""
			query {
				hero(episode: JEDI) {
					name
				}
			}
			"""
		)
	}
	
	func testMultipleArguments() {
		let heroQuery = query("") {
			hero {
				arguments {
					(\.id, "1000")
					(\.episode, .jedi)
				}
				fields {
					\.id
					\.name
				}
			}
		}
		
		XCTAssertEqual(
			heroQuery.description,
			"""
			query {
				hero(id: "1000", episode: JEDI) {
					id
					name
				}
			}
			"""
		)
	}
	
	func testAliases() {
		let heroQuery = query("") {
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
		
		XCTAssertEqual(
			heroQuery.description,
			"""
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
			"""
		)
	}
	
	func testFragments() {
		let comparisonFields = fragment("comparisonFields", on: Hero.self) {
			\.id
			\.name
			
			lens(\.friends) {
				\.id
				\.name
			}
		}

		let heroQuery = query("") {
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
		
		XCTAssertEqual(
			heroQuery.description,
			"""
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
			"""
		)
	}
	
	func testFragmentsAsComputedProperty() {
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
		
		let heroQuery = query("") {
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
		
		XCTAssertEqual(
			heroQuery.description,
			"""
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
			"""
		)
	}
	
	func testNamedQuery() {
		let heroQuery = query("HeroQuery") {
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
		
		XCTAssertEqual(
			heroQuery.description,
			"""
			query HeroQuery {
				hero(episode: JEDI) {
					id
					name
				}
			}
			"""
		)
	}
	
	func testNamedQueryInFunction() {
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
		
		XCTAssertEqual(
			HeroQuery().description,
			"""
			query HeroQuery {
				hero(episode: JEDI) {
					id
					name
				}
			}
			"""
		)
	}
	
	func testVariables() {
		// TBD
	}
	
	func testFragmentVariables() {
		// TBD
	}
	
	func testDirectives() {
		// TBD
	}
	
	func testMutation() {
		// TBD
	}
	
	func testInlineFragments() {
		// TBD
	}
	
	func testMetaFields() {
		// TBD
	}
    
}

import XCTest

@testable import ScrapCore

final class ScpSubstitutionFinderTests: XCTestCase {
    private typealias Fx = ScpTestFixtures

    func test_substitutions_listsReplacementsForKnownIngredient() {
        let result = ScpSubstitutionFinder().substitutions(for: Fx.ingredient("Butter"), in: ScpKitchen())

        XCTAssertFalse(result.isEmpty)
        XCTAssertTrue(result.allSatisfy { $0.original.id == "butter" })
    }

    func test_substitutions_whenIngredientIsUnknown_returnsEmpty() {
        let result = ScpSubstitutionFinder().substitutions(for: Fx.ingredient("Dragonfruit"), in: ScpKitchen())

        XCTAssertTrue(result.isEmpty)
    }

    func test_substitutions_putsReplacementsAlreadyInKitchenFirst() {
        let kitchen = Fx.kitchen("margarine")

        let result = ScpSubstitutionFinder().substitutions(for: Fx.ingredient("butter"), in: kitchen)

        XCTAssertEqual(result.first?.replacement.id, "margarine")
        XCTAssertEqual(result.first?.isInKitchen, true)
        XCTAssertEqual(result.last?.isInKitchen, false)
    }
}

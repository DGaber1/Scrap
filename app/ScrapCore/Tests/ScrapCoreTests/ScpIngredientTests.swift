import XCTest

@testable import ScrapCore

final class ScpIngredientTests: XCTestCase {
    func test_normalizedID_lowercasesAndCollapsesWhitespace() {
        XCTAssertEqual(ScpIngredient.normalizedID(for: "  Chicken   BREAST "), "chicken breast")
    }

    func test_initWithName_derivesIDFromName() {
        XCTAssertEqual(ScpIngredient(name: "Egg").id, "egg")
    }

    func test_spoonacularUnit_mapsCommonSpellings() {
        XCTAssertEqual(ScpMeasurementUnit(spoonacularUnit: "Tbsp"), .tablespoon)
        XCTAssertEqual(ScpMeasurementUnit(spoonacularUnit: "cups"), .cup)
        XCTAssertEqual(ScpMeasurementUnit(spoonacularUnit: "ounces"), .ounce)
    }

    func test_spoonacularUnit_whenUnrecognizedOrMissing_fallsBackToPiece() {
        XCTAssertEqual(ScpMeasurementUnit(spoonacularUnit: "bunch"), .piece)
        XCTAssertEqual(ScpMeasurementUnit(spoonacularUnit: nil), .piece)
        XCTAssertEqual(ScpMeasurementUnit(spoonacularUnit: ""), .piece)
    }

    func test_isNearingExpiration_whenExpiringTomorrow_returnsTrue() {
        let now = Date()
        let item = ScpPantryItem(
            ingredient: ScpIngredient(name: "Milk"),
            location: .fridge,
            expirationDate: now.addingTimeInterval(24 * 60 * 60)
        )

        XCTAssertTrue(item.isNearingExpiration(asOf: now))
    }

    func test_isNearingExpiration_whenNoDate_returnsFalse() {
        XCTAssertFalse(ScpPantryItem(ingredient: ScpIngredient(name: "Rice")).isNearingExpiration())
    }
}

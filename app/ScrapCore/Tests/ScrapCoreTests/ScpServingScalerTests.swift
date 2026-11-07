import XCTest

@testable import ScrapCore

final class ScpServingScalerTests: XCTestCase {
    private func recipe() -> ScpRecipe {
        ScpRecipe(
            id: "r1",
            title: "Test",
            ingredients: [
                ScpRecipeIngredient(ingredient: ScpIngredient(name: "Flour"), quantity: ScpQuantity(amount: 2, unit: .cup))
            ],
            instructions: [],
            prepTimeMinutes: 5,
            cookTimeMinutes: 5,
            difficulty: .easy,
            servings: 2
        )
    }

    func test_scale_whenDoublingServings_doublesQuantities() throws {
        let scaled = try ScpServingScaler.scale(recipe(), toServings: 4)

        XCTAssertEqual(scaled.servings, 4)
        XCTAssertEqual(scaled.ingredients.first?.quantity.amount, 4)
    }

    func test_scale_whenHalvingServings_halvesQuantities() throws {
        let scaled = try ScpServingScaler.scale(recipe(), toServings: 1)

        XCTAssertEqual(scaled.ingredients.first?.quantity.amount, 1)
    }

    func test_scale_whenServingsAreUnchanged_returnsSameQuantities() throws {
        let scaled = try ScpServingScaler.scale(recipe(), toServings: 2)

        XCTAssertEqual(scaled, recipe())
    }

    func test_scale_whenServingsAreZero_throwsInvalidInput() {
        XCTAssertThrowsError(try ScpServingScaler.scale(recipe(), toServings: 0)) { error in
            XCTAssertEqual(error as? ScpError, .invalidInput)
        }
    }

    func test_scale_whenServingsAreNegative_throwsInvalidInput() {
        XCTAssertThrowsError(try ScpServingScaler.scale(recipe(), toServings: -2)) { error in
            XCTAssertEqual(error as? ScpError, .invalidInput)
        }
    }

    func test_scale_whenRecipeHasZeroServings_throwsInvalidInput() {
        var broken = recipe()
        broken.servings = 0

        XCTAssertThrowsError(try ScpServingScaler.scale(broken, toServings: 2)) { error in
            XCTAssertEqual(error as? ScpError, .invalidInput)
        }
    }
}

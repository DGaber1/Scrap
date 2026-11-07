import XCTest

@testable import ScrapCore

final class ScpRecipeMatcherTests: XCTestCase {
    private typealias Fx = ScpTestFixtures
    private let matcher = ScpRecipeMatcher()

    func test_rank_whenOneRecipeIsFullyCovered_ranksItFirst() {
        let full = Fx.recipe(id: "full", ingredients: ["egg", "flour"])
        let partial = Fx.recipe(id: "partial", ingredients: ["egg", "milk"])

        let ranked = matcher.rank(recipes: [partial, full], kitchen: Fx.kitchen("egg", "flour"))

        XCTAssertEqual(ranked.map(\.recipe.id), ["full", "partial"])
        XCTAssertEqual(ranked.first?.matchPercent, 1.0)
        XCTAssertEqual(ranked.last?.matchPercent, 0.5)
    }

    func test_rank_reportsMissingIngredients() {
        let recipe = Fx.recipe(ingredients: ["egg", "milk", "flour"])

        let ranked = matcher.rank(recipes: [recipe], kitchen: Fx.kitchen("egg"))

        XCTAssertEqual(ranked.first?.missingIngredients.map(\.ingredient.id).sorted(), ["flour", "milk"])
    }

    func test_rank_whenKitchenIsEmpty_returnsZeroMatchForAll() {
        let recipes = [Fx.recipe(id: "a", ingredients: ["egg"]), Fx.recipe(id: "b", ingredients: ["milk"])]

        let ranked = matcher.rank(recipes: recipes, kitchen: ScpKitchen())

        XCTAssertEqual(ranked.count, 2)
        XCTAssertTrue(ranked.allSatisfy { $0.matchPercent == 0 })
    }

    func test_rank_whenRecipeHasNoIngredients_doesNotDivideByZero() {
        let ranked = matcher.rank(recipes: [Fx.recipe(ingredients: [])], kitchen: Fx.kitchen("egg"))

        XCTAssertEqual(ranked.first?.matchPercent, 0)
    }

    func test_rank_matchesIngredientsIgnoringCaseAndSpacing() {
        let recipe = Fx.recipe(ingredients: ["Chicken  Breast"])

        let ranked = matcher.rank(recipes: [recipe], kitchen: Fx.kitchen("chicken breast"))

        XCTAssertEqual(ranked.first?.matchPercent, 1.0)
    }

    func test_rank_whenOneThirdIsCovered_returnsOneThird() {
        let recipe = Fx.recipe(ingredients: ["egg", "milk", "flour"])

        let ranked = matcher.rank(recipes: [recipe], kitchen: Fx.kitchen("egg"))

        XCTAssertEqual(ranked.first?.matchPercent ?? -1, 1.0 / 3.0, accuracy: 0.0001)
    }

    func test_rank_whenEquipmentIsMissing_reportsItAndRanksItLowerOnTies() {
        let needsBlender = Fx.recipe(id: "blender", title: "A", ingredients: ["egg"], equipment: [.blender])
        let noEquipment = Fx.recipe(id: "plain", title: "B", ingredients: ["egg"])

        let ranked = matcher.rank(recipes: [needsBlender, noEquipment], kitchen: Fx.kitchen("egg"))

        XCTAssertEqual(ranked.map(\.recipe.id), ["plain", "blender"])
        XCTAssertEqual(ranked.last?.missingEquipment, [ScpEquipment.blender])
    }

    func test_rank_whenMatchIsTied_breaksTieByTotalTimeThenTitle() {
        let slow = Fx.recipe(id: "slow", title: "A", prep: 30, cook: 30)
        let fastB = Fx.recipe(id: "fastB", title: "B", prep: 5, cook: 5)
        let fastA = Fx.recipe(id: "fastA", title: "A", prep: 5, cook: 5)

        let ranked = matcher.rank(recipes: [slow, fastB, fastA], kitchen: ScpKitchen())

        XCTAssertEqual(ranked.map(\.recipe.id), ["fastA", "fastB", "slow"])
    }

    func test_rank_estimatesCostOfMissingIngredientsOnly() {
        let recipe = Fx.recipe(ingredients: ["egg", "milk", "flour"])
        let matcher = ScpRecipeMatcher(costEstimator: ScpFlatCostEstimator(pricePerIngredient: 3))

        let ranked = matcher.rank(recipes: [recipe], kitchen: Fx.kitchen("egg"))

        XCTAssertEqual(ranked.first?.estimatedMissingCost, 6)
    }
}

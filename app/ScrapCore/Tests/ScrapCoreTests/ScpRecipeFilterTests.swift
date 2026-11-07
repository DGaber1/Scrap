import XCTest

@testable import ScrapCore

final class ScpRecipeFilterTests: XCTestCase {
    private typealias Fx = ScpTestFixtures
    private let matcher = ScpRecipeMatcher()

    private func ranked(_ recipes: [ScpRecipe], kitchen: ScpKitchen = ScpKitchen()) -> [ScpRankedRecipe] {
        matcher.rank(recipes: recipes, kitchen: kitchen)
    }

    func test_apply_withDefaultOptions_returnsEverythingInOrder() {
        let input = ranked([Fx.recipe(id: "a", title: "A"), Fx.recipe(id: "b", title: "B")])

        let result = ScpRecipeFilter.apply(ScpRecipeFilterOptions(), to: input)

        XCTAssertEqual(result, input)
    }

    func test_apply_withMaxTotalMinutes_dropsSlowerRecipes() {
        let input = ranked([
            Fx.recipe(id: "quick", prep: 5, cook: 5),
            Fx.recipe(id: "slow", prep: 30, cook: 60),
        ])

        let result = ScpRecipeFilter.apply(ScpRecipeFilterOptions(maxTotalMinutes: 20), to: input)

        XCTAssertEqual(result.map(\.recipe.id), ["quick"])
    }

    func test_apply_withMaxDifficulty_dropsHarderRecipes() {
        let input = ranked([
            Fx.recipe(id: "easy", difficulty: .easy),
            Fx.recipe(id: "hard", difficulty: .hard),
        ])

        let result = ScpRecipeFilter.apply(ScpRecipeFilterOptions(maxDifficulty: .medium), to: input)

        XCTAssertEqual(result.map(\.recipe.id), ["easy"])
    }

    func test_apply_withRequiredRestriction_keepsOnlyRecipesThatSatisfyIt() {
        let input = ranked([
            Fx.recipe(id: "vegan", tags: [.vegan, .vegetarian]),
            Fx.recipe(id: "plain", tags: []),
        ])

        let result = ScpRecipeFilter.apply(ScpRecipeFilterOptions(requiredRestrictions: [.vegan]), to: input)

        XCTAssertEqual(result.map(\.recipe.id), ["vegan"])
    }

    func test_apply_whenHidingMissingEquipment_dropsRecipesNeedingUnownedEquipment() {
        let input = ranked([
            Fx.recipe(id: "none"),
            Fx.recipe(id: "blender", equipment: [.blender]),
        ])

        let result = ScpRecipeFilter.apply(ScpRecipeFilterOptions(hidesRecipesNeedingMissingEquipment: true), to: input)

        XCTAssertEqual(result.map(\.recipe.id), ["none"])
    }

    func test_apply_withFastestSort_ordersByTotalTime() {
        let input = ranked([
            Fx.recipe(id: "slow", prep: 30, cook: 30),
            Fx.recipe(id: "fast", prep: 2, cook: 3),
        ])

        let result = ScpRecipeFilter.apply(ScpRecipeFilterOptions(sortOrder: .fastest), to: input)

        XCTAssertEqual(result.map(\.recipe.id), ["fast", "slow"])
    }

    func test_apply_withHighestProteinSort_putsRecipesWithoutProteinLast() {
        let input = ranked([
            Fx.recipe(id: "unknown", protein: nil),
            Fx.recipe(id: "low", protein: 5),
            Fx.recipe(id: "high", protein: 40),
        ])

        let result = ScpRecipeFilter.apply(ScpRecipeFilterOptions(sortOrder: .highestProtein), to: input)

        XCTAssertEqual(result.map(\.recipe.id), ["high", "low", "unknown"])
    }
}

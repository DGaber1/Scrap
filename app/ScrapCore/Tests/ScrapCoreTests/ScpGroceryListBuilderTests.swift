import XCTest

@testable import ScrapCore

final class ScpGroceryListBuilderTests: XCTestCase {
    private typealias Fx = ScpTestFixtures

    private struct StubScpCostEstimator: ScpCostEstimator {
        func estimatedCost(of ingredient: ScpIngredient, quantity: ScpQuantity) -> Decimal? { nil }
    }

    private let builder = ScpGroceryListBuilder(costEstimator: ScpFlatCostEstimator(pricePerIngredient: 3))

    func test_build_includesOnlyMissingIngredients() throws {
        let recipe = Fx.recipe(ingredients: ["egg", "milk", "flour"])

        let list = try builder.build(for: recipe, kitchen: Fx.kitchen("egg"))

        XCTAssertEqual(Set(list.items.map(\.ingredient.id)), ["milk", "flour"])
    }

    func test_build_whenKitchenHasEverything_returnsEmptyList() throws {
        let recipe = Fx.recipe(ingredients: ["egg", "milk"])

        let list = try builder.build(for: recipe, kitchen: Fx.kitchen("egg", "milk"))

        XCTAssertTrue(list.isEmpty)
    }

    func test_build_totalCostSumsItems() throws {
        let recipe = Fx.recipe(ingredients: ["egg", "milk", "flour"])

        let list = try builder.build(for: recipe, kitchen: ScpKitchen())

        XCTAssertEqual(list.totalEstimatedCost, 9)
    }

    func test_build_whenPriceIsUnknown_usesZeroInsteadOfThrowing() throws {
        let builder = ScpGroceryListBuilder(costEstimator: StubScpCostEstimator())

        let list = try builder.build(for: Fx.recipe(ingredients: ["egg"]), kitchen: ScpKitchen())

        XCTAssertEqual(list.items.first?.estimatedCost, 0)
    }

    func test_build_withServings_scalesQuantitiesFirst() throws {
        var recipe = Fx.recipe(ingredients: ["egg"], servings: 2)
        recipe.ingredients = [ScpRecipeIngredient(ingredient: Fx.ingredient("egg"), quantity: ScpQuantity(amount: 2, unit: .piece))]

        let list = try builder.build(for: recipe, kitchen: ScpKitchen(), servings: 4)

        XCTAssertEqual(list.items.first?.quantity.amount, 4)
    }

    func test_build_withZeroServings_throwsInvalidInput() {
        XCTAssertThrowsError(try builder.build(for: Fx.recipe(ingredients: ["egg"]), kitchen: ScpKitchen(), servings: 0)) { error in
            XCTAssertEqual(error as? ScpError, .invalidInput)
        }
    }

    func test_build_recordsWhichRecipeEachItemCameFrom() throws {
        let list = try builder.build(for: Fx.recipe(id: "r9", ingredients: ["egg"]), kitchen: ScpKitchen())

        XCTAssertEqual(list.items.first?.source, ScpGroceryListItem.Source.recipe(id: "r9"))
    }

    func test_adding_toEmptyList_containsTheMissingIngredients() throws {
        let recipe = Fx.recipe(id: "r1", ingredients: ["egg", "milk"])

        let list = try builder.adding(recipe, kitchen: Fx.kitchen("egg"), to: ScpGroceryList())

        XCTAssertEqual(list.items.map(\.ingredient.id), ["milk"])
    }

    func test_adding_whenIngredientAlreadyOnList_sumsAmountsAndDoesNotDuplicate() throws {
        let recipeA = Fx.recipe(id: "a", ingredients: ["milk"])
        let recipeB = Fx.recipe(id: "b", ingredients: ["milk", "flour"])
        let first = try builder.adding(recipeA, kitchen: ScpKitchen(), to: ScpGroceryList())

        let second = try builder.adding(recipeB, kitchen: ScpKitchen(), to: first)

        XCTAssertEqual(second.items.map(\.ingredient.id), ["milk", "flour"])
        XCTAssertEqual(second.items.first?.quantity.amount, 2)
        XCTAssertEqual(second.items.first?.estimatedCost, 6)
    }

    func test_merge_whenUnitsDiffer_keepsTheExistingLineUnchanged() {
        let existing = ScpGroceryList(items: [
            ScpGroceryListItem(ingredient: Fx.ingredient("milk"), quantity: ScpQuantity(amount: 1, unit: .cup), estimatedCost: 2)
        ])
        let additions = ScpGroceryList(items: [
            ScpGroceryListItem(ingredient: Fx.ingredient("milk"), quantity: ScpQuantity(amount: 1, unit: .liter), estimatedCost: 2)
        ])

        let merged = builder.merge(additions, into: existing)

        XCTAssertEqual(merged.items.count, 1)
        XCTAssertEqual(merged.items.first?.quantity, ScpQuantity(amount: 1, unit: .cup))
    }

    func test_merge_keepsCheckedStateOfExistingItems() {
        var checked = ScpGroceryListItem(ingredient: Fx.ingredient("milk"), quantity: ScpQuantity(amount: 1, unit: .cup))
        checked.isChecked = true

        let merged = builder.merge(ScpGroceryList(), into: ScpGroceryList(items: [checked]))

        XCTAssertEqual(merged.items.first?.isChecked, true)
    }

    func test_sourceRecipeCount_countsDistinctRecipes() throws {
        let one = try builder.adding(Fx.recipe(id: "a", ingredients: ["egg", "milk"]), kitchen: ScpKitchen(), to: ScpGroceryList())
        let two = try builder.adding(Fx.recipe(id: "b", ingredients: ["flour"]), kitchen: ScpKitchen(), to: one)

        XCTAssertEqual(two.sourceRecipeCount, 2)
    }

    func test_sourceRecipeCount_ignoresManualItems() {
        let list = ScpGroceryList(items: [ScpGroceryListItem(ingredient: Fx.ingredient("tape"), quantity: ScpQuantity(amount: 1, unit: .piece))])

        XCTAssertEqual(list.sourceRecipeCount, 0)
    }
}

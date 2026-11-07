import XCTest

@testable import ScrapCore

/// These show the pattern for testing async, repository-dependent code
/// (view models look just like this) with no network.
final class InMemoryScpRepositoryTests: XCTestCase {

    func test_kitchenRepository_addThenLoad_returnsTheItem() async throws {
        let repository = InMemoryScpKitchenRepository()
        let item = ScpPantryItem(ingredient: ScpIngredient(name: "Egg"))

        try await repository.addPantryItem(item)
        let kitchen = try await repository.loadKitchen()

        XCTAssertEqual(kitchen.pantryItems.map(\.id), [item.id])
    }

    func test_kitchenRepository_removeItem_removesIt() async throws {
        let repository = InMemoryScpKitchenRepository()
        let item = ScpPantryItem(ingredient: ScpIngredient(name: "Egg"))
        try await repository.addPantryItem(item)

        try await repository.removePantryItem(id: item.id)

        let kitchen = try await repository.loadKitchen()
        XCTAssertTrue(kitchen.pantryItems.isEmpty)
    }

    func test_kitchenRepository_whenConfiguredToFail_throwsThatError() async {
        let repository = InMemoryScpKitchenRepository(failure: .network)

        do {
            _ = try await repository.loadKitchen()
            XCTFail("Expected an error")
        } catch {
            XCTAssertEqual(error as? ScpError, .network)
        }
    }

    func test_recipeRepository_search_returnsSampleRecipesByDefault() async throws {
        let recipes = try await InMemoryScpRecipeRepository().searchRecipes(ingredientNames: ["egg"])

        XCTAssertFalse(recipes.isEmpty)
    }

    func test_recipeRepository_recipeWithUnknownID_throwsNotFound() async {
        do {
            _ = try await InMemoryScpRecipeRepository().recipe(id: "missing")
            XCTFail("Expected an error")
        } catch {
            XCTAssertEqual(error as? ScpError, .notFound)
        }
    }

    func test_groceryListRepository_saveThenLoad_returnsTheList() async throws {
        let repository = InMemoryScpGroceryListRepository()
        let list = ScpGroceryList(items: [ScpGroceryListItem(ingredient: ScpIngredient(name: "Milk"), quantity: ScpQuantity(amount: 1, unit: .liter))])

        try await repository.saveList(list)

        let loaded = try await repository.loadList()
        XCTAssertEqual(loaded, list)
    }

    func test_authService_signInThenCurrentUser_returnsTheUser() async throws {
        let service = InMemoryScpAuthService()

        let user = try await service.signIn(email: "a@example.com", password: "pw")

        let current = await service.currentUser()
        XCTAssertEqual(current, user)
    }

    func test_authService_signOut_clearsTheUser() async throws {
        let service = InMemoryScpAuthService()
        _ = try await service.signIn(email: "a@example.com", password: "pw")

        await service.signOut()

        let current = await service.currentUser()
        XCTAssertNil(current)
    }

    func test_sampleData_matchesTheSampleKitchenSensibly() {
        let ranked = ScpRecipeMatcher().rank(recipes: ScpSampleData.recipes, kitchen: ScpSampleData.kitchen)

        XCTAssertEqual(ranked.count, ScpSampleData.recipes.count)
        XCTAssertGreaterThan(ranked.first?.matchPercent ?? 0, 0)
    }

    func test_ingredientRepository_search_returnsPrefixMatchesFirst() async throws {
        let result = try await InMemoryScpIngredientRepository().searchIngredients(matching: "chick")

        XCTAssertFalse(result.isEmpty)
        XCTAssertTrue(result.allSatisfy { $0.id.contains("chick") })
        XCTAssertLessThanOrEqual(result.count, 6)
    }

    func test_ingredientRepository_search_whenQueryIsBlank_returnsEmpty() async throws {
        let result = try await InMemoryScpIngredientRepository().searchIngredients(matching: "  ")

        XCTAssertTrue(result.isEmpty)
    }

    func test_ingredientRepository_whenConfiguredToFail_throwsThatError() async {
        do {
            _ = try await InMemoryScpIngredientRepository(failure: .network).searchIngredients(matching: "egg")
            XCTFail("Expected an error")
        } catch {
            XCTAssertEqual(error as? ScpError, .network)
        }
    }

    func test_equipment_allKnown_hasUniqueIDs() {
        let ids = ScpEquipment.allKnown.map(\.id)

        XCTAssertEqual(Set(ids).count, ids.count)
        XCTAssertTrue(ids.contains("stovetop"))
    }
}

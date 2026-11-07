import XCTest

@testable import ScrapCore

final class InMemoryScpRound3Tests: XCTestCase {

    func test_favorites_setFavoriteTrue_savesNewestFirst() async throws {
        let repository = InMemoryScpFavoritesRepository()
        let first = ScpSampleData.recipes[0]
        let second = ScpSampleData.recipes[1]

        try await repository.setFavorite(first, isFavorite: true)
        try await repository.setFavorite(second, isFavorite: true)

        let saved = try await repository.loadFavorites()
        XCTAssertEqual(saved.map(\.id), [second.id, first.id])
    }

    func test_favorites_savingTwice_doesNotDuplicate() async throws {
        let repository = InMemoryScpFavoritesRepository()
        let recipe = ScpSampleData.recipes[0]

        try await repository.setFavorite(recipe, isFavorite: true)
        try await repository.setFavorite(recipe, isFavorite: true)

        let saved = try await repository.loadFavorites()
        XCTAssertEqual(saved.count, 1)
    }

    func test_favorites_setFavoriteFalse_removesIt() async throws {
        let recipe = ScpSampleData.recipes[0]
        let repository = InMemoryScpFavoritesRepository(recipes: [recipe])

        try await repository.setFavorite(recipe, isFavorite: false)

        let saved = try await repository.loadFavorites()
        XCTAssertTrue(saved.isEmpty)
    }

    func test_community_startsWithApprovedSamples() async throws {
        let repository = InMemoryScpCommunityRepository()

        let recipes = try await repository.approvedRecipes()

        XCTAssertEqual(recipes.count, ScpSampleData.communityRecipes.count)
        XCTAssertTrue(recipes.allSatisfy { $0.source == .community })
    }

    func test_community_submittedRecipe_isPendingAndNotListed() async throws {
        let repository = InMemoryScpCommunityRepository()
        let recipe = ScpSampleData.recipes[0]
        let submission = ScpRecipeSubmission(authorID: UUID(), recipe: recipe, status: .approved)

        try await repository.submit(submission)

        let approved = try await repository.approvedRecipes()
        XCTAssertFalse(approved.contains { $0.id == recipe.id })
        let pending = await repository.submissions(withStatus: .pending)
        XCTAssertEqual(pending.count, 1)
        XCTAssertEqual(pending.first?.recipe.source, .community)
    }

    func test_pantryItem_isNearingExpiration_insideWindowOnly() {
        let now = Date()
        let soon = ScpPantryItem(
            ingredient: ScpIngredient(name: "Milk"),
            expirationDate: now.addingTimeInterval(2 * 24 * 60 * 60)
        )
        let later = ScpPantryItem(
            ingredient: ScpIngredient(name: "Rice"),
            expirationDate: now.addingTimeInterval(30 * 24 * 60 * 60)
        )

        XCTAssertTrue(soon.isNearingExpiration(asOf: now))
        XCTAssertFalse(later.isNearingExpiration(asOf: now))
    }
}

final class ScpIngredientLineParserTests: XCTestCase {

    func test_parse_amountUnitAndName() {
        let parsed = ScpIngredientLineParser.parse("2 cups all purpose flour")

        XCTAssertEqual(parsed?.ingredient.name, "all purpose flour")
        XCTAssertEqual(parsed?.quantity, ScpQuantity(amount: 2, unit: .cup))
    }

    func test_parse_fractionAmount() {
        let parsed = ScpIngredientLineParser.parse("1/2 tsp salt")

        XCTAssertEqual(parsed?.quantity, ScpQuantity(amount: 0.5, unit: .teaspoon))
        XCTAssertEqual(parsed?.ingredient.name, "salt")
    }

    func test_parse_countWithoutUnit_isPieces() {
        let parsed = ScpIngredientLineParser.parse("3 eggs")

        XCTAssertEqual(parsed?.quantity, ScpQuantity(amount: 3, unit: .piece))
        XCTAssertEqual(parsed?.ingredient.name, "eggs")
    }

    func test_parse_nameOnly_isOnePiece() {
        let parsed = ScpIngredientLineParser.parse("  salt ")

        XCTAssertEqual(parsed?.quantity, ScpQuantity(amount: 1, unit: .piece))
        XCTAssertEqual(parsed?.ingredient.name, "salt")
    }

    func test_parse_unitWithNoName_treatsUnitWordAsName() {
        let parsed = ScpIngredientLineParser.parse("2 cups")

        XCTAssertEqual(parsed?.ingredient.name, "cups")
    }

    func test_parse_blankLine_returnsNil() {
        XCTAssertNil(ScpIngredientLineParser.parse("   "))
    }
}

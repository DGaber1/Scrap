import XCTest

@testable import ScrapCore

final class ScpSpoonacularRecipeClientTests: XCTestCase {
    private let config = ScpConfig(spoonacularAPIKey: "test-key")

    private func client(_ transport: StubScpHTTPTransport) -> ScpSpoonacularRecipeClient {
        ScpSpoonacularRecipeClient(config: config, transport: transport)
    }

    func test_searchByIngredients_whenResponseIsValid_returnsConvertedRecipes() async throws {
        let json = """
            [{"id": 42, "title": "Egg Fried Rice", "image": "https://example.com/a.jpg",
              "usedIngredients": [{"id": 1, "name": "Egg", "amount": 2, "unit": ""}],
              "missedIngredients": [{"id": 2, "name": "Soy Sauce", "amount": 1.5, "unit": "tbsp"}]}]
            """

        let recipes = try await client(StubScpHTTPTransport(json: json)).searchByIngredients(["egg"])

        XCTAssertEqual(recipes.count, 1)
        XCTAssertEqual(recipes.first?.id, "42")
        XCTAssertEqual(recipes.first?.ingredients.map(\.ingredient.id), ["egg", "soy sauce"])
        XCTAssertEqual(recipes.first?.ingredients.last?.quantity.unit, .tablespoon)
        XCTAssertEqual(recipes.first?.source, .spoonacular)
    }

    func test_searchByIngredients_whenFieldsAreMissing_skipsOnlyTheBrokenResult() async throws {
        let json = """
            [{"id": 1}, {"id": 2, "title": "Okay Recipe"}]
            """

        let recipes = try await client(StubScpHTTPTransport(json: json)).searchByIngredients(["egg"])

        XCTAssertEqual(recipes.map(\.id), ["2"])
        XCTAssertEqual(recipes.first?.ingredients, [])
    }

    func test_searchByIngredients_whenNoIngredientNames_returnsEmptyWithoutCallingNetwork() async throws {
        let transport = StubScpHTTPTransport()

        let recipes = try await client(transport).searchByIngredients([])

        XCTAssertTrue(recipes.isEmpty)
        XCTAssertTrue(transport.requestedURLs.isEmpty)
    }

    func test_searchByIngredients_sendsApiKeyAndIngredientsInTheURL() async throws {
        let transport = StubScpHTTPTransport()

        _ = try await client(transport).searchByIngredients(["egg", "milk"])

        let url = transport.requestedURLs.first?.absoluteString ?? ""
        XCTAssertTrue(url.contains("api.spoonacular.com/recipes/findByIngredients"))
        XCTAssertTrue(url.contains("apiKey=test-key"))
        XCTAssertTrue(url.contains("ingredients=egg,milk"))
    }

    func test_searchByIngredients_whenQuotaIsExceeded_throwsRateLimited() async {
        await assertSearchThrows(.rateLimited, transport: StubScpHTTPTransport(statusCode: 402))
        await assertSearchThrows(.rateLimited, transport: StubScpHTTPTransport(statusCode: 429))
    }

    func test_searchByIngredients_whenKeyIsRejected_throwsUnauthorized() async {
        await assertSearchThrows(.unauthorized, transport: StubScpHTTPTransport(statusCode: 401))
    }

    func test_searchByIngredients_whenServerFails_throwsNetwork() async {
        await assertSearchThrows(.network, transport: StubScpHTTPTransport(statusCode: 500))
    }

    func test_searchByIngredients_whenConnectionFails_throwsNetwork() async {
        await assertSearchThrows(.network, transport: StubScpHTTPTransport(shouldThrow: true))
    }

    func test_searchByIngredients_whenBodyIsGarbage_throwsInvalidData() async {
        await assertSearchThrows(.invalidData, transport: StubScpHTTPTransport(json: "not json"))
    }

    func test_recipe_whenResponseIsValid_returnsInstructionsAndServings() async throws {
        let json = """
            {"id": 7, "title": "Soup", "readyInMinutes": 30, "servings": 4, "vegan": true,
             "extendedIngredients": [{"id": 9, "name": "Carrot", "amount": 3, "unit": ""}],
             "analyzedInstructions": [{"steps": [{"step": "Chop."}, {"step": "Simmer."}]}]}
            """

        let recipe = try await client(StubScpHTTPTransport(json: json)).recipe(id: "7")

        XCTAssertEqual(recipe.title, "Soup")
        XCTAssertEqual(recipe.instructions, ["Chop.", "Simmer."])
        XCTAssertEqual(recipe.servings, 4)
        XCTAssertEqual(recipe.totalTimeMinutes, 30)
        XCTAssertTrue(recipe.dietaryTags.contains(.vegan))
    }

    func test_recipe_whenIDIsUnknown_throwsNotFound() async {
        do {
            _ = try await client(StubScpHTTPTransport(statusCode: 404)).recipe(id: "nope")
            XCTFail("Expected an error")
        } catch {
            XCTAssertEqual(error as? ScpError, .notFound)
        }
    }

    func test_recipe_whenResponseHasNoTitle_throwsInvalidData() async {
        do {
            _ = try await client(StubScpHTTPTransport(json: "{\"id\": 7}")).recipe(id: "7")
            XCTFail("Expected an error")
        } catch {
            XCTAssertEqual(error as? ScpError, .invalidData)
        }
    }

    func test_autocompleteIngredients_whenResponseIsValid_returnsIngredients() async throws {
        let json = """
            [{"id": 5062, "name": "chicken breast", "image": "x.jpg"}, {"id": 1, "name": ""}, {"id": 2}]
            """
        let transport = StubScpHTTPTransport(json: json)

        let result = try await client(transport).autocompleteIngredients("chick")

        XCTAssertEqual(result.map(\.id), ["chicken breast"])
        XCTAssertEqual(result.first?.spoonacularID, 5062)
        let url = transport.requestedURLs.first?.absoluteString ?? ""
        XCTAssertTrue(url.contains("/food/ingredients/autocomplete"))
        XCTAssertTrue(url.contains("query=chick"))
    }

    func test_autocompleteIngredients_whenQueryIsBlank_returnsEmptyWithoutCallingNetwork() async throws {
        let transport = StubScpHTTPTransport()

        let result = try await client(transport).autocompleteIngredients("   ")

        XCTAssertTrue(result.isEmpty)
        XCTAssertTrue(transport.requestedURLs.isEmpty)
    }

    func test_autocompleteIngredients_whenQuotaIsExceeded_throwsRateLimited() async {
        do {
            _ = try await client(StubScpHTTPTransport(statusCode: 402)).autocompleteIngredients("egg")
            XCTFail("Expected an error")
        } catch {
            XCTAssertEqual(error as? ScpError, .rateLimited)
        }
    }

    private func assertSearchThrows(
        _ expected: ScpError,
        transport: StubScpHTTPTransport,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        do {
            _ = try await client(transport).searchByIngredients(["egg"])
            XCTFail("Expected \(expected)", file: file, line: line)
        } catch {
            XCTAssertEqual(error as? ScpError, expected, file: file, line: line)
        }
    }
}

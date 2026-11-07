import Foundation
import ScrapCore

/// Recipes straight from Spoonacular. A caching layer (REQ-D-07) wraps this later.
struct ScpSpoonacularRecipeRepository: ScpRecipeRepository {
    private let client: ScpSpoonacularRecipeClient

    init(client: ScpSpoonacularRecipeClient) {
        self.client = client
    }

    func searchRecipes(ingredientNames: [String]) async throws -> [ScpRecipe] {
        try await client.searchByIngredients(ingredientNames)
    }

    func recipe(id: String) async throws -> ScpRecipe {
        try await client.recipe(id: id)
    }
}

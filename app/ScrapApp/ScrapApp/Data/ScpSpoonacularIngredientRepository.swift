import Foundation
import ScrapCore

/// Ingredient autocomplete straight from Spoonacular.
struct ScpSpoonacularIngredientRepository: ScpIngredientRepository {
    private let client: ScpSpoonacularRecipeClient

    init(client: ScpSpoonacularRecipeClient) {
        self.client = client
    }

    func searchIngredients(matching query: String) async throws -> [ScpIngredient] {
        try await client.autocompleteIngredients(query)
    }
}

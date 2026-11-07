import Foundation

/// Spoonacular's host and paths, grouped so no string is repeated elsewhere (REQ-D-12).
enum ScpSpoonacularEndpoint {
    static let host = "api.spoonacular.com"
    static let searchByIngredients = "/recipes/findByIngredients"
    static let recipeInformation = "/recipes/{id}/information"
    static let ingredientAutocomplete = "/food/ingredients/autocomplete"

    /// Fills the `{id}` placeholder in `template`.
    static func path(_ template: String, id: String) -> String {
        template.replacingOccurrences(of: "{id}", with: id)
    }
}

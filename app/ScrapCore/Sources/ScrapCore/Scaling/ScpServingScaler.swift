import Foundation

/// Rescales a recipe's ingredient quantities when the user changes the
/// number of servings.
public enum ScpServingScaler {

    /// Returns `recipe` rescaled to `servings`.
    /// - Throws: ``ScpError/invalidInput`` if `servings` (or the recipe's own
    ///   serving count) is not a positive number.
    public static func scale(_ recipe: ScpRecipe, toServings servings: Int) throws -> ScpRecipe {
        guard servings > 0, recipe.servings > 0 else { throw ScpError.invalidInput }
        let ratio = Double(servings) / Double(recipe.servings)
        var scaled = recipe
        scaled.servings = servings
        scaled.ingredients = recipe.ingredients.map {
            ScpRecipeIngredient(ingredient: $0.ingredient, quantity: $0.quantity.scaled(by: ratio))
        }
        return scaled
    }
}

import Foundation

/// Where recipes come from. The implementation (Spoonacular, a cache, a test
/// double) lives outside ScrapCore's model and matching code (REQ-D-03).
public protocol ScpRecipeRepository: Sendable {
    /// Candidate recipes that use as many of `ingredientNames` as possible.
    /// Ranking against the user's whole kitchen is done afterwards by ``ScpRecipeMatcher``.
    /// - Throws: ``ScpError`` for every failure (REQ-D-22).
    func searchRecipes(ingredientNames: [String]) async throws -> [ScpRecipe]

    /// The full recipe, including instructions, for `id`.
    /// - Throws: ``ScpError/notFound`` if no recipe has that ID.
    func recipe(id: String) async throws -> ScpRecipe
}

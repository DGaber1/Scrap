import Foundation

/// Stores the recipes a signed-in user has saved with the heart button.
public protocol ScpFavoritesRepository: Sendable {
    /// Every saved recipe, newest first.
    func loadFavorites() async throws -> [ScpRecipe]

    /// Saves the recipe when `isFavorite` is true, or removes it when false.
    /// Saving a recipe that is already saved changes nothing.
    func setFavorite(_ recipe: ScpRecipe, isFavorite: Bool) async throws
}

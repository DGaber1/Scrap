import Foundation

/// A favorites repository that keeps recipes in memory.
public actor InMemoryScpFavoritesRepository: ScpFavoritesRepository {
    private var recipes: [ScpRecipe]
    private let failure: ScpError?

    /// Creates a repository starting from `recipes` (newest first).
    public init(recipes: [ScpRecipe] = [], failure: ScpError? = nil) {
        self.recipes = recipes
        self.failure = failure
    }

    public func loadFavorites() async throws -> [ScpRecipe] {
        if let failure { throw failure }
        return recipes
    }

    public func setFavorite(_ recipe: ScpRecipe, isFavorite: Bool) async throws {
        if let failure { throw failure }
        if isFavorite {
            guard !recipes.contains(where: { $0.id == recipe.id }) else { return }
            recipes.insert(recipe, at: 0)
        } else {
            recipes.removeAll { $0.id == recipe.id }
        }
    }
}

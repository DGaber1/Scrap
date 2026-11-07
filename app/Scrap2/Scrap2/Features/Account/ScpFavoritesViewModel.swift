import Foundation
import Observation
import ScrapCore

/// The recipes saved with the heart button.
@MainActor
@Observable
final class ScpFavoritesViewModel {
    private(set) var recipes: [ScpRecipe] = []
    private(set) var error: ScpError?

    private let repository: any ScpFavoritesRepository

    init(repository: any ScpFavoritesRepository) {
        self.repository = repository
    }

    func isFavorite(_ recipeID: String) -> Bool {
        recipes.contains { $0.id == recipeID }
    }

    func load() async {
        await run { _ in }
    }

    func toggle(_ recipe: ScpRecipe) async {
        let makeFavorite = !isFavorite(recipe.id)
        await run { try await $0.setFavorite(recipe, isFavorite: makeFavorite) }
    }

    private func run(_ change: (any ScpFavoritesRepository) async throws -> Void) async {
        do {
            try await change(repository)
            recipes = try await repository.loadFavorites()
            error = nil
        } catch {
            self.error = (error as? ScpError) ?? .unknown(String(describing: error))
        }
    }
}

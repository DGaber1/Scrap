import Foundation
import ScrapCore

/// Keeps saved recipes on the device between launches. A stand-in until the
/// Supabase repository (REQ-D-07) replaces it.
actor ScpUserDefaultsFavoritesRepository: ScpFavoritesRepository {
    private let storageKey: String

    init(storageKey: String = "scrap.favorites.v1") {
        self.storageKey = storageKey
    }

    func loadFavorites() async throws -> [ScpRecipe] {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return [] }
        do {
            return try JSONDecoder().decode([ScpRecipe].self, from: data)
        } catch {
            throw ScpError.invalidData
        }
    }

    func setFavorite(_ recipe: ScpRecipe, isFavorite: Bool) async throws {
        var recipes = try await loadFavorites()
        if isFavorite {
            guard !recipes.contains(where: { $0.id == recipe.id }) else { return }
            recipes.insert(recipe, at: 0)
        } else {
            recipes.removeAll { $0.id == recipe.id }
        }
        do {
            UserDefaults.standard.set(try JSONEncoder().encode(recipes), forKey: storageKey)
        } catch {
            throw ScpError.invalidData
        }
    }
}

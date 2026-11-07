import Foundation
import Observation
import ScrapCore

/// Finds and ranks recipes for the kitchen. The kitchen itself lives in `ScpKitchenViewModel`.
@MainActor
@Observable
final class ScpHomeViewModel {
    private(set) var state: ScpViewState<[ScpRankedRecipe]> = .idle

    private var lastSearchKey: String?

    private let recipeRepository: any ScpRecipeRepository
    private let matcher: ScpRecipeMatcher

    init(recipeRepository: any ScpRecipeRepository, matcher: ScpRecipeMatcher) {
        self.recipeRepository = recipeRepository
        self.matcher = matcher
    }

    /// Searches for recipes using the kitchen's ingredients, then ranks them.
    /// Recipes that break one of the kitchen's dietary restrictions are left out.
    /// Skips the network call when the ingredients have not changed since the last search,
    /// which protects the daily API quota. Pass `force: true` to search again anyway.
    func findRecipes(for kitchen: ScpKitchen, force: Bool = false) async {
        guard !kitchen.pantryItems.isEmpty else {
            lastSearchKey = nil
            state = .empty
            return
        }
        let key = kitchen.ingredientIDs.sorted().joined(separator: "|")
            + "#" + kitchen.restrictions.map(\.rawValue).sorted().joined(separator: ",")
        if !force, key == lastSearchKey, case .loaded = state { return }
        state = .loading
        do {
            let names = kitchen.pantryItems.map { $0.ingredient.name }
            let recipes = try await recipeRepository.searchRecipes(ingredientNames: names)
            let allowed = recipes.filter { kitchen.restrictions.isSubset(of: $0.dietaryTags) || $0.dietaryTags.isEmpty }
            let ranked = matcher.rank(recipes: allowed, kitchen: kitchen)
            guard !Task.isCancelled else { return }
            lastSearchKey = key
            state = ranked.isEmpty ? .empty : .loaded(ranked)
        } catch {
            guard !Task.isCancelled else { return }
            state = .failed((error as? ScpError) ?? .unknown(String(describing: error)))
        }
    }
}

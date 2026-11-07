import Foundation
import Observation
import ScrapCore

/// Finds and ranks recipes for the kitchen. The kitchen itself lives in `ScpKitchenViewModel`.
@MainActor
@Observable
final class ScpHomeViewModel {
    /// The search results before the filter sheet's choices are applied.
    private(set) var state: ScpViewState<[ScpRankedRecipe]> = .idle
    var filterOptions = ScpRecipeFilterOptions()

    private var lastSearchKey: String?

    private let recipeRepository: any ScpRecipeRepository
    private let matcher: ScpRecipeMatcher

    init(recipeRepository: any ScpRecipeRepository, matcher: ScpRecipeMatcher) {
        self.recipeRepository = recipeRepository
        self.matcher = matcher
    }

    /// The results with the current filters and sort order applied.
    var visibleRecipes: [ScpRankedRecipe] {
        guard case .loaded(let ranked) = state else { return [] }
        return ScpRecipeFilter.apply(filterOptions, to: ranked)
    }

    /// How many filters differ from the defaults, for the badge on the filter button.
    var activeFilterCount: Int {
        let options = filterOptions
        var count = 0
        if options.maxTotalMinutes != nil { count += 1 }
        if options.maxDifficulty != nil { count += 1 }
        if !options.requiredRestrictions.isEmpty { count += 1 }
        if options.mealType != nil { count += 1 }
        if options.cuisine != nil { count += 1 }
        if options.hidesRecipesNeedingMissingEquipment { count += 1 }
        if options.sortOrder != .bestMatch { count += 1 }
        return count
    }

    func resetFilters() {
        filterOptions = ScpRecipeFilterOptions()
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

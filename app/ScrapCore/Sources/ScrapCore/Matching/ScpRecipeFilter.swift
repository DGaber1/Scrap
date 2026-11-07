import Foundation

/// Narrows and re-sorts ranked recipes according to ``ScpRecipeFilterOptions``.
public enum ScpRecipeFilter {

    /// The recipes in `ranked` that pass `options`, ordered by `options.sortOrder`.
    /// `.bestMatch` keeps the order the matcher produced.
    public static func apply(_ options: ScpRecipeFilterOptions, to ranked: [ScpRankedRecipe]) -> [ScpRankedRecipe] {
        let filtered = ranked.filter { passes($0, options) }

        switch options.sortOrder {
        case .bestMatch:
            return filtered
        case .fastest:
            return filtered.sorted { lhs, rhs in
                if lhs.recipe.totalTimeMinutes != rhs.recipe.totalTimeMinutes {
                    return lhs.recipe.totalTimeMinutes < rhs.recipe.totalTimeMinutes
                }
                return lhs.recipe.title < rhs.recipe.title
            }
        case .lowestCost:
            return filtered.sorted { lhs, rhs in
                if lhs.estimatedMissingCost != rhs.estimatedMissingCost {
                    return lhs.estimatedMissingCost < rhs.estimatedMissingCost
                }
                return lhs.recipe.title < rhs.recipe.title
            }
        case .highestProtein:
            return filtered.sorted { lhs, rhs in
                let left = lhs.recipe.proteinGramsPerServing ?? -1
                let right = rhs.recipe.proteinGramsPerServing ?? -1
                if left != right { return left > right }
                return lhs.recipe.title < rhs.recipe.title
            }
        }
    }

    private static func passes(_ ranked: ScpRankedRecipe, _ options: ScpRecipeFilterOptions) -> Bool {
        let recipe = ranked.recipe
        if let limit = options.maxTotalMinutes, recipe.totalTimeMinutes > limit { return false }
        if let limit = options.maxDifficulty, recipe.difficulty > limit { return false }
        if !options.requiredRestrictions.isSubset(of: recipe.dietaryTags) { return false }
        if let mealType = options.mealType, !recipe.mealTypes.contains(mealType) { return false }
        if let cuisine = options.cuisine, recipe.cuisine != cuisine { return false }
        if options.hidesRecipesNeedingMissingEquipment, !ranked.missingEquipment.isEmpty { return false }
        return true
    }
}

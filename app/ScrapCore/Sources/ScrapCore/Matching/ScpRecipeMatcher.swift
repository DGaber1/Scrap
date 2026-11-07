import Foundation

/// Ranks recipes by how much of each one the user can already make from
/// their kitchen. Pure and synchronous, so it is unit-tested without a
/// network, a database, or SwiftUI.
public struct ScpRecipeMatcher: Sendable {
    private let costEstimator: any ScpCostEstimator

    /// Creates a matcher that prices missing ingredients with `costEstimator`.
    public init(costEstimator: any ScpCostEstimator = ScpFlatCostEstimator()) {
        self.costEstimator = costEstimator
    }

    /// Ranks `recipes` against `kitchen`, best match first. Ties are broken by
    /// fewer missing pieces of equipment, then shorter total time, then title,
    /// so the order is the same every time.
    public func rank(recipes: [ScpRecipe], kitchen: ScpKitchen) -> [ScpRankedRecipe] {
        let haveIngredients = kitchen.ingredientIDs
        let haveEquipment = kitchen.equipmentIDs

        let ranked = recipes.map { recipe -> ScpRankedRecipe in
            let missing = recipe.ingredients.filter { !haveIngredients.contains($0.ingredient.id) }
            let missingEquipment = recipe.requiredEquipment.filter { !haveEquipment.contains($0.id) }
            let covered = recipe.ingredients.count - missing.count
            let percent = recipe.ingredients.isEmpty ? 0 : Double(covered) / Double(recipe.ingredients.count)
            let cost = missing.reduce(Decimal(0)) { total, item in
                total + (costEstimator.estimatedCost(of: item.ingredient, quantity: item.quantity) ?? 0)
            }
            return ScpRankedRecipe(
                recipe: recipe,
                matchPercent: percent,
                missingIngredients: missing,
                missingEquipment: missingEquipment,
                estimatedMissingCost: cost
            )
        }

        return ranked.sorted { lhs, rhs in
            if lhs.matchPercent != rhs.matchPercent { return lhs.matchPercent > rhs.matchPercent }
            if lhs.missingEquipment.count != rhs.missingEquipment.count {
                return lhs.missingEquipment.count < rhs.missingEquipment.count
            }
            if lhs.recipe.totalTimeMinutes != rhs.recipe.totalTimeMinutes {
                return lhs.recipe.totalTimeMinutes < rhs.recipe.totalTimeMinutes
            }
            return lhs.recipe.title < rhs.recipe.title
        }
    }
}

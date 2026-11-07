import Foundation

/// A recipe paired with how well the user's kitchen covers it. Produced only
/// by ``ScpRecipeMatcher``.
public struct ScpRankedRecipe: Identifiable, Equatable, Sendable {
    public var id: String { recipe.id }
    public let recipe: ScpRecipe
    /// Share of the recipe's ingredients the user already has, from 0.0 to 1.0.
    public let matchPercent: Double
    public let missingIngredients: [ScpRecipeIngredient]
    public let missingEquipment: [ScpEquipment]
    /// Estimated cost of buying the missing ingredients.
    public let estimatedMissingCost: Decimal

    /// Creates a ranked recipe.
    public init(
        recipe: ScpRecipe,
        matchPercent: Double,
        missingIngredients: [ScpRecipeIngredient],
        missingEquipment: [ScpEquipment] = [],
        estimatedMissingCost: Decimal = 0
    ) {
        self.recipe = recipe
        self.matchPercent = matchPercent
        self.missingIngredients = missingIngredients
        self.missingEquipment = missingEquipment
        self.estimatedMissingCost = estimatedMissingCost
    }
}

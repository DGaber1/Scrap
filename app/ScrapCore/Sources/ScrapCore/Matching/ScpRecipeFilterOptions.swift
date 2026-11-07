import Foundation

/// What the user picked on the filters sheet.
public struct ScpRecipeFilterOptions: Equatable, Sendable {

    /// How to order the filtered results.
    public enum SortOrder: String, CaseIterable, Sendable {
        case bestMatch
        case fastest
        case lowestCost
        case highestProtein
    }

    public var maxTotalMinutes: Int?
    public var maxDifficulty: ScpRecipe.Difficulty?
    /// A recipe must satisfy every restriction listed here.
    public var requiredRestrictions: Set<ScpDietaryRestriction>
    public var mealType: ScpMealType?
    public var cuisine: ScpCuisine?
    /// When true, hide recipes that need equipment the user does not own.
    public var hidesRecipesNeedingMissingEquipment: Bool
    public var sortOrder: SortOrder

    /// Creates options. The defaults filter nothing and keep best-match order.
    public init(
        maxTotalMinutes: Int? = nil,
        maxDifficulty: ScpRecipe.Difficulty? = nil,
        requiredRestrictions: Set<ScpDietaryRestriction> = [],
        mealType: ScpMealType? = nil,
        cuisine: ScpCuisine? = nil,
        hidesRecipesNeedingMissingEquipment: Bool = false,
        sortOrder: SortOrder = .bestMatch
    ) {
        self.maxTotalMinutes = maxTotalMinutes
        self.maxDifficulty = maxDifficulty
        self.requiredRestrictions = requiredRestrictions
        self.mealType = mealType
        self.cuisine = cuisine
        self.hidesRecipesNeedingMissingEquipment = hidesRecipesNeedingMissingEquipment
        self.sortOrder = sortOrder
    }
}

import Foundation

/// An ingredient as it appears in one recipe, with the quantity that recipe needs.
public struct ScpRecipeIngredient: Codable, Identifiable, Equatable, Hashable, Sendable {
    public var id: String { ingredient.id }
    public var ingredient: ScpIngredient
    public var quantity: ScpQuantity

    /// Creates a recipe ingredient.
    public init(ingredient: ScpIngredient, quantity: ScpQuantity) {
        self.ingredient = ingredient
        self.quantity = quantity
    }
}

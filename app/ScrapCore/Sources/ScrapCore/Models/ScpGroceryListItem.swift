import Foundation

/// One line on a grocery list.
public struct ScpGroceryListItem: Codable, Identifiable, Equatable, Sendable {

    /// Why the item is on the list.
    public enum Source: Codable, Equatable, Sendable {
        /// Missing from the kitchen for the recipe with this ID.
        case recipe(id: String)
        /// Added by hand.
        case manual
    }

    public let id: UUID
    public var ingredient: ScpIngredient
    public var quantity: ScpQuantity
    public var estimatedCost: Decimal
    public var isChecked: Bool
    public var source: Source

    /// Creates a grocery list item.
    public init(
        id: UUID = UUID(),
        ingredient: ScpIngredient,
        quantity: ScpQuantity,
        estimatedCost: Decimal = 0,
        isChecked: Bool = false,
        source: Source = .manual
    ) {
        self.id = id
        self.ingredient = ingredient
        self.quantity = quantity
        self.estimatedCost = estimatedCost
        self.isChecked = isChecked
        self.source = source
    }
}

import Foundation

/// A list of items to buy. A guest's list has `ownerID == nil` and is not
/// saved past the current day.
public struct ScpGroceryList: Codable, Identifiable, Equatable, Sendable {
    public let id: UUID
    public var ownerID: UUID?
    public var items: [ScpGroceryListItem]

    /// Creates a grocery list.
    public init(id: UUID = UUID(), ownerID: UUID? = nil, items: [ScpGroceryListItem] = []) {
        self.id = id
        self.ownerID = ownerID
        self.items = items
    }

    /// The sum of every item's estimated cost.
    public var totalEstimatedCost: Decimal {
        items.reduce(Decimal(0)) { $0 + $1.estimatedCost }
    }

    /// Whether the list has no items.
    public var isEmpty: Bool { items.isEmpty }

    /// How many different recipes the list's items were added for.
    public var sourceRecipeCount: Int {
        var recipeIDs = Set<String>()
        for item in items {
            if case .recipe(let id) = item.source { recipeIDs.insert(id) }
        }
        return recipeIDs.count
    }
}

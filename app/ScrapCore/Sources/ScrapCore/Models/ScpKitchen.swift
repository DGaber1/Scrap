import Foundation

/// Everything a user has: pantry and fridge items, equipment, and dietary
/// restrictions. This is the "My Kitchen" screen's data.
public struct ScpKitchen: Codable, Equatable, Sendable {
    public var pantryItems: [ScpPantryItem]
    public var equipment: [ScpEquipment]
    public var restrictions: Set<ScpDietaryRestriction>

    /// Creates a kitchen. An empty kitchen is valid.
    public init(
        pantryItems: [ScpPantryItem] = [],
        equipment: [ScpEquipment] = [],
        restrictions: Set<ScpDietaryRestriction> = []
    ) {
        self.pantryItems = pantryItems
        self.equipment = equipment
        self.restrictions = restrictions
    }

    /// The matching keys of every ingredient on hand.
    public var ingredientIDs: Set<String> { Set(pantryItems.map { $0.ingredient.id }) }

    /// The IDs of every piece of equipment owned.
    public var equipmentIDs: Set<String> { Set(equipment.map { $0.id }) }
}

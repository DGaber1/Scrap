import Foundation

/// Loads and saves the user's kitchen.
public protocol ScpKitchenRepository: Sendable {
    /// The current kitchen. An empty kitchen is returned, not an error, for a new user.
    func loadKitchen() async throws -> ScpKitchen
    /// Adds one pantry or fridge item.
    func addPantryItem(_ item: ScpPantryItem) async throws
    /// Removes the item with `id`. Removing an unknown ID does nothing.
    func removePantryItem(id: UUID) async throws
    /// Replaces the user's equipment.
    func saveEquipment(_ equipment: [ScpEquipment]) async throws
    /// Replaces the user's dietary restrictions.
    func saveRestrictions(_ restrictions: Set<ScpDietaryRestriction>) async throws
}

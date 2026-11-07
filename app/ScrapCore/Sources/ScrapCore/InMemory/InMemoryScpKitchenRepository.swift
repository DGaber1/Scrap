import Foundation

/// A kitchen repository that keeps everything in memory.
public actor InMemoryScpKitchenRepository: ScpKitchenRepository {
    private var kitchen: ScpKitchen
    private let failure: ScpError?

    /// Creates a repository starting from `kitchen`.
    public init(kitchen: ScpKitchen = ScpKitchen(), failure: ScpError? = nil) {
        self.kitchen = kitchen
        self.failure = failure
    }

    public func loadKitchen() async throws -> ScpKitchen {
        if let failure { throw failure }
        return kitchen
    }

    public func addPantryItem(_ item: ScpPantryItem) async throws {
        if let failure { throw failure }
        kitchen.pantryItems.append(item)
    }

    public func removePantryItem(id: UUID) async throws {
        if let failure { throw failure }
        kitchen.pantryItems.removeAll { $0.id == id }
    }

    public func saveEquipment(_ equipment: [ScpEquipment]) async throws {
        if let failure { throw failure }
        kitchen.equipment = equipment
    }

    public func saveRestrictions(_ restrictions: Set<ScpDietaryRestriction>) async throws {
        if let failure { throw failure }
        kitchen.restrictions = restrictions
    }
}

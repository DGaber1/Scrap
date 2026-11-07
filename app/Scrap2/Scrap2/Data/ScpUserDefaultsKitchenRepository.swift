import Foundation
import ScrapCore

/// Keeps the kitchen on the device between launches. A stand-in until the
/// SwiftData cache and Supabase repository (REQ-D-07) replace it.
actor ScpUserDefaultsKitchenRepository: ScpKitchenRepository {
    private let storageKey: String

    init(storageKey: String = "scrap.kitchen.v1") {
        self.storageKey = storageKey
    }

    func loadKitchen() async throws -> ScpKitchen {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return ScpKitchen() }
        do {
            return try JSONDecoder().decode(ScpKitchen.self, from: data)
        } catch {
            throw ScpError.invalidData
        }
    }

    func addPantryItem(_ item: ScpPantryItem) async throws {
        var kitchen = try await loadKitchen()
        kitchen.pantryItems.append(item)
        try store(kitchen)
    }

    func removePantryItem(id: UUID) async throws {
        var kitchen = try await loadKitchen()
        kitchen.pantryItems.removeAll { $0.id == id }
        try store(kitchen)
    }

    func saveEquipment(_ equipment: [ScpEquipment]) async throws {
        var kitchen = try await loadKitchen()
        kitchen.equipment = equipment
        try store(kitchen)
    }

    func saveRestrictions(_ restrictions: Set<ScpDietaryRestriction>) async throws {
        var kitchen = try await loadKitchen()
        kitchen.restrictions = restrictions
        try store(kitchen)
    }

    private func store(_ kitchen: ScpKitchen) throws {
        do {
            UserDefaults.standard.set(try JSONEncoder().encode(kitchen), forKey: storageKey)
        } catch {
            throw ScpError.invalidData
        }
    }
}

import Foundation
import Observation
import ScrapCore

/// The user's kitchen: pantry, fridge, equipment, and dietary restrictions.
/// One instance is shared by the Home and Kitchen screens.
@MainActor
@Observable
final class ScpKitchenViewModel {
    private(set) var kitchen = ScpKitchen()
    private(set) var error: ScpError?

    private let repository: any ScpKitchenRepository
    private let reminderScheduler: any ScpReminderScheduling

    init(repository: any ScpKitchenRepository, reminderScheduler: any ScpReminderScheduling = ScpNoReminderScheduler()) {
        self.repository = repository
        self.reminderScheduler = reminderScheduler
    }

    /// Items whose expiration date is within the next few days, soonest first.
    var useSoonItems: [ScpPantryItem] {
        kitchen.pantryItems
            .filter { $0.isNearingExpiration() }
            .sorted { ($0.expirationDate ?? .distantFuture) < ($1.expirationDate ?? .distantFuture) }
    }

    /// A string that changes whenever the set of ingredients changes. Screens use it to know when to refresh recipes.
    var ingredientKey: String {
        kitchen.ingredientIDs.sorted().joined(separator: "|")
    }

    /// Items stored in one place (pantry or fridge), in the order they were added.
    func items(in location: ScpStorageLocation) -> [ScpPantryItem] {
        kitchen.pantryItems.filter { $0.location == location }
    }

    func hasEquipment(_ equipment: ScpEquipment) -> Bool {
        kitchen.equipment.contains(equipment)
    }

    func hasRestriction(_ restriction: ScpDietaryRestriction) -> Bool {
        kitchen.restrictions.contains(restriction)
    }

    /// Loads the saved kitchen.
    func load() async {
        await refresh { _ in }
    }

    /// Adds an ingredient to the pantry or fridge. Duplicates are ignored.
    func addIngredient(_ ingredient: ScpIngredient, to location: ScpStorageLocation = .pantry) async {
        guard !kitchen.ingredientIDs.contains(ingredient.id) else { return }
        let item = ScpPantryItem(ingredient: ingredient, location: location)
        await refresh { try await $0.addPantryItem(item) }
    }

    /// Adds an ingredient from free text, for when the user presses return without picking a suggestion.
    func addIngredient(named name: String, to location: ScpStorageLocation = .pantry) async {
        let cleaned = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return }
        await addIngredient(ScpIngredient(name: cleaned), to: location)
    }

    func removeItem(id: UUID) async {
        await refresh { try await $0.removePantryItem(id: id) }
    }

    /// Sets or clears an item's expiration date, and asks for reminder permission the first time a date is set.
    func setExpiration(_ date: Date?, for item: ScpPantryItem) async {
        if date != nil {
            _ = await reminderScheduler.requestPermission()
        }
        var updated = item
        updated.expirationDate = date
        await refresh {
            try await $0.removePantryItem(id: item.id)
            try await $0.addPantryItem(updated)
        }
    }

    /// Moves an item between the pantry and the fridge.
    func move(_ item: ScpPantryItem, to location: ScpStorageLocation) async {
        var moved = item
        moved.location = location
        await refresh {
            try await $0.removePantryItem(id: item.id)
            try await $0.addPantryItem(moved)
        }
    }

    func toggleEquipment(_ equipment: ScpEquipment) async {
        var updated = kitchen.equipment
        if let index = updated.firstIndex(of: equipment) {
            updated.remove(at: index)
        } else {
            updated.append(equipment)
        }
        await refresh { try await $0.saveEquipment(updated) }
    }

    func toggleRestriction(_ restriction: ScpDietaryRestriction) async {
        var updated = kitchen.restrictions
        if updated.contains(restriction) {
            updated.remove(restriction)
        } else {
            updated.insert(restriction)
        }
        await refresh { try await $0.saveRestrictions(updated) }
    }

    /// Runs a change, then reloads the kitchen so the screen matches what was saved.
    private func refresh(_ change: (any ScpKitchenRepository) async throws -> Void) async {
        do {
            try await change(repository)
            kitchen = try await repository.loadKitchen()
            error = nil
            await reminderScheduler.reschedule(for: kitchen.pantryItems)
        } catch {
            self.error = (error as? ScpError) ?? .unknown(String(describing: error))
        }
    }
}

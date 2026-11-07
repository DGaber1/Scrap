import Foundation
import Observation
import ScrapCore

/// The shopping list: check items off, add your own, and add what a recipe is missing.
/// One instance is shared by the Grocery tab and the Recipe Detail screen.
@MainActor
@Observable
final class ScpGroceryListViewModel {
    private(set) var list = ScpGroceryList()
    private(set) var error: ScpError?
    /// Set briefly after items are added so the UI can confirm it.
    private(set) var lastAddedCount: Int?

    private let repository: any ScpGroceryListRepository
    private let builder: ScpGroceryListBuilder

    init(repository: any ScpGroceryListRepository, builder: ScpGroceryListBuilder) {
        self.repository = repository
        self.builder = builder
    }

    var items: [ScpGroceryListItem] { list.items }
    var estimatedTotal: Decimal { list.totalEstimatedCost }
    var recipeCount: Int { list.sourceRecipeCount }
    var checkedItems: [ScpGroceryListItem] { list.items.filter { $0.isChecked } }

    func load() async {
        do {
            list = try await repository.loadList()
            error = nil
        } catch {
            self.error = (error as? ScpError) ?? .unknown(String(describing: error))
        }
    }

    /// Adds everything the recipe needs that the kitchen lacks. Returns how many items the list now holds from this call.
    @discardableResult
    func addMissingItems(of recipe: ScpRecipe, kitchen: ScpKitchen, servings: Int? = nil) async -> Bool {
        do {
            let before = list.items.count
            let updated = try builder.adding(recipe, kitchen: kitchen, servings: servings, to: list)
            lastAddedCount = max(updated.items.count - before, 0)
            await save(updated)
            return error == nil
        } catch {
            self.error = (error as? ScpError) ?? .unknown(String(describing: error))
            return false
        }
    }

    func toggleChecked(id: UUID) async {
        var updated = list
        guard let index = updated.items.firstIndex(where: { $0.id == id }) else { return }
        updated.items[index].isChecked.toggle()
        await save(updated)
    }

    /// Adds a handwritten line such as "paper towels".
    func addManualItem(named name: String) async {
        let cleaned = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return }
        var updated = list
        updated.items.append(
            ScpGroceryListItem(
                ingredient: ScpIngredient(name: cleaned),
                quantity: ScpQuantity(amount: 1, unit: .piece),
                source: .manual
            )
        )
        await save(updated)
    }

    func removeItem(id: UUID) async {
        var updated = list
        updated.items.removeAll { $0.id == id }
        await save(updated)
    }

    /// "Purchased these items": drops everything that was checked off and keeps the rest.
    func finishShopping() async {
        var updated = list
        updated.items.removeAll { $0.isChecked }
        await save(updated)
    }

    /// Clears the whole list.
    func startNewList() async {
        var updated = list
        updated.items = []
        await save(updated)
    }

    /// A plain-text copy of the list for sharing.
    var shareText: String {
        let lines = list.items.map { item -> String in
            let mark = item.isChecked ? "[x]" : "[ ]"
            return "\(mark) \(ScpQuantityFormatter.text(for: item.quantity, name: item.ingredient.name))"
        }
        return (["Scrap grocery list"] + lines).joined(separator: "\n")
    }

    private func save(_ updated: ScpGroceryList) async {
        do {
            try await repository.saveList(updated)
            list = updated
            error = nil
        } catch {
            self.error = (error as? ScpError) ?? .unknown(String(describing: error))
        }
    }
}

import Foundation

/// Loads and saves the user's grocery list.
public protocol ScpGroceryListRepository: Sendable {
    /// The current list. An empty list is returned, not an error, when none exists.
    func loadList() async throws -> ScpGroceryList
    /// Replaces the stored list.
    func saveList(_ list: ScpGroceryList) async throws
}

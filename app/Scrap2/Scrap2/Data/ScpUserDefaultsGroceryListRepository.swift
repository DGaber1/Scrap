import Foundation
import ScrapCore

/// Keeps the grocery list on the device between launches. A stand-in until the
/// Supabase repository (REQ-D-07) replaces it.
actor ScpUserDefaultsGroceryListRepository: ScpGroceryListRepository {
    private let storageKey: String

    init(storageKey: String = "scrap.groceryList.v1") {
        self.storageKey = storageKey
    }

    func loadList() async throws -> ScpGroceryList {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return ScpGroceryList() }
        do {
            return try JSONDecoder().decode(ScpGroceryList.self, from: data)
        } catch {
            throw ScpError.invalidData
        }
    }

    func saveList(_ list: ScpGroceryList) async throws {
        do {
            UserDefaults.standard.set(try JSONEncoder().encode(list), forKey: storageKey)
        } catch {
            throw ScpError.invalidData
        }
    }
}

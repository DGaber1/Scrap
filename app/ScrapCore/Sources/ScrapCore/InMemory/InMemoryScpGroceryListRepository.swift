import Foundation

/// A grocery list repository that keeps the list in memory.
public actor InMemoryScpGroceryListRepository: ScpGroceryListRepository {
    private var list: ScpGroceryList
    private let failure: ScpError?

    /// Creates a repository starting from `list`.
    public init(list: ScpGroceryList = ScpGroceryList(), failure: ScpError? = nil) {
        self.list = list
        self.failure = failure
    }

    public func loadList() async throws -> ScpGroceryList {
        if let failure { throw failure }
        return list
    }

    public func saveList(_ list: ScpGroceryList) async throws {
        if let failure { throw failure }
        self.list = list
    }
}

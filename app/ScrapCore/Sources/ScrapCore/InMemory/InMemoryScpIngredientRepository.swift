import Foundation

/// An ingredient lookup over a fixed list of common ingredients. No network.
public struct InMemoryScpIngredientRepository: ScpIngredientRepository {
    public var ingredients: [ScpIngredient]
    /// When set, every call throws this error.
    public var failure: ScpError?

    /// Creates a repository over `ingredients`.
    public init(ingredients: [ScpIngredient] = ScpSampleData.commonIngredients, failure: ScpError? = nil) {
        self.ingredients = ingredients
        self.failure = failure
    }

    public func searchIngredients(matching query: String) async throws -> [ScpIngredient] {
        if let failure { throw failure }
        let needle = ScpIngredient.normalizedID(for: query)
        guard !needle.isEmpty else { return [] }
        let prefixMatches = ingredients.filter { $0.id.hasPrefix(needle) }
        let otherMatches = ingredients.filter { !$0.id.hasPrefix(needle) && $0.id.contains(needle) }
        return Array((prefixMatches + otherMatches).prefix(6))
    }
}

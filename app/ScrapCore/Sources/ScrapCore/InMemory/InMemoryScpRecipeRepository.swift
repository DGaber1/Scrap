import Foundation

/// A recipe repository that returns fixed recipes and touches no network.
/// For previews, tests, and running the prototype without an API key.
public struct InMemoryScpRecipeRepository: ScpRecipeRepository {
    public var recipes: [ScpRecipe]
    /// When set, every call throws this error.
    public var failure: ScpError?

    /// Creates a repository holding `recipes`.
    public init(recipes: [ScpRecipe] = ScpSampleData.recipes, failure: ScpError? = nil) {
        self.recipes = recipes
        self.failure = failure
    }

    public func searchRecipes(ingredientNames: [String]) async throws -> [ScpRecipe] {
        if let failure { throw failure }
        return recipes
    }

    public func recipe(id: String) async throws -> ScpRecipe {
        if let failure { throw failure }
        guard let match = recipes.first(where: { $0.id == id }) else { throw ScpError.notFound }
        return match
    }
}

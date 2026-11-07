import Foundation
import ScrapCore

/// The one place that creates concrete repositories and clients (REQ-D-06).
/// Everything else receives them through its initializer.
struct ScpAppDependencies {
    let recipeRepository: any ScpRecipeRepository
    let ingredientRepository: any ScpIngredientRepository
    let kitchenRepository: any ScpKitchenRepository
    let groceryListRepository: any ScpGroceryListRepository
    let recipeMatcher: ScpRecipeMatcher
    let groceryListBuilder: ScpGroceryListBuilder
    /// True when recipes come from the real Spoonacular API instead of sample data.
    let usesLiveRecipes: Bool

    /// Uses Spoonacular when `Secrets.plist` holds a key; otherwise sample data,
    /// so the app always runs.
    static func makeDefault() -> ScpAppDependencies {
        guard let config = ScpSecretsLoader.load(), config.hasSpoonacularKey else {
            return makeSample(kitchen: ScpKitchen())
        }
        let client = ScpSpoonacularRecipeClient(config: config)
        return ScpAppDependencies(
            recipeRepository: ScpSpoonacularRecipeRepository(client: client),
            ingredientRepository: ScpSpoonacularIngredientRepository(client: client),
            kitchenRepository: ScpUserDefaultsKitchenRepository(),
            groceryListRepository: ScpUserDefaultsGroceryListRepository(),
            recipeMatcher: ScpRecipeMatcher(),
            groceryListBuilder: ScpGroceryListBuilder(),
            usesLiveRecipes: true
        )
    }

    /// Sample data, for previews.
    static func preview() -> ScpAppDependencies {
        makeSample(kitchen: ScpSampleData.kitchen)
    }

    private static func makeSample(kitchen: ScpKitchen) -> ScpAppDependencies {
        ScpAppDependencies(
            recipeRepository: InMemoryScpRecipeRepository(),
            ingredientRepository: InMemoryScpIngredientRepository(),
            kitchenRepository: InMemoryScpKitchenRepository(kitchen: kitchen),
            groceryListRepository: InMemoryScpGroceryListRepository(),
            recipeMatcher: ScpRecipeMatcher(),
            groceryListBuilder: ScpGroceryListBuilder(),
            usesLiveRecipes: false
        )
    }
}

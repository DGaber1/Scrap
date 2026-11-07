import Foundation

@testable import ScrapCore

/// Small builders shared by the unit tests.
enum ScpTestFixtures {

    static func ingredient(_ name: String) -> ScpIngredient {
        ScpIngredient(name: name)
    }

    static func recipeIngredient(_ name: String, amount: Double = 1, unit: ScpMeasurementUnit = .piece) -> ScpRecipeIngredient {
        ScpRecipeIngredient(ingredient: ingredient(name), quantity: ScpQuantity(amount: amount, unit: unit))
    }

    static func pantryItem(_ name: String) -> ScpPantryItem {
        ScpPantryItem(ingredient: ingredient(name))
    }

    static func kitchen(_ names: String..., equipment: [ScpEquipment] = []) -> ScpKitchen {
        ScpKitchen(pantryItems: names.map { pantryItem($0) }, equipment: equipment)
    }

    static func recipe(
        id: String = "r1",
        title: String = "Recipe",
        ingredients: [String] = [],
        prep: Int = 5,
        cook: Int = 5,
        difficulty: ScpRecipe.Difficulty = .easy,
        servings: Int = 2,
        protein: Double? = nil,
        equipment: [ScpEquipment] = [],
        tags: Set<ScpDietaryRestriction> = []
    ) -> ScpRecipe {
        ScpRecipe(
            id: id,
            title: title,
            ingredients: ingredients.map { recipeIngredient($0) },
            instructions: [],
            prepTimeMinutes: prep,
            cookTimeMinutes: cook,
            difficulty: difficulty,
            servings: servings,
            proteinGramsPerServing: protein,
            requiredEquipment: equipment,
            dietaryTags: tags
        )
    }
}

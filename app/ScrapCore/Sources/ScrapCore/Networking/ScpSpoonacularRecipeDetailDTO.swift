import Foundation

/// Spoonacular's full recipe information response. Every field is optional (REQ-D-22).
struct ScpSpoonacularRecipeDetailDTO: Decodable {

    struct IngredientDTO: Decodable {
        let id: Int?
        let name: String?
        let amount: Double?
        let unit: String?
    }

    struct InstructionGroupDTO: Decodable {
        let steps: [StepDTO]?
    }

    struct StepDTO: Decodable {
        let step: String?
    }

    let id: Int?
    let title: String?
    let image: String?
    let readyInMinutes: Int?
    let servings: Int?
    let vegetarian: Bool?
    let vegan: Bool?
    let glutenFree: Bool?
    let dairyFree: Bool?
    let extendedIngredients: [IngredientDTO]?
    let analyzedInstructions: [InstructionGroupDTO]?

    /// Converts to a ScrapCore model, or `nil` when the response has no ID or title.
    /// Spoonacular gives only a total time, so it is stored as cook time.
    func toRecipe() -> ScpRecipe? {
        guard let id, let title, !title.isEmpty else { return nil }

        let ingredients = (extendedIngredients ?? []).compactMap { dto -> ScpRecipeIngredient? in
            guard let name = dto.name, !name.isEmpty else { return nil }
            return ScpRecipeIngredient(
                ingredient: ScpIngredient(name: name, spoonacularID: dto.id),
                quantity: ScpQuantity(amount: dto.amount ?? 1, unit: ScpMeasurementUnit(spoonacularUnit: dto.unit))
            )
        }

        let steps = (analyzedInstructions ?? [])
            .flatMap { $0.steps ?? [] }
            .compactMap { $0.step }
            .filter { !$0.isEmpty }

        var tags: Set<ScpDietaryRestriction> = []
        if vegetarian == true { tags.insert(.vegetarian) }
        if vegan == true { tags.insert(.vegan) }
        if glutenFree == true { tags.insert(.glutenFree) }
        if dairyFree == true { tags.insert(.dairyFree) }

        return ScpRecipe(
            id: String(id),
            title: title,
            ingredients: ingredients,
            instructions: steps,
            prepTimeMinutes: 0,
            cookTimeMinutes: readyInMinutes ?? 0,
            difficulty: .medium,
            servings: max(servings ?? 1, 1),
            dietaryTags: tags,
            source: .spoonacular,
            imageURL: image.flatMap { URL(string: $0) }
        )
    }
}

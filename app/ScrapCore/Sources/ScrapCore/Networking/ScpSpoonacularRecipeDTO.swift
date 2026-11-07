import Foundation

/// One result of Spoonacular's "find by ingredients" call. Every field except
/// the ID is optional, so a missing field degrades the result instead of
/// failing the whole response (REQ-D-22).
struct ScpSpoonacularRecipeDTO: Decodable {

    struct IngredientDTO: Decodable {
        let id: Int?
        let name: String?
        let amount: Double?
        let unit: String?
    }

    let id: Int?
    let title: String?
    let image: String?
    let usedIngredients: [IngredientDTO]?
    let missedIngredients: [IngredientDTO]?

    /// Converts to a ScrapCore model, or `nil` when the result has no ID or title.
    /// Spoonacular's search call gives no instructions or times; the detail call fills those in.
    func toRecipe() -> ScpRecipe? {
        guard let id, let title, !title.isEmpty else { return nil }
        let all = (usedIngredients ?? []) + (missedIngredients ?? [])
        let ingredients = all.compactMap { dto -> ScpRecipeIngredient? in
            guard let name = dto.name, !name.isEmpty else { return nil }
            return ScpRecipeIngredient(
                ingredient: ScpIngredient(name: name, spoonacularID: dto.id),
                quantity: ScpQuantity(amount: dto.amount ?? 1, unit: ScpMeasurementUnit(spoonacularUnit: dto.unit))
            )
        }
        return ScpRecipe(
            id: String(id),
            title: title,
            ingredients: ingredients,
            instructions: [],
            prepTimeMinutes: 0,
            cookTimeMinutes: 0,
            difficulty: .medium,
            servings: 1,
            source: .spoonacular,
            imageURL: image.flatMap { URL(string: $0) }
        )
    }
}

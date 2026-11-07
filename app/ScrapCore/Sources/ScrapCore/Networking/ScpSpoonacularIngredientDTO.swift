import Foundation

/// One suggestion from Spoonacular's ingredient autocomplete. Fields are optional (REQ-D-22).
struct ScpSpoonacularIngredientDTO: Decodable {
    let id: Int?
    let name: String?

    /// Converts to a ScrapCore model, or `nil` when the name is missing or blank.
    func toIngredient() -> ScpIngredient? {
        guard let name, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        return ScpIngredient(name: name, spoonacularID: id)
    }
}

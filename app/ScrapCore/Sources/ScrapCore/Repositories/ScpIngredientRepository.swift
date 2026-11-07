import Foundation

/// Looks up ingredient names as the user types, so they pick a real
/// ingredient instead of typing a misspelling.
public protocol ScpIngredientRepository: Sendable {
    /// Ingredients whose names match `query`, best matches first.
    /// - Throws: ``ScpError`` for every failure (REQ-D-22).
    func searchIngredients(matching query: String) async throws -> [ScpIngredient]
}

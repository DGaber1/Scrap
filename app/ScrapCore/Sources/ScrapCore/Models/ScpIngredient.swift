import Foundation

/// A canonical ingredient identity.
///
/// Pantry items and recipe ingredients both point at one of these, which is
/// how matching works: two ingredients are "the same" when their `id`s are
/// equal. The `id` is the lowercased, whitespace-collapsed name (see
/// ``normalizedID(for:)``) so "Egg", "egg " and "EGG" all match.
public struct ScpIngredient: Codable, Identifiable, Equatable, Hashable, Sendable {
    public let id: String
    public var name: String
    /// The Spoonacular ingredient ID, when the ingredient came from Spoonacular.
    public var spoonacularID: Int?

    /// Creates an ingredient with an explicit `id`.
    public init(id: String, name: String, spoonacularID: Int? = nil) {
        self.id = id
        self.name = name
        self.spoonacularID = spoonacularID
    }

    /// Creates an ingredient whose `id` is derived from `name`.
    public init(name: String, spoonacularID: Int? = nil) {
        self.init(id: ScpIngredient.normalizedID(for: name), name: name, spoonacularID: spoonacularID)
    }

    /// The matching key for an ingredient name: lowercased, trimmed, and with
    /// repeated whitespace collapsed to a single space.
    public static func normalizedID(for name: String) -> String {
        name.lowercased().split(whereSeparator: { $0.isWhitespace }).joined(separator: " ")
    }
}

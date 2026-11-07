import Foundation

/// Where a recipe came from.
public enum ScpRecipeSource: String, Codable, Hashable, Sendable {
    /// Fetched from the Spoonacular API.
    case spoonacular
    /// Contributed by a Scrap user and approved by an admin.
    case community
}

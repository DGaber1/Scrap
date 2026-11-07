import Foundation

/// A dietary restriction a user can set, or a diet a recipe satisfies.
public enum ScpDietaryRestriction: String, Codable, CaseIterable, Hashable, Sendable {
    case vegetarian
    case vegan
    case glutenFree
    case dairyFree
    case nutFree
}

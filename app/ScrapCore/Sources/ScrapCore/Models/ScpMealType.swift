import Foundation

/// The kind of meal a recipe is for.
public enum ScpMealType: String, Codable, CaseIterable, Hashable, Sendable {
    case breakfast
    case lunch
    case dinner
    case snack
    case dessert
}

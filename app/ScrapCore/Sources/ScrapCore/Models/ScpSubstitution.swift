import Foundation

/// A replacement for a missing ingredient.
public struct ScpSubstitution: Identifiable, Equatable, Sendable {
    public var id: String { "\(original.id)->\(replacement.id)" }
    public let original: ScpIngredient
    public let replacement: ScpIngredient
    /// True when the user already has everything the replacement needs.
    public let isInKitchen: Bool
    /// How much to use, such as "1:1". `nil` when unknown.
    public let ratio: String?

    /// Creates a substitution.
    public init(original: ScpIngredient, replacement: ScpIngredient, isInKitchen: Bool, ratio: String? = nil) {
        self.original = original
        self.replacement = replacement
        self.isInKitchen = isInKitchen
        self.ratio = ratio
    }
}

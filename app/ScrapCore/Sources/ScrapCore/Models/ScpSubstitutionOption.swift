import Foundation

/// One possible swap for an ingredient: what to use instead, how much, and which diets it fits.
public struct ScpSubstitutionOption: Equatable, Sendable {
    /// What to use instead, such as "Greek yogurt" or "Milk and lemon juice".
    public let name: String
    /// How much to use, such as "1:1" or "Use ½ as much".
    public let ratio: String
    /// The dietary needs this swap satisfies. A swap is hidden for a user whose
    /// restrictions are not all in this set.
    public let suitableFor: Set<ScpDietaryRestriction>

    /// Creates an option.
    public init(name: String, ratio: String, suitableFor: Set<ScpDietaryRestriction>) {
        self.name = name
        self.ratio = ratio
        self.suitableFor = suitableFor
    }
}

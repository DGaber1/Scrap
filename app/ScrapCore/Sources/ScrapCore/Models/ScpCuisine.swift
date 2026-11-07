import Foundation

/// The cuisine a recipe belongs to.
public enum ScpCuisine: String, Codable, CaseIterable, Hashable, Sendable {
    case american
    case italian
    case mexican
    case asian
    case indian
    case mediterranean
    case other
}

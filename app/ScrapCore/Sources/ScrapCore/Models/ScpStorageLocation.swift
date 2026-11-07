import Foundation

/// Where an ingredient is kept.
public enum ScpStorageLocation: String, Codable, CaseIterable, Hashable, Sendable {
    /// Non-perishables, frozen items, spices. No expiration date needed.
    case pantry
    /// Perishables, usually added from a receipt, with an estimated expiration date.
    case fridge
}

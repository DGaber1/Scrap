import Foundation

/// One ingredient the user has on hand.
public struct ScpPantryItem: Codable, Identifiable, Equatable, Sendable {
    public let id: UUID
    public var ingredient: ScpIngredient
    public var quantity: ScpQuantity?
    public var location: ScpStorageLocation
    public var expirationDate: Date?
    public var addedAt: Date

    /// Creates a pantry item.
    public init(
        id: UUID = UUID(),
        ingredient: ScpIngredient,
        quantity: ScpQuantity? = nil,
        location: ScpStorageLocation = .pantry,
        expirationDate: Date? = nil,
        addedAt: Date = Date()
    ) {
        self.id = id
        self.ingredient = ingredient
        self.quantity = quantity
        self.location = location
        self.expirationDate = expirationDate
        self.addedAt = addedAt
    }

    /// Whether the item expires within `reminderWindow` seconds of `now`
    /// (default three days). Items without an expiration date never do.
    public func isNearingExpiration(asOf now: Date = Date(), reminderWindow: TimeInterval = 3 * 24 * 60 * 60) -> Bool {
        guard let expirationDate else { return false }
        let remaining = expirationDate.timeIntervalSince(now)
        return remaining >= 0 && remaining <= reminderWindow
    }
}

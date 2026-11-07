import Foundation

/// A signed-in Scrap user account.
public struct ScpUser: Codable, Identifiable, Equatable, Sendable {
    public let id: UUID
    public var email: String
    public var displayName: String
    public var createdAt: Date

    /// Creates a user.
    public init(id: UUID = UUID(), email: String, displayName: String, createdAt: Date = Date()) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.createdAt = createdAt
    }
}

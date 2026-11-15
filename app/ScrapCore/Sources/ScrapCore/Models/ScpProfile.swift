import Foundation

/// The public side of a Scrap account: what friends and the community feed see.
/// A signed-in ``ScpUser`` gets one of these so others can find and befriend them.
public struct ScpProfile: Codable, Identifiable, Equatable, Hashable, Sendable {
    public let id: UUID
    /// The unique handle shown in the app, such as "maya.cooks".
    public var username: String
    public var displayName: String
    /// The equipment this person has said they own (their My Kitchen equipment).
    public var equipment: [ScpEquipment]
    /// Rough distance from the viewer in miles, for "0.4 mi away".
    /// Only sample data sets this until location is wired up.
    public var distanceMiles: Double?

    /// Creates a profile.
    public init(
        id: UUID = UUID(),
        username: String,
        displayName: String,
        equipment: [ScpEquipment] = [],
        distanceMiles: Double? = nil
    ) {
        self.id = id
        self.username = username
        self.displayName = displayName
        self.equipment = equipment
        self.distanceMiles = distanceMiles
    }

    /// Creates the profile for a signed-in user, deriving a username from their name or email.
    public init(user: ScpUser, equipment: [ScpEquipment] = []) {
        self.init(
            id: user.id,
            username: ScpProfile.username(from: user.displayName.isEmpty ? user.email : user.displayName),
            displayName: user.displayName,
            equipment: equipment
        )
    }

    /// Whether this person owns `item`.
    public func owns(_ item: ScpEquipment) -> Bool {
        equipment.contains { $0.id == item.id }
    }

    /// The link a user shares to invite friends, such as `https://scrap.app/u/deanna.g`.
    public var inviteLink: URL? {
        URL(string: "https://scrap.app/u/\(username)")
    }

    /// Turns a display name or an email into a username: lowercased, spaces become
    /// dots, and only letters, digits, dots, and underscores are kept.
    /// For an email, only the part before "@" is used. Never returns an empty string.
    public static func username(from text: String) -> String {
        let base = text.split(separator: "@").first.map(String.init) ?? text
        let allowed = Set("abcdefghijklmnopqrstuvwxyz0123456789._")
        let words = base.lowercased().split(whereSeparator: { $0.isWhitespace })
        let cleaned = String(words.joined(separator: ".").filter { allowed.contains($0) })
        let trimmed = cleaned.trimmingCharacters(in: CharacterSet(charactersIn: "._"))
        return trimmed.isEmpty ? "scrapper" : trimmed
    }
}

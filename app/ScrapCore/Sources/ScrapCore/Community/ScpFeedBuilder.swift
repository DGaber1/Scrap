import Foundation

/// Which tab of the community feed is showing.
public enum ScpFeedScope: String, CaseIterable, Sendable {
    /// Public posts from everyone, plus friends-only posts from your friends.
    case forYou
    /// Only posts from your friends (and you). Needs an account.
    case friends
}

/// Decides which posts a viewer may see and in what order (REQ-F-16, REQ-F-17).
/// Pure logic, so the visibility rules are testable without the app.
public struct ScpFeedBuilder: Sendable {

    /// Creates a builder.
    public init() {}

    /// The posts to show, newest first.
    ///
    /// - A post is visible when the viewer wrote it, it is public, or it is
    ///   friends-only and the viewer is friends with the author.
    /// - Posts the viewer reported are hidden from them.
    /// - Guests (`viewerID == nil`) see public posts on For You and nothing on Friends.
    public func posts(
        _ all: [ScpPost],
        scope: ScpFeedScope,
        viewerID: UUID?,
        friendIDs: Set<UUID>
    ) -> [ScpPost] {
        let visible = all.filter { isVisible($0, to: viewerID, friendIDs: friendIDs) }
        let scoped: [ScpPost]
        switch scope {
        case .forYou:
            scoped = visible
        case .friends:
            guard let viewerID else { return [] }
            scoped = visible.filter { $0.authorID == viewerID || friendIDs.contains($0.authorID) }
        }
        return scoped.sorted { $0.createdAt > $1.createdAt }
    }

    /// Whether `viewerID` may see `post` at all.
    public func isVisible(_ post: ScpPost, to viewerID: UUID?, friendIDs: Set<UUID>) -> Bool {
        if let viewerID, post.reportedBy.contains(viewerID) { return false }
        if let viewerID, post.authorID == viewerID { return true }
        switch post.visibility {
        case .everyone: return true
        case .friends: return viewerID != nil && friendIDs.contains(post.authorID)
        }
    }
}

/// Finds which friends could lend a piece of equipment.
public struct ScpBorrowFinder: Sendable {

    /// Creates a finder.
    public init() {}

    /// Friends who own `equipment`, closest first. Friends with no known distance come last,
    /// in username order.
    public func lenders(of equipment: ScpEquipment, among friends: [ScpProfile]) -> [ScpProfile] {
        friends
            .filter { $0.owns(equipment) }
            .sorted { lhs, rhs in
                switch (lhs.distanceMiles, rhs.distanceMiles) {
                case let (left?, right?) where left != right:
                    return left < right
                case (.some, .none):
                    return true
                case (.none, .some):
                    return false
                default:
                    return lhs.username < rhs.username
                }
            }
    }
}

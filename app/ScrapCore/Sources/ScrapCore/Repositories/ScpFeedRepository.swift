import Foundation

/// Posts in the community feed (REQ-F-16, REQ-F-17).
/// Which posts a viewer sees is decided by ``ScpFeedBuilder``, not here.
public protocol ScpFeedRepository: Sendable {
    /// Every stored post, in no particular order.
    func allPosts() async throws -> [ScpPost]
    /// Adds a new post.
    func publish(_ post: ScpPost) async throws
    /// Likes or unlikes a post and returns the updated post.
    func setLiked(_ isLiked: Bool, postID: UUID, by userID: UUID) async throws -> ScpPost
    /// Saves or unsaves a post and returns the updated post.
    func setSaved(_ isSaved: Bool, postID: UUID, by userID: UUID) async throws -> ScpPost
    /// Adds a comment and returns the updated post.
    func addComment(_ comment: ScpComment, toPost postID: UUID) async throws -> ScpPost
    /// Reports a post for review. It stays hidden from the reporter.
    func report(postID: UUID, by userID: UUID) async throws
}

/// Profiles, friendships, friend requests, and equipment borrowing.
public protocol ScpFriendsRepository: Sendable {
    /// Creates or updates the signed-in user's public profile.
    func register(_ profile: ScpProfile) async throws
    /// Everyone this repository knows about, for search and showing post authors.
    func allProfiles() async throws -> [ScpProfile]
    /// The user's friends.
    func friends(of userID: UUID) async throws -> [ScpProfile]
    /// People who asked to be the user's friend.
    func incomingRequests(for userID: UUID) async throws -> [ScpProfile]
    /// IDs of people the user has asked to be friends with.
    func outgoingRequests(from userID: UUID) async throws -> Set<UUID>
    /// Sends a friend request.
    func sendRequest(from senderID: UUID, to receiverID: UUID) async throws
    /// Accepts a request, making both people friends.
    func acceptRequest(from senderID: UUID, to receiverID: UUID) async throws
    /// Declines a request.
    func declineRequest(from senderID: UUID, to receiverID: UUID) async throws
    /// Asks a friend to lend a piece of equipment.
    func requestToBorrow(_ request: ScpBorrowRequest) async throws
    /// Borrow requests the user has sent.
    func borrowRequests(from userID: UUID) async throws -> [ScpBorrowRequest]
}

import Foundation

/// A friends repository that keeps everything in memory.
///
/// The first time a user registers, they get a few sample friends and two
/// incoming friend requests, so the Friends screens have something to show.
public actor InMemoryScpFriendsRepository: ScpFriendsRepository {
    private var profiles: [UUID: ScpProfile]
    /// Each person's friends. Always stored in both directions.
    private var friendIDs: [UUID: Set<UUID>]
    /// Receiver ID → IDs of people who asked to be their friend.
    private var requests: [UUID: Set<UUID>]
    private var borrowRequests: [ScpBorrowRequest] = []
    private var seededUserIDs: Set<UUID> = []
    private let starterFriendIDs: [UUID]
    private let starterRequesterIDs: [UUID]
    private let failure: ScpError?

    /// Creates a repository holding the sample community.
    public init(
        profiles: [ScpProfile] = ScpSampleCommunity.profiles,
        friendships: [(UUID, UUID)] = ScpSampleCommunity.friendships,
        starterFriendIDs: [UUID] = ScpSampleCommunity.starterFriendIDs,
        starterRequesterIDs: [UUID] = ScpSampleCommunity.starterRequesterIDs,
        failure: ScpError? = nil
    ) {
        var byID: [UUID: ScpProfile] = [:]
        for profile in profiles { byID[profile.id] = profile }
        var friends: [UUID: Set<UUID>] = [:]
        for (first, second) in friendships {
            friends[first, default: []].insert(second)
            friends[second, default: []].insert(first)
        }
        self.profiles = byID
        self.friendIDs = friends
        self.requests = [:]
        self.starterFriendIDs = starterFriendIDs
        self.starterRequesterIDs = starterRequesterIDs
        self.failure = failure
    }

    public func register(_ profile: ScpProfile) async throws {
        if let failure { throw failure }
        profiles[profile.id] = profile
        guard !seededUserIDs.contains(profile.id) else { return }
        seededUserIDs.insert(profile.id)
        for friendID in starterFriendIDs where friendID != profile.id {
            befriend(profile.id, friendID)
        }
        for requesterID in starterRequesterIDs where requesterID != profile.id {
            if !(friendIDs[profile.id]?.contains(requesterID) ?? false) {
                requests[profile.id, default: []].insert(requesterID)
            }
        }
    }

    public func allProfiles() async throws -> [ScpProfile] {
        if let failure { throw failure }
        return profiles.values.sorted { $0.username < $1.username }
    }

    public func friends(of userID: UUID) async throws -> [ScpProfile] {
        if let failure { throw failure }
        return lookUp(friendIDs[userID] ?? [])
    }

    public func incomingRequests(for userID: UUID) async throws -> [ScpProfile] {
        if let failure { throw failure }
        return lookUp(requests[userID] ?? [])
    }

    public func outgoingRequests(from userID: UUID) async throws -> Set<UUID> {
        if let failure { throw failure }
        return Set(requests.filter { $0.value.contains(userID) }.keys)
    }

    public func sendRequest(from senderID: UUID, to receiverID: UUID) async throws {
        if let failure { throw failure }
        guard senderID != receiverID, profiles[receiverID] != nil else { throw ScpError.invalidInput }
        guard !(friendIDs[senderID]?.contains(receiverID) ?? false) else { return }
        // If they already asked you, sending one back makes you friends.
        if requests[senderID]?.contains(receiverID) ?? false {
            requests[senderID]?.remove(receiverID)
            befriend(senderID, receiverID)
            return
        }
        requests[receiverID, default: []].insert(senderID)
    }

    public func acceptRequest(from senderID: UUID, to receiverID: UUID) async throws {
        if let failure { throw failure }
        guard requests[receiverID]?.remove(senderID) != nil else { throw ScpError.notFound }
        befriend(senderID, receiverID)
    }

    public func declineRequest(from senderID: UUID, to receiverID: UUID) async throws {
        if let failure { throw failure }
        requests[receiverID]?.remove(senderID)
    }

    public func requestToBorrow(_ request: ScpBorrowRequest) async throws {
        if let failure { throw failure }
        guard friendIDs[request.requesterID]?.contains(request.lenderID) ?? false else {
            throw ScpError.unauthorized
        }
        borrowRequests.append(request)
    }

    public func borrowRequests(from userID: UUID) async throws -> [ScpBorrowRequest] {
        if let failure { throw failure }
        return borrowRequests.filter { $0.requesterID == userID }
    }

    private func befriend(_ first: UUID, _ second: UUID) {
        friendIDs[first, default: []].insert(second)
        friendIDs[second, default: []].insert(first)
    }

    private func lookUp(_ ids: Set<UUID>) -> [ScpProfile] {
        ids.compactMap { profiles[$0] }.sorted { $0.username < $1.username }
    }
}

import Foundation
import Observation
import ScrapCore

/// Your friends, friend requests, finding people, and borrowing equipment from friends.
/// One instance is shared by the Community tab and Recipe Detail (for "Ask to borrow").
@MainActor
@Observable
final class ScpFriendsViewModel {

    /// How the signed-in user is connected to someone.
    enum Relationship {
        case me, friend, requestedByYou, requestedYou, none
    }

    /// Your own public profile. Nil for guests.
    private(set) var me: ScpProfile?
    private(set) var friends: [ScpProfile] = []
    private(set) var requests: [ScpProfile] = []
    private(set) var isLoading = false
    private(set) var error: ScpError?
    private var directory: [ScpProfile] = []
    private var outgoingIDs: Set<UUID> = []
    private var borrowKeys: Set<String> = []

    private let repository: any ScpFriendsRepository
    private let borrowFinder: ScpBorrowFinder

    init(repository: any ScpFriendsRepository, borrowFinder: ScpBorrowFinder = ScpBorrowFinder()) {
        self.repository = repository
        self.borrowFinder = borrowFinder
    }

    var friendIDs: Set<UUID> { Set(friends.map(\.id)) }

    /// Every known person, by ID, for showing post authors.
    var profilesByID: [UUID: ScpProfile] {
        var byID: [UUID: ScpProfile] = [:]
        for profile in directory { byID[profile.id] = profile }
        if let me { byID[me.id] = me }
        return byID
    }

    /// Registers your profile (with your current equipment) and loads your friends.
    /// Clears everything for guests.
    func load(user: ScpUser?, equipment: [ScpEquipment]) async {
        guard let user else {
            me = nil
            friends = []
            requests = []
            outgoingIDs = []
            borrowKeys = []
            directory = (try? await repository.allProfiles()) ?? []
            return
        }
        isLoading = true
        defer { isLoading = false }
        let profile = ScpProfile(user: user, equipment: equipment)
        do {
            try await repository.register(profile)
            me = profile
            try await refresh(for: profile.id)
            let borrows = try await repository.borrowRequests(from: profile.id)
            borrowKeys = Set(borrows.map { Self.borrowKey($0.equipment, lenderID: $0.lenderID) })
            error = nil
        } catch {
            self.error = (error as? ScpError) ?? .unknown(String(describing: error))
        }
    }

    func relationship(with profile: ScpProfile) -> Relationship {
        if profile.id == me?.id { return .me }
        if friendIDs.contains(profile.id) { return .friend }
        if outgoingIDs.contains(profile.id) { return .requestedByYou }
        if requests.contains(where: { $0.id == profile.id }) { return .requestedYou }
        return .none
    }

    /// People whose username or name contains `query`, excluding yourself.
    func search(_ query: String) -> [ScpProfile] {
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !needle.isEmpty else { return [] }
        return directory.filter { profile in
            profile.id != me?.id
                && (profile.username.lowercased().contains(needle) || profile.displayName.lowercased().contains(needle))
        }
    }

    func accept(_ profile: ScpProfile) async {
        await change { me in try await self.repository.acceptRequest(from: profile.id, to: me) }
    }

    func decline(_ profile: ScpProfile) async {
        await change { me in try await self.repository.declineRequest(from: profile.id, to: me) }
    }

    func sendRequest(to profile: ScpProfile) async {
        await change { me in try await self.repository.sendRequest(from: me, to: profile.id) }
    }

    /// Friends who own `equipment`, closest first.
    func lenders(of equipment: ScpEquipment) -> [ScpProfile] {
        borrowFinder.lenders(of: equipment, among: friends)
    }

    func hasAskedToBorrow(_ equipment: ScpEquipment, from lender: ScpProfile) -> Bool {
        borrowKeys.contains(Self.borrowKey(equipment, lenderID: lender.id))
    }

    /// Sends a borrow request. Returns true when it was sent.
    @discardableResult
    func askToBorrow(_ equipment: ScpEquipment, from lender: ScpProfile, recipeTitle: String) async -> Bool {
        guard let me else { return false }
        let request = ScpBorrowRequest(
            equipment: equipment,
            lenderID: lender.id,
            requesterID: me.id,
            recipeTitle: recipeTitle
        )
        do {
            try await repository.requestToBorrow(request)
            borrowKeys.insert(Self.borrowKey(equipment, lenderID: lender.id))
            error = nil
            return true
        } catch {
            self.error = (error as? ScpError) ?? .unknown(String(describing: error))
            return false
        }
    }

    private func change(_ action: (UUID) async throws -> Void) async {
        guard let me else { return }
        do {
            try await action(me.id)
            try await refresh(for: me.id)
            error = nil
        } catch {
            self.error = (error as? ScpError) ?? .unknown(String(describing: error))
        }
    }

    private func refresh(for userID: UUID) async throws {
        friends = try await repository.friends(of: userID)
        requests = try await repository.incomingRequests(for: userID)
        outgoingIDs = try await repository.outgoingRequests(from: userID)
        directory = try await repository.allProfiles()
    }

    private static func borrowKey(_ equipment: ScpEquipment, lenderID: UUID) -> String {
        "\(lenderID.uuidString)|\(equipment.id)"
    }
}

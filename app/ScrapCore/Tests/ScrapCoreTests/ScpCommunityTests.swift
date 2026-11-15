import XCTest

@testable import ScrapCore

final class ScpFeedBuilderTests: XCTestCase {
    private let builder = ScpFeedBuilder()
    private let viewer = UUID()
    private let friend = UUID()
    private let stranger = UUID()
    private let now = Date()

    private func post(by author: UUID, _ visibility: ScpPostVisibility, hoursAgo: Double = 1) -> ScpPost {
        ScpPost(
            authorID: author,
            caption: "Dinner",
            visibility: visibility,
            createdAt: now.addingTimeInterval(-hoursAgo * 3600)
        )
    }

    func test_posts_forGuestOnForYou_showsOnlyPublicPosts() {
        let posts = [post(by: friend, .friends), post(by: stranger, .everyone)]

        let shown = builder.posts(posts, scope: .forYou, viewerID: nil, friendIDs: [])

        XCTAssertEqual(shown.map(\.authorID), [stranger])
    }

    func test_posts_forGuestOnFriends_isEmpty() {
        let shown = builder.posts([post(by: stranger, .everyone)], scope: .friends, viewerID: nil, friendIDs: [])

        XCTAssertTrue(shown.isEmpty)
    }

    func test_posts_friendsOnlyPost_visibleToFriendsButNotStrangers() {
        let friendsOnly = post(by: friend, .friends)

        XCTAssertTrue(builder.isVisible(friendsOnly, to: viewer, friendIDs: [friend]))
        XCTAssertFalse(builder.isVisible(friendsOnly, to: viewer, friendIDs: []))
    }

    func test_posts_onFriendsScope_excludesPublicPostsFromStrangers() {
        let posts = [post(by: friend, .everyone), post(by: stranger, .everyone), post(by: viewer, .friends)]

        let shown = builder.posts(posts, scope: .friends, viewerID: viewer, friendIDs: [friend])

        XCTAssertEqual(Set(shown.map(\.authorID)), [friend, viewer])
    }

    func test_posts_whenViewerReportedPost_hidesIt() {
        var reported = post(by: stranger, .everyone)
        reported.reportedBy = [viewer]

        let shown = builder.posts([reported], scope: .forYou, viewerID: viewer, friendIDs: [])

        XCTAssertTrue(shown.isEmpty)
    }

    func test_posts_sortsNewestFirst() {
        let older = post(by: stranger, .everyone, hoursAgo: 5)
        let newer = post(by: stranger, .everyone, hoursAgo: 1)

        let shown = builder.posts([older, newer], scope: .forYou, viewerID: nil, friendIDs: [])

        XCTAssertEqual(shown.map(\.id), [newer.id, older.id])
    }
}

final class ScpBorrowFinderTests: XCTestCase {
    func test_lenders_returnsOwnersClosestFirstWithUnknownDistanceLast() {
        let far = ScpProfile(username: "far", displayName: "Far", equipment: [.airFryer], distanceMiles: 2)
        let near = ScpProfile(username: "near", displayName: "Near", equipment: [.airFryer], distanceMiles: 0.4)
        let unknown = ScpProfile(username: "unknown", displayName: "Unknown", equipment: [.airFryer])
        let noFryer = ScpProfile(username: "none", displayName: "None", equipment: [.blender], distanceMiles: 0.1)

        let lenders = ScpBorrowFinder().lenders(of: .airFryer, among: [far, unknown, noFryer, near])

        XCTAssertEqual(lenders.map(\.username), ["near", "far", "unknown"])
    }
}

final class ScpProfileTests: XCTestCase {
    func test_username_fromEmail_usesPartBeforeAt() {
        XCTAssertEqual(ScpProfile.username(from: "Deanna.G@stevens.edu"), "deanna.g")
    }

    func test_username_fromName_joinsWordsWithDots() {
        XCTAssertEqual(ScpProfile.username(from: "Sam  Eats!"), "sam.eats")
    }

    func test_username_whenNothingUsable_fallsBack() {
        XCTAssertEqual(ScpProfile.username(from: "!!!"), "scrapper")
    }

    func test_inviteLink_containsUsername() {
        let profile = ScpProfile(username: "deanna.g", displayName: "Deanna")

        XCTAssertEqual(profile.inviteLink?.absoluteString, "https://scrap.app/u/deanna.g")
    }
}

final class InMemoryScpCommunityRepositoryTests: XCTestCase {
    private let me = ScpProfile(username: "me", displayName: "Me")

    func test_register_seedsStarterFriendsAndRequests() async throws {
        let repository = InMemoryScpFriendsRepository()

        try await repository.register(me)

        let friends = try await repository.friends(of: me.id)
        let requests = try await repository.incomingRequests(for: me.id)
        XCTAssertEqual(Set(friends.map(\.id)), Set(ScpSampleCommunity.starterFriendIDs))
        XCTAssertEqual(Set(requests.map(\.id)), Set(ScpSampleCommunity.starterRequesterIDs))
    }

    func test_acceptRequest_makesBothPeopleFriends() async throws {
        let repository = InMemoryScpFriendsRepository()
        try await repository.register(me)
        let maya = ScpSampleCommunity.maya

        try await repository.acceptRequest(from: maya.id, to: me.id)

        let myFriends = try await repository.friends(of: me.id)
        let mayasFriends = try await repository.friends(of: maya.id)
        let requests = try await repository.incomingRequests(for: me.id)
        XCTAssertTrue(myFriends.contains { $0.id == maya.id })
        XCTAssertTrue(mayasFriends.contains { $0.id == me.id })
        XCTAssertFalse(requests.contains { $0.id == maya.id })
    }

    func test_sendRequest_showsAsOutgoing() async throws {
        let repository = InMemoryScpFriendsRepository()
        try await repository.register(me)
        let nina = ScpSampleCommunity.nina

        try await repository.sendRequest(from: me.id, to: nina.id)

        let outgoing = try await repository.outgoingRequests(from: me.id)
        XCTAssertEqual(outgoing, [nina.id])
    }

    func test_requestToBorrow_fromNonFriend_isRejected() async throws {
        let repository = InMemoryScpFriendsRepository()
        try await repository.register(me)
        let request = ScpBorrowRequest(
            equipment: .airFryer,
            lenderID: ScpSampleCommunity.nina.id,
            requesterID: me.id,
            recipeTitle: "Garlic chicken"
        )

        do {
            try await repository.requestToBorrow(request)
            XCTFail("Borrowing from a non-friend should throw")
        } catch {
            XCTAssertEqual(error as? ScpError, .unauthorized)
        }
    }

    func test_feed_likeAndComment_updatePost() async throws {
        let repository = InMemoryScpFeedRepository()
        let post = try await repository.allPosts()[0]

        let liked = try await repository.setLiked(true, postID: post.id, by: me.id)
        let commented = try await repository.addComment(ScpComment(authorID: me.id, text: "  Looks great  "), toPost: post.id)

        XCTAssertEqual(liked.likeCount, post.likeCount + 1)
        XCTAssertTrue(liked.isLiked(by: me.id))
        XCTAssertEqual(commented.comments.last?.text, "Looks great")
    }

    func test_feed_emptyComment_isRejected() async throws {
        let repository = InMemoryScpFeedRepository()
        let post = try await repository.allPosts()[0]

        do {
            _ = try await repository.addComment(ScpComment(authorID: me.id, text: "   "), toPost: post.id)
            XCTFail("An empty comment should throw")
        } catch {
            XCTAssertEqual(error as? ScpError, .invalidInput)
        }
    }
}

import Foundation
import Observation
import ScrapCore

/// The community feed: For You and Friends, likes, saves, comments, reports, and new posts.
/// Which posts show is decided by ``ScpFeedBuilder`` in ScrapCore (REQ-D-01).
@MainActor
@Observable
final class ScpFeedViewModel {
    private(set) var state: ScpViewState<[ScpPost]> = .idle
    private(set) var scope: ScpFeedScope = .forYou
    /// Text in the search bar. Filters by caption, username, or recipe name.
    private(set) var searchText = ""
    /// A short message such as "Thanks, we'll review it." Cleared by the view.
    var notice: String?
    private(set) var publishError: ScpError?

    private var allPosts: [ScpPost] = []
    private var viewerID: UUID?
    private var friendIDs: Set<UUID> = []
    private var profiles: [UUID: ScpProfile] = [:]

    private let repository: any ScpFeedRepository
    private let builder: ScpFeedBuilder

    init(repository: any ScpFeedRepository, builder: ScpFeedBuilder = ScpFeedBuilder()) {
        self.repository = repository
        self.builder = builder
    }

    /// The signed-in viewer's ID, or nil for guests.
    var currentViewerID: UUID? { viewerID }

    /// The author of `post`, if known.
    func author(of post: ScpPost) -> ScpProfile? {
        profiles[post.authorID]
    }

    func profile(id: UUID) -> ScpProfile? {
        profiles[id]
    }

    /// The latest copy of a post, for sheets that stay open while it changes.
    func post(id: UUID) -> ScpPost? {
        allPosts.first { $0.id == id }
    }

    /// Posts by one person that the viewer may see, newest first.
    func posts(by authorID: UUID) -> [ScpPost] {
        builder.posts(allPosts, scope: .forYou, viewerID: viewerID, friendIDs: friendIDs)
            .filter { $0.authorID == authorID }
    }

    /// Loads every post, then shows the ones this viewer may see.
    func load(viewerID: UUID?, friendIDs: Set<UUID>, profiles: [UUID: ScpProfile]) async {
        self.viewerID = viewerID
        self.friendIDs = friendIDs
        self.profiles = profiles
        if viewerID == nil, scope == .friends { scope = .forYou }
        if case .loaded = state {} else { state = .loading }
        do {
            allPosts = try await repository.allPosts()
            rebuild()
        } catch {
            state = .failed((error as? ScpError) ?? .unknown(String(describing: error)))
        }
    }

    /// Re-filters after friends change, without reloading posts.
    func updateFriends(_ ids: Set<UUID>, profiles: [UUID: ScpProfile]) {
        friendIDs = ids
        self.profiles = profiles
        rebuild()
    }

    func select(_ newScope: ScpFeedScope) {
        scope = newScope
        rebuild()
    }

    func search(_ text: String) {
        searchText = text
        rebuild()
    }

    func toggleLike(_ post: ScpPost) async {
        guard let viewerID else { return }
        let makeLiked = !post.isLiked(by: viewerID)
        await update { try await $0.setLiked(makeLiked, postID: post.id, by: viewerID) }
    }

    func toggleSave(_ post: ScpPost) async {
        guard let viewerID else { return }
        let makeSaved = !post.isSaved(by: viewerID)
        await update { try await $0.setSaved(makeSaved, postID: post.id, by: viewerID) }
        if makeSaved { notice = String(localized: "Saved. Find it again on the poster's profile.") }
    }

    /// Adds a comment. Returns true when it was posted.
    @discardableResult
    func addComment(_ text: String, to post: ScpPost) async -> Bool {
        guard let viewerID else { return false }
        let comment = ScpComment(authorID: viewerID, text: text)
        return await update { try await $0.addComment(comment, toPost: post.id) }
    }

    func report(_ post: ScpPost) async {
        guard let viewerID else { return }
        do {
            try await repository.report(postID: post.id, by: viewerID)
            if let index = allPosts.firstIndex(where: { $0.id == post.id }) {
                allPosts[index].reportedBy.insert(viewerID)
            }
            notice = String(localized: "Thanks for reporting. We'll review this post.")
            rebuild()
        } catch {
            notice = (error as? ScpError)?.userMessage ?? String(localized: "Something went wrong. Please try again.")
        }
    }

    /// Publishes a new post. Needs a photo or a caption. Returns true when it was posted.
    func publish(
        caption: String,
        photos: [ScpPostPhoto],
        linkedRecipe: ScpRecipe?,
        ownRecipeTitle: String?,
        visibility: ScpPostVisibility
    ) async -> Bool {
        guard let viewerID else { return false }
        let text = caption.trimmingCharacters(in: .whitespacesAndNewlines)
        let ownTitle = ownRecipeTitle?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty || !photos.isEmpty else {
            publishError = .invalidInput
            return false
        }
        let post = ScpPost(
            authorID: viewerID,
            caption: text,
            photos: photos,
            linkedRecipe: linkedRecipe,
            ownRecipeTitle: (ownTitle?.isEmpty ?? true) ? nil : ownTitle,
            visibility: visibility
        )
        do {
            try await repository.publish(post)
            allPosts.append(post)
            publishError = nil
            rebuild()
            return true
        } catch {
            publishError = (error as? ScpError) ?? .unknown(String(describing: error))
            return false
        }
    }

    func clearPublishError() {
        publishError = nil
    }

    @discardableResult
    private func update(_ change: (any ScpFeedRepository) async throws -> ScpPost) async -> Bool {
        do {
            let updated = try await change(repository)
            if let index = allPosts.firstIndex(where: { $0.id == updated.id }) {
                allPosts[index] = updated
            }
            rebuild()
            return true
        } catch {
            notice = (error as? ScpError)?.userMessage ?? String(localized: "Something went wrong. Please try again.")
            return false
        }
    }

    private func rebuild() {
        var posts = builder.posts(allPosts, scope: scope, viewerID: viewerID, friendIDs: friendIDs)
        let needle = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !needle.isEmpty {
            posts = posts.filter { post in
                post.caption.lowercased().contains(needle)
                    || (profiles[post.authorID]?.username.lowercased().contains(needle) ?? false)
                    || (post.linkedRecipe?.title.lowercased().contains(needle) ?? false)
                    || (post.ownRecipeTitle?.lowercased().contains(needle) ?? false)
            }
        }
        state = posts.isEmpty ? .empty : .loaded(posts)
    }
}

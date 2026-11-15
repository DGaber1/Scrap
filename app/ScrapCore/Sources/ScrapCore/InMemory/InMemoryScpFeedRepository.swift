import Foundation

/// A feed repository that keeps posts in memory. Starts with sample posts.
public actor InMemoryScpFeedRepository: ScpFeedRepository {
    private var posts: [ScpPost]
    private let failure: ScpError?

    /// Creates a repository. Pass `failure` to make every call throw it.
    public init(posts: [ScpPost] = ScpSampleCommunity.posts(), failure: ScpError? = nil) {
        self.posts = posts
        self.failure = failure
    }

    public func allPosts() async throws -> [ScpPost] {
        if let failure { throw failure }
        return posts
    }

    public func publish(_ post: ScpPost) async throws {
        if let failure { throw failure }
        posts.append(post)
    }

    public func setLiked(_ isLiked: Bool, postID: UUID, by userID: UUID) async throws -> ScpPost {
        try update(postID) { post in
            if isLiked { post.likedBy.insert(userID) } else { post.likedBy.remove(userID) }
        }
    }

    public func setSaved(_ isSaved: Bool, postID: UUID, by userID: UUID) async throws -> ScpPost {
        try update(postID) { post in
            if isSaved { post.savedBy.insert(userID) } else { post.savedBy.remove(userID) }
        }
    }

    public func addComment(_ comment: ScpComment, toPost postID: UUID) async throws -> ScpPost {
        let text = comment.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { throw ScpError.invalidInput }
        return try update(postID) { post in
            var cleaned = comment
            cleaned.text = text
            post.comments.append(cleaned)
        }
    }

    public func report(postID: UUID, by userID: UUID) async throws {
        _ = try update(postID) { post in
            post.reportedBy.insert(userID)
        }
    }

    private func update(_ postID: UUID, _ change: (inout ScpPost) -> Void) throws -> ScpPost {
        if let failure { throw failure }
        guard let index = posts.firstIndex(where: { $0.id == postID }) else { throw ScpError.notFound }
        change(&posts[index])
        return posts[index]
    }
}

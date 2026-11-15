import Foundation

/// Who can see a post (UC-10).
public enum ScpPostVisibility: String, Codable, CaseIterable, Sendable {
    /// Only the author's friends.
    case friends
    /// Anyone using Scrap, including guests.
    case everyone
}

/// One photo on a post.
public enum ScpPostPhoto: Codable, Equatable, Sendable {
    /// A photo hosted online.
    case remote(URL)
    /// A photo the user picked on this device (JPEG or PNG bytes).
    case data(Data)
    /// A named stand-in used by sample data. The app decides how to draw it.
    case placeholder(String)
}

/// A comment on a post.
public struct ScpComment: Codable, Identifiable, Equatable, Sendable {
    public let id: UUID
    public var authorID: UUID
    public var text: String
    public var createdAt: Date

    /// Creates a comment.
    public init(id: UUID = UUID(), authorID: UUID, text: String, createdAt: Date = Date()) {
        self.id = id
        self.authorID = authorID
        self.text = text
        self.createdAt = createdAt
    }
}

/// A dish someone cooked and shared to the community feed (REQ-F-16).
public struct ScpPost: Codable, Identifiable, Equatable, Sendable {
    public let id: UUID
    public var authorID: UUID
    public var caption: String
    public var photos: [ScpPostPhoto]
    /// The Scrap recipe the author made, if they linked one.
    public var linkedRecipe: ScpRecipe?
    /// The name of the author's own recipe, when it is not a Scrap recipe.
    public var ownRecipeTitle: String?
    public var visibility: ScpPostVisibility
    public var createdAt: Date
    public var likedBy: Set<UUID>
    public var savedBy: Set<UUID>
    public var comments: [ScpComment]
    /// Users who reported this post (REQ-F-17). Reported posts are hidden from the reporter.
    public var reportedBy: Set<UUID>
    /// Likes from people outside this device's data, so sample posts look lived-in.
    public var baseLikeCount: Int

    /// Creates a post.
    public init(
        id: UUID = UUID(),
        authorID: UUID,
        caption: String,
        photos: [ScpPostPhoto] = [],
        linkedRecipe: ScpRecipe? = nil,
        ownRecipeTitle: String? = nil,
        visibility: ScpPostVisibility = .friends,
        createdAt: Date = Date(),
        likedBy: Set<UUID> = [],
        savedBy: Set<UUID> = [],
        comments: [ScpComment] = [],
        reportedBy: Set<UUID> = [],
        baseLikeCount: Int = 0
    ) {
        self.id = id
        self.authorID = authorID
        self.caption = caption
        self.photos = photos
        self.linkedRecipe = linkedRecipe
        self.ownRecipeTitle = ownRecipeTitle
        self.visibility = visibility
        self.createdAt = createdAt
        self.likedBy = likedBy
        self.savedBy = savedBy
        self.comments = comments
        self.reportedBy = reportedBy
        self.baseLikeCount = baseLikeCount
    }

    /// Total likes shown under the post.
    public var likeCount: Int { baseLikeCount + likedBy.count }

    /// Whether `userID` has liked the post. Always false for guests.
    public func isLiked(by userID: UUID?) -> Bool {
        guard let userID else { return false }
        return likedBy.contains(userID)
    }

    /// Whether `userID` has saved the post. Always false for guests.
    public func isSaved(by userID: UUID?) -> Bool {
        guard let userID else { return false }
        return savedBy.contains(userID)
    }
}

/// A request to borrow a friend's equipment for a recipe.
public struct ScpBorrowRequest: Codable, Identifiable, Equatable, Sendable {
    public let id: UUID
    public var equipment: ScpEquipment
    public var lenderID: UUID
    public var requesterID: UUID
    /// The recipe the equipment is needed for.
    public var recipeTitle: String
    public var createdAt: Date

    /// Creates a borrow request.
    public init(
        id: UUID = UUID(),
        equipment: ScpEquipment,
        lenderID: UUID,
        requesterID: UUID,
        recipeTitle: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.equipment = equipment
        self.lenderID = lenderID
        self.requesterID = requesterID
        self.recipeTitle = recipeTitle
        self.createdAt = createdAt
    }
}

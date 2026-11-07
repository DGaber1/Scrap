import Foundation

/// A user-contributed recipe awaiting admin approval.
public struct ScpRecipeSubmission: Codable, Identifiable, Equatable, Sendable {
    public let id: UUID
    public var authorID: UUID
    public var recipe: ScpRecipe
    public var status: ScpSubmissionStatus
    public var submittedAt: Date

    /// Creates a submission. New submissions start as `.pending`.
    public init(
        id: UUID = UUID(),
        authorID: UUID,
        recipe: ScpRecipe,
        status: ScpSubmissionStatus = .pending,
        submittedAt: Date = Date()
    ) {
        self.id = id
        self.authorID = authorID
        self.recipe = recipe
        self.status = status
        self.submittedAt = submittedAt
    }
}

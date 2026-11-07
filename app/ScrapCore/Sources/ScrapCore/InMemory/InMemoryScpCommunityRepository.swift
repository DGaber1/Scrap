import Foundation

/// A community repository that keeps submissions in memory.
/// Submitted recipes start as `.pending` and are not listed until approved.
public actor InMemoryScpCommunityRepository: ScpCommunityRepository {
    private var submissions: [ScpRecipeSubmission]
    private let failure: ScpError?

    /// Creates a repository with some already-approved sample recipes.
    public init(
        approved: [ScpRecipe] = ScpSampleData.communityRecipes,
        failure: ScpError? = nil
    ) {
        self.submissions = approved.map {
            ScpRecipeSubmission(authorID: $0.contributedByUserID ?? UUID(), recipe: $0, status: .approved)
        }
        self.failure = failure
    }

    public func approvedRecipes() async throws -> [ScpRecipe] {
        if let failure { throw failure }
        return submissions.filter { $0.status == .approved }.map(\.recipe)
    }

    public func submit(_ submission: ScpRecipeSubmission) async throws {
        if let failure { throw failure }
        var pending = submission
        pending.status = .pending
        pending.recipe.source = .community
        submissions.append(pending)
    }

    /// Every submission with the given status, for tests and a future review screen.
    public func submissions(withStatus status: ScpSubmissionStatus) -> [ScpRecipeSubmission] {
        submissions.filter { $0.status == status }
    }
}

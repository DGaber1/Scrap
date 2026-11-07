import Foundation

/// User-contributed recipes and their approval flow.
public protocol ScpCommunityRepository: Sendable {
    /// Community recipes an admin has approved.
    func approvedRecipes() async throws -> [ScpRecipe]
    /// Sends a new recipe for admin approval.
    func submit(_ submission: ScpRecipeSubmission) async throws
}

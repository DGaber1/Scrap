import Foundation
import Observation
import ScrapCore

/// Recipes shared by other Scrap users, and submitting your own.
@MainActor
@Observable
final class ScpCommunityViewModel {
    private(set) var state: ScpViewState<[ScpRecipe]> = .idle
    private(set) var submitError: ScpError?

    private let repository: any ScpCommunityRepository

    init(repository: any ScpCommunityRepository) {
        self.repository = repository
    }

    func load() async {
        state = .loading
        do {
            let recipes = try await repository.approvedRecipes()
            state = recipes.isEmpty ? .empty : .loaded(recipes)
        } catch {
            state = .failed((error as? ScpError) ?? .unknown(String(describing: error)))
        }
    }

    /// Sends a recipe for review. Returns true when it was accepted.
    /// Ingredient and instruction text is one item per line.
    func submit(
        title: String,
        servings: Int,
        prepMinutes: Int,
        cookMinutes: Int,
        ingredientText: String,
        instructionText: String,
        authorID: UUID
    ) async -> Bool {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let ingredients = ingredientText.split(whereSeparator: \.isNewline).compactMap {
            ScpIngredientLineParser.parse(String($0))
        }
        let steps = instructionText.split(whereSeparator: \.isNewline)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard !cleanTitle.isEmpty, !ingredients.isEmpty, !steps.isEmpty, servings > 0 else {
            submitError = .invalidInput
            return false
        }

        let totalMinutes = prepMinutes + cookMinutes
        let recipe = ScpRecipe(
            id: "community-\(UUID().uuidString)",
            title: cleanTitle,
            ingredients: ingredients,
            instructions: steps,
            prepTimeMinutes: prepMinutes,
            cookTimeMinutes: cookMinutes,
            difficulty: totalMinutes <= 30 ? .easy : (totalMinutes <= 60 ? .medium : .hard),
            servings: servings,
            source: .community,
            contributedByUserID: authorID
        )
        do {
            try await repository.submit(ScpRecipeSubmission(authorID: authorID, recipe: recipe))
            submitError = nil
            return true
        } catch {
            submitError = (error as? ScpError) ?? .unknown(String(describing: error))
            return false
        }
    }

    func clearSubmitError() {
        submitError = nil
    }
}

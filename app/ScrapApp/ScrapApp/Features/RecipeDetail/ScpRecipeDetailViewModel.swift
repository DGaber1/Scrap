import Foundation
import Observation
import ScrapCore

/// State and actions for one recipe's detail screen: loads the full recipe
/// and rescales it when the serving count changes.
@MainActor
@Observable
final class ScpRecipeDetailViewModel {
    private(set) var state: ScpViewState<ScpRecipe> = .idle
    private(set) var servings: Int

    private let ranked: ScpRankedRecipe
    private let kitchen: ScpKitchen
    private let recipeRepository: any ScpRecipeRepository
    private var baseRecipe: ScpRecipe?

    init(ranked: ScpRankedRecipe, kitchen: ScpKitchen, recipeRepository: any ScpRecipeRepository) {
        self.ranked = ranked
        self.kitchen = kitchen
        self.recipeRepository = recipeRepository
        self.servings = max(ranked.recipe.servings, 1)
    }

    var title: String { ranked.recipe.title }
    var matchPercent: Double { ranked.matchPercent }
    var missingEquipment: [ScpEquipment] { ranked.missingEquipment }

    /// The ingredients of the (possibly rescaled) recipe the kitchen lacks.
    func missingIngredients(in recipe: ScpRecipe) -> [ScpRecipeIngredient] {
        recipe.ingredients.filter { isMissing($0) }
    }

    /// The ingredients of the (possibly rescaled) recipe the kitchen already has.
    func availableIngredients(in recipe: ScpRecipe) -> [ScpRecipeIngredient] {
        recipe.ingredients.filter { !isMissing($0) }
    }

    /// Rough cost of buying what is missing, at the current serving count.
    func estimatedMissingCost(in recipe: ScpRecipe) -> Decimal {
        let estimator = ScpFlatCostEstimator()
        return missingIngredients(in: recipe).reduce(Decimal(0)) { total, item in
            total + (estimator.estimatedCost(of: item.ingredient, quantity: item.quantity) ?? 0)
        }
    }

    /// Whether the user lacks this ingredient (drawn in red).
    func isMissing(_ ingredient: ScpRecipeIngredient) -> Bool {
        !kitchen.ingredientIDs.contains(ingredient.ingredient.id)
    }

    /// Loads the full recipe, including instructions.
    func load() async {
        state = .loading
        do {
            let full = try await recipeRepository.recipe(id: ranked.recipe.id)
            baseRecipe = full
            servings = max(full.servings, 1)
            state = (full.ingredients.isEmpty && full.instructions.isEmpty) ? .empty : .loaded(full)
        } catch {
            state = .failed((error as? ScpError) ?? .unknown(String(describing: error)))
        }
    }

    /// One more serving.
    func increaseServings() {
        applyServings(servings + 1)
    }

    /// One fewer serving, never below one.
    func decreaseServings() {
        applyServings(servings - 1)
    }

    private func applyServings(_ newValue: Int) {
        guard let baseRecipe, newValue >= 1 else { return }
        do {
            state = .loaded(try ScpServingScaler.scale(baseRecipe, toServings: newValue))
            servings = newValue
        } catch {
            state = .failed((error as? ScpError) ?? .unknown(String(describing: error)))
        }
    }
}

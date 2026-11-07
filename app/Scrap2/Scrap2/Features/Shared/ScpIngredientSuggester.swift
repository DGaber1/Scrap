import Foundation
import Observation
import ScrapCore

/// Turns what the user types into a short list of real ingredient names,
/// so they pick a suggestion instead of risking a typo.
@MainActor
@Observable
final class ScpIngredientSuggester {
    private(set) var suggestions: [ScpIngredient] = []
    private(set) var isSearching = false
    private(set) var error: ScpError?

    private let repository: any ScpIngredientRepository
    private var searchTask: Task<Void, Never>?

    init(repository: any ScpIngredientRepository) {
        self.repository = repository
    }

    /// Call whenever the text changes. Waits briefly so we do not search on every keystroke.
    func queryChanged(_ text: String) {
        searchTask?.cancel()
        let query = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard query.count >= 2 else {
            suggestions = []
            isSearching = false
            error = nil
            return
        }
        searchTask = Task { [repository] in
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            isSearching = true
            do {
                let found = try await repository.searchIngredients(matching: query)
                guard !Task.isCancelled else { return }
                suggestions = found
                error = nil
            } catch {
                guard !Task.isCancelled else { return }
                suggestions = []
                self.error = (error as? ScpError) ?? .unknown(String(describing: error))
            }
            isSearching = false
        }
    }

    /// Hides the suggestions, for example after one is picked.
    func clear() {
        searchTask?.cancel()
        suggestions = []
        isSearching = false
        error = nil
    }
}

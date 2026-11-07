import Foundation

/// Suggests replacements for a missing ingredient. Swaps that break one of the
/// kitchen's dietary restrictions are left out, and swaps the user can already
/// make from their kitchen are listed first.
public struct ScpSubstitutionFinder: Sendable {
    private let entries: [String: [ScpSubstitutionOption]]

    /// Creates a finder. `entries` maps a normalized ingredient name to its possible swaps.
    public init() {
        self.entries = ScpSubstitutionTable.entries
    }

    public init(entries: [String: [ScpSubstitutionOption]]) {
        self.entries = entries
    }

    /// Words that describe an ingredient without changing what it is ("unsalted butter" is butter).
    private static let modifiers: Set<String> = [
        "unsalted", "salted", "large", "small", "medium", "fresh", "whole", "lowfat", "low-fat", "nonfat",
        "skim", "organic", "extra", "ripe", "raw", "dried", "chopped", "minced", "diced", "sliced",
        "grated", "shredded", "softened", "melted", "packed", "boneless", "skinless", "plain",
        "unsweetened", "sweetened", "frozen", "canned",
    ]

    /// Replacements for `ingredient` that fit `kitchen`'s dietary restrictions, with the ones the kitchen can already make first.
    public func substitutions(for ingredient: ScpIngredient, in kitchen: ScpKitchen) -> [ScpSubstitution] {
        let have = kitchen.ingredientIDs
        let options = options(for: ingredient).filter { kitchen.restrictions.isSubset(of: $0.suitableFor) }
        let all = options.map { option in
            ScpSubstitution(
                original: ingredient,
                replacement: ScpIngredient(name: option.name),
                isInKitchen: Self.components(of: option.name).allSatisfy { have.contains($0) },
                ratio: option.ratio.isEmpty ? nil : option.ratio
            )
        }
        return all.filter { $0.isInKitchen } + all.filter { !$0.isInKitchen }
    }

    /// Looks the ingredient up by name, then again with descriptive words and plurals removed.
    private func options(for ingredient: ScpIngredient) -> [ScpSubstitutionOption] {
        if let exact = entries[ingredient.id] { return exact }

        let words = ingredient.id.split(separator: " ").map(String.init).filter { !Self.modifiers.contains($0) }
        guard !words.isEmpty else { return [] }
        let stem = words.dropLast().joined(separator: " ")
        let last = words[words.count - 1]
        let prefix = stem.isEmpty ? "" : stem + " "

        var candidates = [prefix + last]
        if last.hasSuffix("es") { candidates.append(prefix + String(last.dropLast(2))) }
        if last.hasSuffix("s") { candidates.append(prefix + String(last.dropLast())) }
        for candidate in candidates {
            if let found = entries[candidate] { return found }
        }
        return []
    }

    /// "Milk and lemon juice" needs both "milk" and "lemon juice".
    private static func components(of name: String) -> [String] {
        name.components(separatedBy: " and ").map { ScpIngredient.normalizedID(for: $0) }
    }
}

import Foundation

/// Builds a grocery list from the ingredients a recipe needs that the user
/// does not have, with an estimated cost per item, and merges new items
/// into an existing list.
public struct ScpGroceryListBuilder: Sendable {
    private let costEstimator: any ScpCostEstimator

    /// Creates a builder that prices items with `costEstimator`.
    public init(costEstimator: any ScpCostEstimator = ScpFlatCostEstimator()) {
        self.costEstimator = costEstimator
    }

    /// A list containing only the ingredients of `recipe` missing from `kitchen`,
    /// scaled to `servings` when given. Unknown prices count as zero in the total.
    /// - Throws: ``ScpError/invalidInput`` if `servings` is not positive.
    public func build(
        for recipe: ScpRecipe,
        kitchen: ScpKitchen,
        servings: Int? = nil,
        ownerID: UUID? = nil
    ) throws -> ScpGroceryList {
        let target: ScpRecipe
        if let servings {
            target = try ScpServingScaler.scale(recipe, toServings: servings)
        } else {
            target = recipe
        }

        let have = kitchen.ingredientIDs
        let items = target.ingredients
            .filter { !have.contains($0.ingredient.id) }
            .map { missing in
                ScpGroceryListItem(
                    ingredient: missing.ingredient,
                    quantity: missing.quantity,
                    estimatedCost: costEstimator.estimatedCost(of: missing.ingredient, quantity: missing.quantity) ?? 0,
                    source: .recipe(id: target.id)
                )
            }
        return ScpGroceryList(ownerID: ownerID, items: items)
    }

    /// `existing` with the missing ingredients of `recipe` added to it (see ``merge(_:into:)``).
    /// - Throws: ``ScpError/invalidInput`` if `servings` is not positive.
    public func adding(
        _ recipe: ScpRecipe,
        kitchen: ScpKitchen,
        servings: Int? = nil,
        to existing: ScpGroceryList
    ) throws -> ScpGroceryList {
        let additions = try build(for: recipe, kitchen: kitchen, servings: servings, ownerID: existing.ownerID)
        return merge(additions, into: existing)
    }

    /// `list` with `additions` merged in. An ingredient already on the list is not
    /// repeated: when the units match, the amounts and costs are added together;
    /// otherwise the existing line is kept as it is.
    public func merge(_ additions: ScpGroceryList, into list: ScpGroceryList) -> ScpGroceryList {
        var merged = list
        for item in additions.items {
            if let index = merged.items.firstIndex(where: { $0.ingredient.id == item.ingredient.id }) {
                if merged.items[index].quantity.unit == item.quantity.unit {
                    merged.items[index].quantity.amount += item.quantity.amount
                    merged.items[index].estimatedCost += item.estimatedCost
                }
            } else {
                merged.items.append(item)
            }
        }
        return merged
    }
}

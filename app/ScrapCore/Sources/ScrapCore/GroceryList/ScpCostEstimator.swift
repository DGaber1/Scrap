import Foundation

/// Where an estimated price for an ingredient comes from. A protocol so the
/// real pricing source can be swapped in later and tests can supply fixed prices.
public protocol ScpCostEstimator: Sendable {
    /// Estimated cost of `quantity` of `ingredient`, or `nil` when unknown.
    /// Callers must not treat `nil` as free.
    func estimatedCost(of ingredient: ScpIngredient, quantity: ScpQuantity) -> Decimal?
}

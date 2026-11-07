import Foundation

/// A placeholder estimator that charges the same price for every ingredient.
/// Good enough for the first prototype; replace with a real source later.
public struct ScpFlatCostEstimator: ScpCostEstimator {
    public let pricePerIngredient: Decimal

    /// Creates an estimator charging `pricePerIngredient` for each ingredient.
    public init(pricePerIngredient: Decimal = 2) {
        self.pricePerIngredient = pricePerIngredient
    }

    public func estimatedCost(of ingredient: ScpIngredient, quantity: ScpQuantity) -> Decimal? {
        pricePerIngredient
    }
}

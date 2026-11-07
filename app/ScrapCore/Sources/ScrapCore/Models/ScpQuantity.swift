import Foundation

/// An amount of something, such as "2 cups".
public struct ScpQuantity: Codable, Equatable, Hashable, Sendable {
    public var amount: Double
    public var unit: ScpMeasurementUnit

    /// Creates a quantity.
    public init(amount: Double, unit: ScpMeasurementUnit) {
        self.amount = amount
        self.unit = unit
    }

    /// A copy of this quantity multiplied by `ratio`.
    public func scaled(by ratio: Double) -> ScpQuantity {
        ScpQuantity(amount: amount * ratio, unit: unit)
    }
}

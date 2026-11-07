import Foundation
import ScrapCore

/// Turns a quantity into text such as "2 cups flour" or "1.5 lb chicken".
enum ScpQuantityFormatter {
    /// Amount and unit only, such as "2 cup" or "1.5 lb". Empty for a plain count of one.
    static func amountText(for quantity: ScpQuantity) -> String {
        let number = quantity.amount.formatted(.number.precision(.fractionLength(0...2)))
        let unit = quantity.unit.abbreviation
        return unit.isEmpty ? number : "\(number) \(unit)"
    }

    /// Amount, unit, and ingredient name.
    static func text(for quantity: ScpQuantity, name: String) -> String {
        "\(amountText(for: quantity)) \(name)"
    }
}

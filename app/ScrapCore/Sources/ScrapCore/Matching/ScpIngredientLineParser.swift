import Foundation

/// Turns a typed line such as "2 cups flour" or "1/2 tsp salt" into an ingredient with a quantity.
/// A line with no amount, such as "salt", becomes one piece.
public enum ScpIngredientLineParser {

    private static let units: [String: ScpMeasurementUnit] = [
        "piece": .piece, "pieces": .piece,
        "g": .gram, "gram": .gram, "grams": .gram,
        "kg": .kilogram, "kilogram": .kilogram, "kilograms": .kilogram,
        "oz": .ounce, "ounce": .ounce, "ounces": .ounce,
        "lb": .pound, "lbs": .pound, "pound": .pound, "pounds": .pound,
        "cup": .cup, "cups": .cup,
        "tbsp": .tablespoon, "tablespoon": .tablespoon, "tablespoons": .tablespoon,
        "tsp": .teaspoon, "teaspoon": .teaspoon, "teaspoons": .teaspoon,
        "ml": .milliliter, "milliliter": .milliliter, "milliliters": .milliliter,
        "l": .liter, "liter": .liter, "liters": .liter,
    ]

    /// The parsed ingredient, or `nil` when the line is blank or has no name.
    public static func parse(_ line: String) -> ScpRecipeIngredient? {
        let tokens = line.split(whereSeparator: { $0.isWhitespace }).map(String.init)
        guard !tokens.isEmpty else { return nil }

        var index = 0
        var amount = 1.0
        var unit = ScpMeasurementUnit.piece

        if let number = number(from: tokens[0]) {
            amount = number
            index = 1
            if index + 1 < tokens.count, let found = units[tokens[index].lowercased()] {
                unit = found
                index += 1
            }
        }

        let name = tokens[index...].joined(separator: " ")
        guard !name.isEmpty, amount > 0 else { return nil }
        return ScpRecipeIngredient(
            ingredient: ScpIngredient(name: name),
            quantity: ScpQuantity(amount: amount, unit: unit)
        )
    }

    private static func number(from token: String) -> Double? {
        if let value = Double(token) { return value }
        let parts = token.split(separator: "/")
        if parts.count == 2, let top = Double(parts[0]), let bottom = Double(parts[1]), bottom != 0 {
            return top / bottom
        }
        return nil
    }
}

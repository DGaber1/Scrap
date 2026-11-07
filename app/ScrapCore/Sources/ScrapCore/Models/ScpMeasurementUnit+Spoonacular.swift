import Foundation

extension ScpMeasurementUnit {
    /// Maps a free-text Spoonacular unit ("cups", "Tbsp", "") onto a unit.
    /// Anything unrecognized becomes `.piece` rather than failing (REQ-D-22).
    init(spoonacularUnit raw: String?) {
        let value = (raw ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        switch value {
        case "g", "gram", "grams": self = .gram
        case "kg", "kilogram", "kilograms": self = .kilogram
        case "oz", "ounce", "ounces": self = .ounce
        case "lb", "lbs", "pound", "pounds": self = .pound
        case "cup", "cups", "c": self = .cup
        case "tbsp", "tbsps", "tablespoon", "tablespoons", "tbs": self = .tablespoon
        case "tsp", "tsps", "teaspoon", "teaspoons": self = .teaspoon
        case "ml", "milliliter", "milliliters", "millilitre", "millilitres": self = .milliliter
        case "l", "liter", "liters", "litre", "litres": self = .liter
        default: self = .piece
        }
    }
}

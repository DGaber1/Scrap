import Foundation

/// A unit of measurement for an ingredient quantity.
public enum ScpMeasurementUnit: String, Codable, CaseIterable, Sendable {
    case piece
    case gram
    case kilogram
    case ounce
    case pound
    case cup
    case tablespoon
    case teaspoon
    case milliliter
    case liter

    /// Short label for display, such as "tbsp". Empty for `.piece`.
    public var abbreviation: String {
        switch self {
        case .piece: return ""
        case .gram: return "g"
        case .kilogram: return "kg"
        case .ounce: return "oz"
        case .pound: return "lb"
        case .cup: return "cup"
        case .tablespoon: return "tbsp"
        case .teaspoon: return "tsp"
        case .milliliter: return "mL"
        case .liter: return "L"
        }
    }
}

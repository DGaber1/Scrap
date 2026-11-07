import SwiftUI

/// Every color the UI uses (REQ-D-23). Values are taken from the team's UI designs.
enum ScpColor {
    /// Cream screen background.
    static let background = Color(scpHex: 0xF5EEDC)
    /// Cards and text fields.
    static let card = Color(scpHex: 0xFBF7EC)
    /// Forest green: buttons, selected tabs, titles.
    static let brand = Color(scpHex: 0x4B6E49)
    /// Lighter green: match percentages and progress bars.
    static let matchGreen = Color(scpHex: 0x5D9A4F)
    /// Soft green: info banners and "add" chips.
    static let softGreen = Color(scpHex: 0xE1EAD6)
    /// The red highlight for a missing ingredient.
    static let missingIngredient = Color(scpHex: 0xC4402F)
    /// Pale red behind a missing-ingredient row.
    static let missingBackground = Color(scpHex: 0xF7E1DB)
    /// Unselected chips and segmented-control tracks.
    static let chip = Color(scpHex: 0xECE3CB)
    /// Thin dividing lines.
    static let divider = Color(scpHex: 0xE5DAC0)
    static let textPrimary = Color(scpHex: 0x2B2A22)
    static let textMuted = Color(scpHex: 0x8A8468)
    /// Grocery list notepad.
    static let paper = Color(scpHex: 0xFFFDF5)
    static let paperLine = Color(scpHex: 0xB9D3E8)
    static let paperMargin = Color(scpHex: 0xE9A6A0)
    static let ink = Color(scpHex: 0x2A2A45)
}

private extension Color {
    init(scpHex hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}

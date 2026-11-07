import SwiftUI

/// Every font the UI uses (REQ-D-23). Sizes scale with Dynamic Type.
/// The two handwriting fonts ship with iOS; if one is ever missing, SwiftUI falls back to the system font.
enum ScpFont {
    /// The big "Scrap" wordmark.
    static func logo(_ size: CGFloat) -> Font {
        .custom("MarkerFelt-Wide", size: size, relativeTo: .largeTitle)
    }

    /// The handwritten look of the grocery list notepad.
    static func handwriting(_ size: CGFloat, relativeTo style: Font.TextStyle = .title3) -> Font {
        .custom("BradleyHandITCTT-Bold", size: size, relativeTo: style)
    }

    static let screenTitle = Font.title.weight(.bold)
    static let sectionHeader = Font.footnote.weight(.bold)
    static let recipeTitle = Font.headline
    static let detail = Font.subheadline
    static let caption = Font.caption
}

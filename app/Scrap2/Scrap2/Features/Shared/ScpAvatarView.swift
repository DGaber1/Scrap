import Foundation
import SwiftUI
import ScrapCore

/// A round avatar showing the first letter of a username on a colored circle.
/// The color is picked from the username, so each person always gets the same one.
struct ScpAvatarView: View {
    let username: String
    var size: CGFloat = 44

    var body: some View {
        Text(initial)
            .font(.system(size: size * 0.42, weight: .semibold, design: .rounded))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(color, in: Circle())
            .accessibilityHidden(true)
    }

    private var initial: String {
        username.first.map { String($0).uppercased() } ?? "?"
    }

    private var color: Color {
        let palette = ScpColor.avatarPalette
        let sum = username.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return palette[sum % palette.count]
    }
}

extension ScpEquipment {
    /// A small picture for this equipment, drawn in a rounded tile.
    var emoji: String {
        switch id {
        case ScpEquipment.airFryer.id: return "🍟"
        case ScpEquipment.blender.id: return "🥤"
        case ScpEquipment.standMixer.id: return "🧁"
        case ScpEquipment.instantPot.id: return "🍲"
        case ScpEquipment.oven.id: return "🥧"
        case ScpEquipment.stovetop.id: return "🍳"
        default: return "🍴"
        }
    }

    /// The name in lowercase with "a" or "an", such as "an air fryer".
    var withArticle: String {
        let lower = name.lowercased()
        let article = lower.first.map { "aeiou".contains($0) } == true ? "an" : "a"
        return "\(article) \(lower)"
    }
}

/// Short relative times such as "now", "5m ago", "2h ago", or "3d ago".
enum ScpAgeFormatter {
    static func text(since date: Date, now: Date = Date()) -> String {
        let seconds = max(now.timeIntervalSince(date), 0)
        switch seconds {
        case ..<60: return String(localized: "now")
        case ..<3_600: return String(localized: "\(Int(seconds / 60))m ago")
        case ..<86_400: return String(localized: "\(Int(seconds / 3_600))h ago")
        case ..<604_800: return String(localized: "\(Int(seconds / 86_400))d ago")
        default: return date.formatted(.dateTime.month(.abbreviated).day())
        }
    }
}

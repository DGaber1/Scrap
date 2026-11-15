import SwiftUI

/// The full-width green capsule button.
struct ScpPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(ScpColor.brand.opacity(configuration.isPressed ? 0.85 : 1), in: Capsule())
    }
}

/// The full-width outlined capsule, such as "Add air fryer to grocery list".
struct ScpOutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(ScpColor.brand)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(ScpColor.card.opacity(configuration.isPressed ? 0.6 : 0), in: Capsule())
            .overlay(Capsule().stroke(ScpColor.brand, lineWidth: 2))
    }
}

/// The small green pill, such as "Accept" or "Ask to borrow". Pass `isFilled: false`
/// for the quieter state shown after the action is done.
struct ScpPillButtonStyle: ButtonStyle {
    var isFilled = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(isFilled ? Color.white : ScpColor.brand)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                (isFilled ? ScpColor.brand : ScpColor.softGreen).opacity(configuration.isPressed ? 0.8 : 1),
                in: Capsule()
            )
    }
}

/// The small soft-green button, such as "+ Add missing to list".
struct ScpSoftButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(ScpColor.brand)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(ScpColor.softGreen.opacity(configuration.isPressed ? 0.7 : 1), in: RoundedRectangle(cornerRadius: 12))
    }
}

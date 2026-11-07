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

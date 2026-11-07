import SwiftUI

/// A centered icon, title, and message for screens that are not built yet.
struct ScpPlaceholderView: View {
    let systemImage: String
    let title: LocalizedStringKey
    let message: LocalizedStringKey

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 48))
                .foregroundStyle(ScpColor.brand)
            Text(title)
                .font(ScpFont.screenTitle)
                .foregroundStyle(ScpColor.textPrimary)
            Text(message)
                .font(ScpFont.detail)
                .foregroundStyle(ScpColor.textMuted)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ScpColor.background)
    }
}

import SwiftUI

/// The heart that saves a recipe.
struct ScpHeartButton: View {
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isOn ? "heart.fill" : "heart")
                .font(.title3)
                .foregroundStyle(isOn ? ScpColor.missingIngredient : ScpColor.textMuted)
                .padding(6)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isOn ? Text("Remove from saved recipes") : Text("Save recipe"))
    }
}

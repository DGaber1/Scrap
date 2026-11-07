import SwiftUI
import ScrapCore

/// One ranked recipe in the results list: photo, title, match bar, time, and what is missing.
struct ScpRecipeCard: View {
    let ranked: ScpRankedRecipe
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    let onAddMissing: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: ranked.recipe.imageURL) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                ScpColor.chip
            }
            .frame(width: 76, height: 76)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top) {
                    Text(ranked.recipe.title)
                        .font(ScpFont.recipeTitle)
                        .foregroundStyle(ScpColor.textPrimary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    Spacer(minLength: 0)
                    ScpHeartButton(isOn: isFavorite, action: onToggleFavorite)
                }

                HStack(spacing: 8) {
                    ProgressView(value: ranked.matchPercent)
                        .tint(ScpColor.matchGreen)
                    Text(ranked.matchPercent, format: .percent.precision(.fractionLength(0)))
                        .font(ScpFont.detail.weight(.semibold))
                        .foregroundStyle(ScpColor.matchGreen)
                    if ranked.recipe.totalTimeMinutes > 0 {
                        Text("· \(ranked.recipe.totalTimeMinutes) min total")
                            .font(ScpFont.caption)
                            .foregroundStyle(ScpColor.textMuted)
                            .fixedSize()
                    }
                }

                if !ranked.missingIngredients.isEmpty {
                    Text("Missing: \(ranked.missingIngredients.map { $0.ingredient.name }.formatted())")
                        .font(ScpFont.caption)
                        .foregroundStyle(ScpColor.missingIngredient)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)

                    Button(action: onAddMissing) {
                        Label("Add missing to list", systemImage: "plus")
                    }
                    .buttonStyle(ScpSoftButtonStyle())
                }
            }
        }
        .padding(12)
        .background(ScpColor.card, in: RoundedRectangle(cornerRadius: 16))
    }
}

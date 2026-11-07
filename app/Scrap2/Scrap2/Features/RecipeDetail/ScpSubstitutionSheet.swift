import SwiftUI
import ScrapCore

/// Swaps for a missing ingredient. Ones you already own are listed first.
struct ScpSubstitutionSheet: View {
    let ingredient: ScpRecipeIngredient
    let substitutions: [ScpSubstitution]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if substitutions.isEmpty {
                        ScpEmptyHint(text: "We don't have a swap for this one that fits your dietary needs yet.")
                    } else {
                        ForEach(substitutions) { substitution in
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(substitution.replacement.name)
                                        .foregroundStyle(ScpColor.textPrimary)
                                    if let ratio = substitution.ratio {
                                        Text(ratio)
                                            .font(ScpFont.caption)
                                            .foregroundStyle(ScpColor.textMuted)
                                    }
                                }
                                Spacer()
                                if substitution.isInKitchen {
                                    Label("You have this", systemImage: "checkmark.circle.fill")
                                        .font(ScpFont.caption)
                                        .foregroundStyle(ScpColor.matchGreen)
                                } else {
                                    Text("Need to buy")
                                        .font(ScpFont.caption)
                                        .foregroundStyle(ScpColor.textMuted)
                                }
                            }
                            .padding(14)
                            .background(ScpColor.card, in: RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding(16)
            }
            .background(ScpColor.background)
            .navigationTitle("Instead of \(ingredient.ingredient.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

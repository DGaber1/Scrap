import SwiftUI
import ScrapCore

/// A text field that suggests real ingredient names as the user types.
struct ScpIngredientSearchField: View {
    let placeholder: LocalizedStringKey
    let suggester: ScpIngredientSuggester
    let onPick: (ScpIngredient) -> Void
    let onSubmitText: (String) -> Void

    @State private var text = ""

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(ScpColor.textMuted)
                TextField(placeholder, text: $text)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.done)
                    .onSubmit {
                        let value = text
                        reset()
                        onSubmitText(value)
                    }
                if suggester.isSearching {
                    ProgressView()
                }
            }
            .padding(14)
            .background(ScpColor.card, in: RoundedRectangle(cornerRadius: 14))
            .onChange(of: text) { _, newValue in
                suggester.queryChanged(newValue)
            }

            if !suggester.suggestions.isEmpty {
                VStack(spacing: 0) {
                    ForEach(suggester.suggestions) { suggestion in
                        Button {
                            reset()
                            onPick(suggestion)
                        } label: {
                            HStack {
                                Text(suggestion.name.capitalized)
                                    .foregroundStyle(ScpColor.textPrimary)
                                Spacer()
                                Image(systemName: "plus.circle")
                                    .foregroundStyle(ScpColor.brand)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                        }
                        Divider()
                    }
                }
                .background(ScpColor.card, in: RoundedRectangle(cornerRadius: 14))
                .padding(.top, 6)
            }
        }
    }

    private func reset() {
        text = ""
        suggester.clear()
    }
}

import SwiftUI
import ScrapCore

/// My Kitchen: what is in the pantry and fridge, which tools you own, and dietary needs.
struct ScpKitchenView: View {
    private enum KitchenTab: String, CaseIterable, Identifiable {
        case pantry = "Pantry"
        case fridge = "Fridge"
        case equipment = "Equipment"
        var id: String { rawValue }
    }

    let kitchen: ScpKitchenViewModel
    @State private var tab: KitchenTab = .pantry
    @State private var suggester: ScpIngredientSuggester
    @State private var expirationItem: ScpPantryItem?

    init(kitchen: ScpKitchenViewModel, dependencies: ScpAppDependencies) {
        self.kitchen = kitchen
        _suggester = State(initialValue: ScpIngredientSuggester(repository: dependencies.ingredientRepository))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Picker("Kitchen section", selection: $tab) {
                    ForEach(KitchenTab.allCases) { Text(LocalizedStringKey($0.rawValue)).tag($0) }
                }
                .pickerStyle(.segmented)

                if let error = kitchen.error {
                    Text(error.userMessage)
                        .font(ScpFont.caption)
                        .foregroundStyle(ScpColor.missingIngredient)
                }

                switch tab {
                case .pantry: ingredientSection(location: .pantry)
                case .fridge: ingredientSection(location: .fridge)
                case .equipment: ScpEquipmentSection(kitchen: kitchen)
                }
            }
            .padding(16)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(ScpColor.background)
        .navigationTitle("My Kitchen")
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $expirationItem) { item in
            ScpExpirationSheet(item: item) { date in
                Task { await kitchen.setExpiration(date, for: item) }
            }
            .presentationDetents([.medium])
        }
    }

    @ViewBuilder
    private func ingredientSection(location: ScpStorageLocation) -> some View {
        Label(
            "Everything you add here is used to find recipes you can make.",
            systemImage: "info.circle"
        )
        .font(ScpFont.detail)
        .foregroundStyle(ScpColor.brand)
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ScpColor.softGreen, in: RoundedRectangle(cornerRadius: 12))

        ScpIngredientSearchField(
            placeholder: "Add an ingredient…",
            suggester: suggester,
            onPick: { ingredient in Task { await kitchen.addIngredient(ingredient, to: location) } },
            onSubmitText: { name in Task { await kitchen.addIngredient(named: name, to: location) } }
        )

        let items = kitchen.items(in: location)
        if items.isEmpty {
            ScpEmptyHint(text: "Nothing here yet. Search above to add your first ingredient.")
        } else {
            ForEach(items) { item in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.ingredient.name.capitalized)
                            .foregroundStyle(ScpColor.textPrimary)
                        expirationLabel(for: item)
                    }
                    Spacer()
                    Menu {
                        Button("Set expiration date…") { expirationItem = item }
                        if item.expirationDate != nil {
                            Button("Clear expiration date") {
                                Task { await kitchen.setExpiration(nil, for: item) }
                            }
                        }
                        Button("Move to \(location == .pantry ? "fridge" : "pantry")") {
                            Task { await kitchen.move(item, to: location == .pantry ? .fridge : .pantry) }
                        }
                        Button("Remove", role: .destructive) {
                            Task { await kitchen.removeItem(id: item.id) }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .padding(8)
                            .foregroundStyle(ScpColor.textMuted)
                    }
                    .accessibilityLabel("Options for \(item.ingredient.name)")
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(ScpColor.card, in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    @ViewBuilder
    private func expirationLabel(for item: ScpPantryItem) -> some View {
        if let date = item.expirationDate {
            if item.isNearingExpiration() {
                Label("Use soon · \(date.formatted(date: .abbreviated, time: .omitted))", systemImage: "clock.badge.exclamationmark")
                    .font(ScpFont.caption)
                    .foregroundStyle(ScpColor.missingIngredient)
            } else {
                Text("Expires \(date.formatted(date: .abbreviated, time: .omitted))")
                    .font(ScpFont.caption)
                    .foregroundStyle(ScpColor.textMuted)
            }
        }
    }
}

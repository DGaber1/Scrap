import SwiftUI
import ScrapCore

/// Home: add what you have, then see the recipes you can make.
struct ScpHomeView: View {
    let home: ScpHomeViewModel
    let kitchen: ScpKitchenViewModel
    let groceryList: ScpGroceryListViewModel
    let dependencies: ScpAppDependencies

    @State private var suggester: ScpIngredientSuggester

    init(
        home: ScpHomeViewModel,
        kitchen: ScpKitchenViewModel,
        groceryList: ScpGroceryListViewModel,
        dependencies: ScpAppDependencies
    ) {
        self.home = home
        self.kitchen = kitchen
        self.groceryList = groceryList
        self.dependencies = dependencies
        _suggester = State(initialValue: ScpIngredientSuggester(repository: dependencies.ingredientRepository))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    header
                    ScpIngredientSearchField(
                        placeholder: "Add an ingredient…",
                        suggester: suggester,
                        onPick: { ingredient in Task { await kitchen.addIngredient(ingredient) } },
                        onSubmitText: { name in Task { await kitchen.addIngredient(named: name) } }
                    )
                    ingredientChips
                    if !dependencies.usesLiveRecipes {
                        sampleNotice
                    }
                    results
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(ScpColor.background)
            .toolbar(.hidden, for: .navigationBar)
        }
        .task(id: kitchen.ingredientKey) {
            try? await Task.sleep(for: .milliseconds(600))
            guard !Task.isCancelled else { return }
            await home.findRecipes(for: kitchen.kitchen)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Scrap")
                .font(ScpFont.logo(44))
                .foregroundStyle(ScpColor.brand)
            Text("What's in your kitchen?")
                .font(ScpFont.screenTitle)
                .foregroundStyle(ScpColor.textPrimary)
        }
        .padding(.top, 8)
    }

    private var ingredientChips: some View {
        let items = kitchen.kitchen.pantryItems
        return ScpFlowLayout(spacing: 8) {
            ForEach(items) { item in
                Button {
                    Task { await kitchen.removeItem(id: item.id) }
                } label: {
                    HStack(spacing: 6) {
                        Text(item.ingredient.name.capitalized)
                        Image(systemName: "xmark")
                            .font(.caption2.weight(.bold))
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(ScpColor.brand, in: Capsule())
                }
                .accessibilityLabel("Remove \(item.ingredient.name)")
            }
        }
    }

    private var sampleNotice: some View {
        Label("Showing sample recipes. Add your Spoonacular key to Secrets.plist for real ones.", systemImage: "info.circle")
            .font(ScpFont.caption)
            .foregroundStyle(ScpColor.textMuted)
    }

    @ViewBuilder
    private var results: some View {
        switch home.state {
        case .idle, .empty:
            ScpEmptyHint(text: "Add a few ingredients and your top recipes will show up here.")
        case .loading:
            HStack(spacing: 12) {
                ProgressView()
                Text("Finding recipes…")
                    .foregroundStyle(ScpColor.textMuted)
            }
            .padding(.top, 8)
        case .failed(let error):
            VStack(alignment: .leading, spacing: 8) {
                Text(error.userMessage)
                    .foregroundStyle(ScpColor.missingIngredient)
                Button("Try again") {
                    Task { await home.findRecipes(for: kitchen.kitchen, force: true) }
                }
                .buttonStyle(ScpSoftButtonStyle())
            }
        case .loaded(let ranked):
            Text("Top recipes")
                .font(ScpFont.sectionHeader)
                .foregroundStyle(ScpColor.textMuted)
                .textCase(.uppercase)
            ForEach(ranked) { item in
                NavigationLink {
                    ScpRecipeDetailView(
                        ranked: item,
                        kitchen: kitchen.kitchen,
                        groceryList: groceryList,
                        dependencies: dependencies
                    )
                } label: {
                    ScpRecipeCard(ranked: item) {
                        Task { await groceryList.addMissingItems(of: item.recipe, kitchen: kitchen.kitchen) }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

/// A short grey sentence shown when a list has nothing in it yet.
struct ScpEmptyHint: View {
    let text: LocalizedStringKey

    var body: some View {
        Text(text)
            .font(ScpFont.detail)
            .foregroundStyle(ScpColor.textMuted)
            .padding(.top, 8)
    }
}

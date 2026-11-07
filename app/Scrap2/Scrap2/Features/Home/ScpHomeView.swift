import SwiftUI
import ScrapCore

/// Home: add what you have, then see the recipes you can make.
struct ScpHomeView: View {
    let home: ScpHomeViewModel
    let kitchen: ScpKitchenViewModel
    let groceryList: ScpGroceryListViewModel
    let session: ScpSessionViewModel
    let favorites: ScpFavoritesViewModel
    let dependencies: ScpAppDependencies
    let onNeedAccount: (LocalizedStringKey) -> Void

    @State private var suggester: ScpIngredientSuggester
    @State private var showsFilters = false

    init(
        home: ScpHomeViewModel,
        kitchen: ScpKitchenViewModel,
        groceryList: ScpGroceryListViewModel,
        session: ScpSessionViewModel,
        favorites: ScpFavoritesViewModel,
        dependencies: ScpAppDependencies,
        onNeedAccount: @escaping (LocalizedStringKey) -> Void
    ) {
        self.home = home
        self.kitchen = kitchen
        self.groceryList = groceryList
        self.session = session
        self.favorites = favorites
        self.dependencies = dependencies
        self.onNeedAccount = onNeedAccount
        _suggester = State(initialValue: ScpIngredientSuggester(repository: dependencies.ingredientRepository))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    header
                    HStack(alignment: .top, spacing: 10) {
                        ScpIngredientSearchField(
                            placeholder: "Add an ingredient…",
                            suggester: suggester,
                            onPick: { ingredient in Task { await kitchen.addIngredient(ingredient) } },
                            onSubmitText: { name in Task { await kitchen.addIngredient(named: name) } }
                        )
                        filterButton
                    }
                    ingredientChips
                    useSoonBanner
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
            .sheet(isPresented: $showsFilters) {
                ScpFilterSheet(
                    options: Bindable(home).filterOptions,
                    onReset: { home.resetFilters() }
                )
                .presentationDetents([.large])
            }
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

    private var filterButton: some View {
        Button {
            showsFilters = true
        } label: {
            Image(systemName: "slider.horizontal.3")
                .font(.title3)
                .foregroundStyle(home.activeFilterCount > 0 ? Color.white : ScpColor.brand)
                .frame(width: 50, height: 50)
                .background(home.activeFilterCount > 0 ? ScpColor.brand : ScpColor.card, in: RoundedRectangle(cornerRadius: 14))
                .overlay(alignment: .topTrailing) {
                    if home.activeFilterCount > 0 {
                        Text("\(home.activeFilterCount)")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(5)
                            .background(ScpColor.missingIngredient, in: Circle())
                            .offset(x: 6, y: -6)
                    }
                }
        }
        .accessibilityLabel("Filters")
    }

    @ViewBuilder
    private var useSoonBanner: some View {
        let soon = kitchen.useSoonItems
        if !soon.isEmpty {
            Label(
                "Use soon: \(soon.map { $0.ingredient.name.capitalized }.formatted())",
                systemImage: "clock.badge.exclamationmark"
            )
            .font(ScpFont.detail)
            .foregroundStyle(ScpColor.missingIngredient)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(ScpColor.missingBackground, in: RoundedRectangle(cornerRadius: 12))
        }
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
        case .loaded:
            let visible = home.visibleRecipes
            if visible.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ScpEmptyHint(text: "No recipes match your filters.")
                    Button("Reset filters") { home.resetFilters() }
                        .buttonStyle(ScpSoftButtonStyle())
                }
            } else {
                Text("Top recipes")
                    .font(ScpFont.sectionHeader)
                    .foregroundStyle(ScpColor.textMuted)
                    .textCase(.uppercase)
                ForEach(visible) { item in
                    NavigationLink {
                        ScpRecipeDetailView(
                            ranked: item,
                            kitchen: kitchen.kitchen,
                            groceryList: groceryList,
                            session: session,
                            favorites: favorites,
                            dependencies: dependencies,
                            onNeedAccount: onNeedAccount
                        )
                    } label: {
                        ScpRecipeCard(
                            ranked: item,
                            isFavorite: favorites.isFavorite(item.recipe.id),
                            onToggleFavorite: { toggleFavorite(item.recipe) },
                            onAddMissing: {
                                Task { await groceryList.addMissingItems(of: item.recipe, kitchen: kitchen.kitchen) }
                            }
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func toggleFavorite(_ recipe: ScpRecipe) {
        guard session.isAllowed(.saveRecipe) else {
            onNeedAccount("Create an account to save recipes you love.")
            return
        }
        Task { await favorites.toggle(recipe) }
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

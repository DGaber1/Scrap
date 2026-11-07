import SwiftUI
import ScrapCore

/// Recipes from other Scrap users, ranked against your kitchen.
struct ScpCommunityView: View {
    let community: ScpCommunityViewModel
    let kitchen: ScpKitchenViewModel
    let groceryList: ScpGroceryListViewModel
    let session: ScpSessionViewModel
    let favorites: ScpFavoritesViewModel
    let dependencies: ScpAppDependencies
    let onNeedAccount: (LocalizedStringKey) -> Void

    @State private var showsSubmit = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Community")
                            .font(ScpFont.screenTitle)
                            .foregroundStyle(ScpColor.textPrimary)
                        Spacer()
                        Button {
                            if session.isAllowed(.submitRecipe) {
                                showsSubmit = true
                            } else {
                                onNeedAccount("Create an account to share your own recipes.")
                            }
                        } label: {
                            Label("Share", systemImage: "plus")
                        }
                        .buttonStyle(ScpSoftButtonStyle())
                    }
                    .padding(.top, 8)
                    content
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .background(ScpColor.background)
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showsSubmit) {
                if let user = session.user {
                    ScpSubmitRecipeView(community: community, authorID: user.id)
                }
            }
        }
        .task { await community.load() }
    }

    @ViewBuilder
    private var content: some View {
        switch community.state {
        case .idle, .loading:
            HStack(spacing: 12) {
                ProgressView()
                Text("Loading recipes…").foregroundStyle(ScpColor.textMuted)
            }
        case .empty:
            ScpEmptyHint(text: "No community recipes yet. Be the first to share one.")
        case .failed(let error):
            VStack(alignment: .leading, spacing: 8) {
                Text(error.userMessage).foregroundStyle(ScpColor.missingIngredient)
                Button("Try again") { Task { await community.load() } }
                    .buttonStyle(ScpSoftButtonStyle())
            }
        case .loaded(let recipes):
            let ranked = dependencies.recipeMatcher.rank(recipes: recipes, kitchen: kitchen.kitchen)
            ForEach(ranked) { item in
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

    private func toggleFavorite(_ recipe: ScpRecipe) {
        guard session.isAllowed(.saveRecipe) else {
            onNeedAccount("Create an account to save recipes you love.")
            return
        }
        Task { await favorites.toggle(recipe) }
    }
}

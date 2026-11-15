import SwiftUI
import ScrapCore

/// Recipes from other Scrap users, ranked against your kitchen (REQ-F-15).
/// Opened from the Community tab, so it runs inside that tab's navigation stack.
struct ScpCommunityRecipesView: View {
    let community: ScpCommunityViewModel
    let kitchen: ScpKitchenViewModel
    let groceryList: ScpGroceryListViewModel
    let session: ScpSessionViewModel
    let favorites: ScpFavoritesViewModel
    let dependencies: ScpAppDependencies
    let onNeedAccount: (LocalizedStringKey) -> Void

    @State private var showsSubmit = false

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                content
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(ScpColor.background)
        .navigationTitle("Community recipes")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if session.isAllowed(.submitRecipe) {
                        showsSubmit = true
                    } else {
                        onNeedAccount("Create an account to share your own recipes.")
                    }
                } label: {
                    Label("Share a recipe", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showsSubmit) {
            if let user = session.user {
                ScpSubmitRecipeView(community: community, authorID: user.id)
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

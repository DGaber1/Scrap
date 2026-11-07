import SwiftUI
import ScrapCore

/// Profile tab: your account, My Kitchen, and saved recipes.
struct ScpProfileView: View {
    let kitchen: ScpKitchenViewModel
    let groceryList: ScpGroceryListViewModel
    let session: ScpSessionViewModel
    let favorites: ScpFavoritesViewModel
    let dependencies: ScpAppDependencies
    let onNeedAccount: (LocalizedStringKey) -> Void

    var body: some View {
        NavigationStack {
            List {
                Section {
                    if let user = session.user {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(user.displayName)
                                .font(.headline)
                            Text(user.email)
                                .font(ScpFont.caption)
                                .foregroundStyle(ScpColor.textMuted)
                        }
                        Button("Sign out", role: .destructive) {
                            Task { await session.signOut() }
                        }
                    } else {
                        Button("Sign in or create an account") {
                            onNeedAccount("Save recipes, share your own, and keep your lists.")
                        }
                        .foregroundStyle(ScpColor.brand)
                    }
                }
                .listRowBackground(ScpColor.card)

                Section {
                    NavigationLink {
                        ScpKitchenView(kitchen: kitchen, dependencies: dependencies)
                    } label: {
                        Label("My Kitchen", systemImage: "refrigerator")
                    }
                    NavigationLink {
                        savedRecipes
                    } label: {
                        Label("Saved recipes", systemImage: "heart")
                    }
                }
                .listRowBackground(ScpColor.card)
            }
            .scrollContentBackground(.hidden)
            .background(ScpColor.background)
            .navigationTitle("Profile")
        }
    }

    private var savedRecipes: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                if favorites.recipes.isEmpty {
                    ScpEmptyHint(text: "Tap the heart on a recipe to save it here.")
                } else {
                    let ranked = dependencies.recipeMatcher.rank(recipes: favorites.recipes, kitchen: kitchen.kitchen)
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
                                isFavorite: true,
                                onToggleFavorite: { Task { await favorites.toggle(item.recipe) } },
                                onAddMissing: {
                                    Task { await groceryList.addMissingItems(of: item.recipe, kitchen: kitchen.kitchen) }
                                }
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(16)
        }
        .background(ScpColor.background)
        .navigationTitle("Saved recipes")
    }
}

import Foundation
import SwiftUI
import ScrapCore

/// The Community tab: what people are cooking (UC-10, REQ-F-16).
/// Guests can browse For You; liking, saving, commenting, posting, and Friends need an account.
struct ScpFeedView: View {
    let feed: ScpFeedViewModel
    let friends: ScpFriendsViewModel
    let community: ScpCommunityViewModel
    let home: ScpHomeViewModel
    let kitchen: ScpKitchenViewModel
    let groceryList: ScpGroceryListViewModel
    let session: ScpSessionViewModel
    let favorites: ScpFavoritesViewModel
    let dependencies: ScpAppDependencies
    let onNeedAccount: (LocalizedStringKey) -> Void

    @State private var showsCreatePost = false
    @State private var showsFriends = false
    @State private var showsSearch = false
    @State private var commentsTarget: ScpPost?
    @State private var profileTarget: ScpProfile?

    private var isGuest: Bool { session.user == nil }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 18) {
                    header
                    if showsSearch {
                        searchField
                    }
                    ScpSegmentedControl(
                        options: ScpFeedScope.allCases,
                        selection: Binding(get: { feed.scope }, set: { feed.select($0) }),
                        title: { scope in LocalizedStringKey(scope == .forYou ? "For You" : "Friends") },
                        locked: isGuest ? [.friends] : [],
                        onLockedTap: { _ in onNeedAccount("Create an account to see what your friends are cooking.") }
                    )
                    if !isGuest {
                        composer
                    }
                    communityRecipesLink
                    if let notice = feed.notice {
                        noticeBanner(notice)
                    }
                    content
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(ScpColor.background)
            .refreshable { await reload() }
            .safeAreaInset(edge: .bottom) {
                if isGuest {
                    ScpGuestSignUpBanner(text: "Sign up to like, save and comment") {
                        onNeedAccount("Create an account to like, save, and comment on posts.")
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(item: $profileTarget) { profile in
                ScpFriendProfileView(profile: profile, friends: friends, feed: feed)
            }
            .sheet(isPresented: $showsCreatePost) {
                if let user = session.user {
                    ScpCreatePostView(
                        feed: feed,
                        community: community,
                        authorID: user.id,
                        recipeChoices: recipeChoices
                    )
                }
            }
            .sheet(isPresented: $showsFriends) {
                ScpFriendsView(friends: friends, feed: feed)
            }
            .sheet(item: $commentsTarget) { post in
                ScpCommentsSheet(
                    postID: post.id,
                    feed: feed,
                    canComment: session.isAllowed(.comment),
                    onNeedAccount: {
                        // Close this sheet first; SwiftUI can't show the account sheet on top of it.
                        commentsTarget = nil
                        Task {
                            try? await Task.sleep(for: .milliseconds(450))
                            onNeedAccount("Create an account to comment on posts.")
                        }
                    }
                )
                .presentationDetents([.medium, .large])
            }
        }
        .task(id: session.user?.id) { await reload() }
        .onChange(of: friends.friendIDs) { _, ids in
            feed.updateFriends(ids, profiles: friends.profilesByID)
        }
        .task(id: feed.notice) {
            guard feed.notice != nil else { return }
            try? await Task.sleep(for: .seconds(3))
            guard !Task.isCancelled else { return }
            feed.notice = nil
        }
    }

    private func reload() async {
        await friends.load(user: session.user, equipment: kitchen.kitchen.equipment)
        await feed.load(viewerID: friends.me?.id, friendIDs: friends.friendIDs, profiles: friends.profilesByID)
    }

    // MARK: Header

    private var header: some View {
        HStack(spacing: 18) {
            Text("Community")
                .font(ScpFont.screenTitle)
                .foregroundStyle(ScpColor.textPrimary)
            Spacer()
            Button {
                withAnimation(.snappy) { showsSearch.toggle() }
                if !showsSearch { feed.search("") }
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.title2)
                    .foregroundStyle(ScpColor.textPrimary)
            }
            .accessibilityLabel("Search posts")
            Button {
                if session.isAllowed(.addFriend) {
                    showsFriends = true
                } else {
                    onNeedAccount("Create an account to add friends.")
                }
            } label: {
                Image(systemName: "person.badge.plus")
                    .font(.title2)
                    .foregroundStyle(ScpColor.brand)
                    .overlay(alignment: .topTrailing) {
                        if !friends.requests.isEmpty {
                            Circle()
                                .fill(ScpColor.missingIngredient)
                                .frame(width: 9, height: 9)
                                .offset(x: 2, y: -2)
                        }
                    }
            }
            .accessibilityLabel(friends.requests.isEmpty ? Text("Friends") : Text("Friends, \(friends.requests.count) new requests"))
        }
        .padding(.top, 8)
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(ScpColor.textMuted)
            TextField(
                "Search dishes, people, or recipes",
                text: Binding(get: { feed.searchText }, set: { feed.search($0) })
            )
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
        }
        .padding(14)
        .background(ScpColor.card, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(ScpColor.divider))
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    /// "Share what you cooked…" row that opens Create Post.
    private var composer: some View {
        Button {
            if session.isAllowed(.sharePost) {
                showsCreatePost = true
            } else {
                onNeedAccount("Create an account to share what you cooked.")
            }
        } label: {
            HStack(spacing: 12) {
                ScpAvatarView(username: friends.me?.username ?? "?", size: 40)
                Text("Share what you cooked…")
                    .foregroundStyle(ScpColor.textMuted)
                Spacer()
                Image(systemName: "camera")
                    .font(.title3)
                    .foregroundStyle(ScpColor.brand)
            }
            .padding(14)
            .background(ScpColor.card, in: RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(ScpColor.divider))
        }
        .buttonStyle(.plain)
    }

    private var communityRecipesLink: some View {
        NavigationLink {
            ScpCommunityRecipesView(
                community: community,
                kitchen: kitchen,
                groceryList: groceryList,
                session: session,
                favorites: favorites,
                dependencies: dependencies,
                onNeedAccount: onNeedAccount
            )
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "book.closed")
                Text("Recipes from the community")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(ScpColor.brand)
            .padding(12)
            .background(ScpColor.softGreen, in: RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }

    private func noticeBanner(_ text: String) -> some View {
        Label(text, systemImage: "checkmark.circle")
            .font(ScpFont.detail)
            .foregroundStyle(ScpColor.brand)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(ScpColor.softGreen, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: Posts

    @ViewBuilder
    private var content: some View {
        switch feed.state {
        case .idle, .loading:
            HStack(spacing: 12) {
                ProgressView()
                Text("Loading posts…").foregroundStyle(ScpColor.textMuted)
            }
            .padding(.top, 8)
        case .empty:
            emptyState
        case .failed(let error):
            VStack(alignment: .leading, spacing: 8) {
                Text(error.userMessage).foregroundStyle(ScpColor.missingIngredient)
                Button("Try again") { Task { await reload() } }
                    .buttonStyle(ScpSoftButtonStyle())
            }
        case .loaded(let posts):
            ForEach(posts) { post in
                ScpPostCard(
                    post: post,
                    author: feed.author(of: post),
                    viewerID: feed.currentViewerID,
                    rankedRecipe: post.linkedRecipe.map { rank($0) },
                    onLike: { likeTapped(post) },
                    onComment: { commentsTarget = post },
                    onSave: { saveTapped(post) },
                    onReport: { Task { await feed.report(post) } },
                    onAuthorTap: { profileTarget = feed.author(of: post) }
                ) { ranked in
                    ScpRecipeDetailView(
                        ranked: ranked,
                        kitchen: kitchen.kitchen,
                        groceryList: groceryList,
                        session: session,
                        favorites: favorites,
                        dependencies: dependencies,
                        onNeedAccount: onNeedAccount
                    )
                }
                Divider().overlay(ScpColor.divider)
            }
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !feed.searchText.isEmpty {
                ScpEmptyHint(text: "No posts match your search.")
            } else if feed.scope == .friends {
                ScpEmptyHint(text: "Your friends haven't posted yet. Add more friends or share your own dish.")
                Button("Find friends") { showsFriends = true }
                    .buttonStyle(ScpSoftButtonStyle())
            } else {
                ScpEmptyHint(text: "No posts yet. Be the first to share what you cooked!")
            }
        }
    }

    private func likeTapped(_ post: ScpPost) {
        guard session.isAllowed(.likePost) else {
            onNeedAccount("Create an account to like posts.")
            return
        }
        Task { await feed.toggleLike(post) }
    }

    private func saveTapped(_ post: ScpPost) {
        guard session.isAllowed(.savePost) else {
            onNeedAccount("Create an account to save posts.")
            return
        }
        Task { await feed.toggleSave(post) }
    }

    private func rank(_ recipe: ScpRecipe) -> ScpRankedRecipe {
        dependencies.recipeMatcher.rank(recipes: [recipe], kitchen: kitchen.kitchen).first
            ?? ScpRankedRecipe(recipe: recipe, matchPercent: 0, missingIngredients: recipe.ingredients)
    }

    /// Recipes to offer when linking a post: current results, then favorites, then community recipes.
    private var recipeChoices: [ScpRankedRecipe] {
        var seen: Set<String> = []
        var choices: [ScpRankedRecipe] = []
        var candidates = home.visibleRecipes
        candidates += dependencies.recipeMatcher.rank(recipes: favorites.recipes, kitchen: kitchen.kitchen)
        if case .loaded(let recipes) = community.state {
            candidates += dependencies.recipeMatcher.rank(recipes: recipes, kitchen: kitchen.kitchen)
        }
        for candidate in candidates where seen.insert(candidate.id).inserted {
            choices.append(candidate)
        }
        return choices
    }
}

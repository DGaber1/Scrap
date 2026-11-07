import SwiftUI
import ScrapCore

/// The five tabs of the app and the custom bar that switches them.
enum ScpTab: Hashable {
    case home, grocery, community, profile
}

/// Owns the screen-level view models so state survives tab switches.
struct ScpRootView: View {
    private let dependencies: ScpAppDependencies
    @State private var selection: ScpTab = .home
    @State private var kitchen: ScpKitchenViewModel
    @State private var groceryList: ScpGroceryListViewModel
    @State private var home: ScpHomeViewModel
    @State private var session: ScpSessionViewModel
    @State private var favorites: ScpFavoritesViewModel
    @State private var community: ScpCommunityViewModel
    @State private var showsScanSheet = false
    @State private var accountReason: LocalizedStringKey?

    init(dependencies: ScpAppDependencies) {
        self.dependencies = dependencies
        _kitchen = State(
            initialValue: ScpKitchenViewModel(
                repository: dependencies.kitchenRepository,
                reminderScheduler: dependencies.reminderScheduler
            )
        )
        _session = State(initialValue: ScpSessionViewModel(authService: dependencies.authService))
        _favorites = State(initialValue: ScpFavoritesViewModel(repository: dependencies.favoritesRepository))
        _community = State(initialValue: ScpCommunityViewModel(repository: dependencies.communityRepository))
        _groceryList = State(
            initialValue: ScpGroceryListViewModel(
                repository: dependencies.groceryListRepository,
                builder: dependencies.groceryListBuilder
            )
        )
        _home = State(
            initialValue: ScpHomeViewModel(
                recipeRepository: dependencies.recipeRepository,
                matcher: dependencies.recipeMatcher
            )
        )
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScpColor.background.ignoresSafeArea()
            Group {
                switch selection {
                case .home:
                    ScpHomeView(
                        home: home,
                        kitchen: kitchen,
                        groceryList: groceryList,
                        session: session,
                        favorites: favorites,
                        dependencies: dependencies,
                        onNeedAccount: { accountReason = $0 }
                    )
                case .grocery:
                    ScpGroceryListView(groceryList: groceryList)
                case .community:
                    ScpCommunityView(
                        community: community,
                        kitchen: kitchen,
                        groceryList: groceryList,
                        session: session,
                        favorites: favorites,
                        dependencies: dependencies,
                        onNeedAccount: { accountReason = $0 }
                    )
                case .profile:
                    ScpProfileView(
                        kitchen: kitchen,
                        groceryList: groceryList,
                        session: session,
                        favorites: favorites,
                        dependencies: dependencies,
                        onNeedAccount: { accountReason = $0 }
                    )
                }
            }
            .safeAreaInset(edge: .bottom) {
                ScpTabBar(selection: $selection, onScan: { showsScanSheet = true })
            }
        }
        .task {
            await session.load()
            await kitchen.load()
            await groceryList.load()
            await favorites.load()
        }
        .sheet(
            isPresented: Binding(
                get: { accountReason != nil },
                set: { if !$0 { accountReason = nil } }
            )
        ) {
            ScpAccountView(session: session, reason: accountReason ?? "")
        }
        .sheet(isPresented: $showsScanSheet) {
            ScpReceiptUploadView()
        }
    }
}

/// The bottom bar: Home, Grocery, a raised "Scan receipt" button, Community, Profile.
struct ScpTabBar: View {
    @Binding var selection: ScpTab
    let onScan: () -> Void

    var body: some View {
        HStack(alignment: .bottom) {
            tabButton(.home, title: "Home", systemImage: "house")
            tabButton(.grocery, title: "Grocery", systemImage: "cart")
            Button(action: onScan) {
                VStack(spacing: 4) {
                    Image(systemName: "plus")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 52, height: 52)
                        .background(ScpColor.brand, in: Circle())
                        .shadow(radius: 3, y: 2)
                    Text("Scan receipt")
                        .font(.caption2)
                        .foregroundStyle(ScpColor.textMuted)
                }
                .offset(y: -14)
            }
            .frame(maxWidth: .infinity)
            .accessibilityLabel("Scan receipt")
            tabButton(.community, title: "Community", systemImage: "person.2")
            tabButton(.profile, title: "Profile", systemImage: "person.crop.circle")
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .background(ScpColor.card)
        .overlay(alignment: .top) { Divider() }
    }

    private func tabButton(_ tab: ScpTab, title: LocalizedStringKey, systemImage: String) -> some View {
        Button {
            selection = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.title3)
                Text(title)
                    .font(.caption2)
            }
            .foregroundStyle(selection == tab ? ScpColor.brand : ScpColor.textMuted)
            .frame(maxWidth: .infinity)
        }
        .accessibilityAddTraits(selection == tab ? .isSelected : [])
    }
}

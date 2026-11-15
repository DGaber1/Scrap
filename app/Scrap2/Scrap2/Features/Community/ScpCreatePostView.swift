import Foundation
import SwiftUI
import PhotosUI
import ScrapCore

/// Share a dish you cooked (UC-10): photos, a caption, an optional recipe, and who can see it.
struct ScpCreatePostView: View {
    private enum RecipeMode: String, CaseIterable, Identifiable {
        case scrap = "From Scrap"
        case own = "My own recipe"
        var id: String { rawValue }
    }

    let feed: ScpFeedViewModel
    let community: ScpCommunityViewModel
    let authorID: UUID
    /// Recipes the user might have made: their current results, favorites, and community recipes.
    let recipeChoices: [ScpRankedRecipe]
    @Environment(\.dismiss) private var dismiss

    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var photos: [ScpPostPhoto] = []
    @State private var caption = ""
    @State private var recipeMode: RecipeMode = .scrap
    @State private var selectedRecipe: ScpRankedRecipe?
    @State private var ownRecipeTitle = ""
    @State private var visibility: ScpPostVisibility = .friends
    @State private var showsRecipePicker = false
    @State private var showsSubmitRecipe = false
    @State private var isPosting = false

    private static let maxPhotos = 4

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    photoRow
                    captionField
                    recipeSection
                    visibilitySection
                    if feed.publishError != nil {
                        Text("Add a photo or a caption before posting.")
                            .font(ScpFont.caption)
                            .foregroundStyle(ScpColor.missingIngredient)
                    }
                }
                .padding(16)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(ScpColor.background)
            .safeAreaInset(edge: .bottom) {
                Button {
                    post()
                } label: {
                    Text(isPosting ? "Posting…" : "Post")
                }
                .buttonStyle(ScpPrimaryButtonStyle())
                .disabled(isPosting || !canPost)
                .opacity(canPost ? 1 : 0.5)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(ScpColor.background)
            }
            .navigationTitle("Create post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .accessibilityLabel("Cancel")
                }
            }
            .onChange(of: pickerItems) { _, items in
                Task { await loadPhotos(from: items) }
            }
            .sheet(isPresented: $showsRecipePicker) {
                ScpRecipePickerSheet(choices: recipeChoices) { selectedRecipe = $0 }
                    .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showsSubmitRecipe) {
                ScpSubmitRecipeView(community: community, authorID: authorID)
            }
            .onAppear { feed.clearPublishError() }
        }
    }

    private var canPost: Bool {
        !photos.isEmpty || !caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: Photos

    private var photoRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(photos.enumerated()), id: \.offset) { index, photo in
                    ScpPostPhotoView(photo: photo)
                        .frame(width: 110, height: 110)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .overlay(alignment: .topTrailing) {
                            Button {
                                removePhoto(at: index)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title3)
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.white, .black.opacity(0.5))
                            }
                            .padding(6)
                            .accessibilityLabel("Remove photo")
                        }
                }
                if photos.count < Self.maxPhotos {
                    PhotosPicker(
                        selection: $pickerItems,
                        maxSelectionCount: Self.maxPhotos,
                        matching: .images
                    ) {
                        VStack(spacing: 8) {
                            Image(systemName: "camera")
                                .font(.title2)
                            Text("Add photo")
                                .font(ScpFont.detail)
                        }
                        .foregroundStyle(ScpColor.textMuted)
                        .frame(width: 110, height: 110)
                        .background(ScpColor.card, in: RoundedRectangle(cornerRadius: 18))
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(ScpColor.divider))
                    }
                }
            }
        }
    }

    private func loadPhotos(from items: [PhotosPickerItem]) async {
        var loaded: [ScpPostPhoto] = []
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self) {
                loaded.append(.data(data))
            }
        }
        photos = loaded
    }

    /// Removes a photo. Every photo comes from the picker, so removing its picker item
    /// reloads the remaining photos through `onChange(of: pickerItems)`.
    private func removePhoto(at index: Int) {
        if pickerItems.indices.contains(index) {
            pickerItems.remove(at: index)
        } else if photos.indices.contains(index) {
            photos.remove(at: index)
        }
    }

    // MARK: Caption

    private var captionField: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $caption)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 110)
                .padding(10)
            if caption.isEmpty {
                Text("What did you make? Any tips?")
                    .foregroundStyle(ScpColor.textMuted)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 18)
                    .allowsHitTesting(false)
            }
        }
        .background(ScpColor.card, in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(ScpColor.divider))
    }

    // MARK: Recipe

    private var recipeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Which recipe did you make? (optional)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(ScpColor.textMuted)
            ScpSegmentedControl(
                options: RecipeMode.allCases,
                selection: $recipeMode,
                title: { LocalizedStringKey($0.rawValue) }
            )
            switch recipeMode {
            case .scrap:
                if let selectedRecipe {
                    selectedRecipeCard(selectedRecipe)
                } else {
                    Button {
                        showsRecipePicker = true
                    } label: {
                        Label("Choose a recipe", systemImage: "magnifyingglass")
                    }
                    .buttonStyle(ScpSoftButtonStyle())
                }
            case .own:
                TextField("Recipe name, like Grandma's chili", text: $ownRecipeTitle)
                    .padding(14)
                    .background(ScpColor.card, in: RoundedRectangle(cornerRadius: 14))
                Button {
                    showsSubmitRecipe = true
                } label: {
                    Label("Write and submit a new recipe", systemImage: "plus")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(ScpColor.brand)
                }
            }
        }
    }

    private func selectedRecipeCard(_ ranked: ScpRankedRecipe) -> some View {
        HStack(spacing: 12) {
            AsyncImage(url: ranked.recipe.imageURL) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                ZStack {
                    ScpColor.chip
                    Image(systemName: "fork.knife").foregroundStyle(ScpColor.textMuted)
                }
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 2) {
                Text(ranked.recipe.title)
                    .font(.headline)
                    .foregroundStyle(ScpColor.textPrimary)
                    .lineLimit(2)
                Text(
                    "\(ranked.matchPercent.formatted(.percent.precision(.fractionLength(0)))) match · \(ranked.recipe.totalTimeMinutes) min"
                )
                .font(ScpFont.detail)
                .foregroundStyle(ScpColor.textMuted)
            }
            Spacer()
            Button {
                selectedRecipe = nil
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(ScpColor.textMuted)
            }
            .accessibilityLabel("Remove recipe")
        }
        .padding(12)
        .background(ScpColor.card, in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(ScpColor.divider))
    }

    // MARK: Visibility

    private var visibilitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Share with")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(ScpColor.textMuted)
            HStack(spacing: 10) {
                visibilityChip(.friends, title: "Friends")
                visibilityChip(.everyone, title: "Everyone")
            }
        }
    }

    private func visibilityChip(_ value: ScpPostVisibility, title: LocalizedStringKey) -> some View {
        Button {
            visibility = value
        } label: {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(visibility == value ? Color.white : ScpColor.textPrimary)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(visibility == value ? ScpColor.brand : ScpColor.chip, in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(visibility == value ? .isSelected : [])
    }

    // MARK: Posting

    private func post() {
        isPosting = true
        Task {
            let worked = await feed.publish(
                caption: caption,
                photos: photos,
                linkedRecipe: recipeMode == .scrap ? selectedRecipe?.recipe : nil,
                ownRecipeTitle: recipeMode == .own ? ownRecipeTitle : nil,
                visibility: visibility
            )
            isPosting = false
            if worked { dismiss() }
        }
    }
}

/// Pick which Scrap recipe a post is about.
struct ScpRecipePickerSheet: View {
    let choices: [ScpRankedRecipe]
    let onPick: (ScpRankedRecipe) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    var body: some View {
        NavigationStack {
            List {
                if filtered.isEmpty {
                    Text("No recipes yet. Add ingredients on Home to see recipes you can make.")
                        .foregroundStyle(ScpColor.textMuted)
                        .listRowBackground(ScpColor.card)
                }
                ForEach(filtered) { ranked in
                    Button {
                        onPick(ranked)
                        dismiss()
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(ranked.recipe.title)
                                .foregroundStyle(ScpColor.textPrimary)
                            Text("\(ranked.matchPercent.formatted(.percent.precision(.fractionLength(0)))) match")
                                .font(ScpFont.caption)
                                .foregroundStyle(ScpColor.matchGreen)
                        }
                    }
                    .listRowBackground(ScpColor.card)
                }
            }
            .scrollContentBackground(.hidden)
            .background(ScpColor.background)
            .searchable(text: $query, prompt: "Search recipes")
            .navigationTitle("Which recipe?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private var filtered: [ScpRankedRecipe] {
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !needle.isEmpty else { return choices }
        return choices.filter { $0.recipe.title.lowercased().contains(needle) }
    }
}

/// The green pill segmented control from the designs, used for For You / Friends
/// and From Scrap / My own recipe.
struct ScpSegmentedControl<Option: Hashable>: View {
    let options: [Option]
    @Binding var selection: Option
    let title: (Option) -> LocalizedStringKey
    /// Options that show a lock and call `onLockedTap` instead of selecting.
    var locked: Set<Option> = []
    var onLockedTap: (Option) -> Void = { _ in }

    var body: some View {
        HStack(spacing: 4) {
            ForEach(options, id: \.self) { option in
                let isSelected = option == selection
                let isLocked = locked.contains(option)
                Button {
                    if isLocked {
                        onLockedTap(option)
                    } else {
                        selection = option
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(title(option))
                        if isLocked {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                        }
                    }
                    .font(.headline)
                    .foregroundStyle(isSelected ? Color.white : ScpColor.textMuted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(isSelected ? ScpColor.brand : Color.clear, in: RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .padding(4)
        .background(ScpColor.chip, in: RoundedRectangle(cornerRadius: 18))
    }
}

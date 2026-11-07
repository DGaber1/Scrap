import SwiftUI
import ScrapCore

/// One recipe: photo, match, stats, and either its ingredients or its steps.
struct ScpRecipeDetailView: View {
    private enum DetailSection: String, CaseIterable, Identifiable {
        case ingredients = "Ingredients"
        case instructions = "Instructions"
        var id: String { rawValue }
    }

    @State private var viewModel: ScpRecipeDetailViewModel
    @State private var section: DetailSection = .ingredients
    @State private var justAdded = false
    let kitchen: ScpKitchen
    let groceryList: ScpGroceryListViewModel

    init(
        ranked: ScpRankedRecipe,
        kitchen: ScpKitchen,
        groceryList: ScpGroceryListViewModel,
        dependencies: ScpAppDependencies
    ) {
        self.kitchen = kitchen
        self.groceryList = groceryList
        _viewModel = State(
            initialValue: ScpRecipeDetailViewModel(
                ranked: ranked,
                kitchen: kitchen,
                recipeRepository: dependencies.recipeRepository
            )
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                content
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .background(ScpColor.background)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) { addButton }
        .task { await viewModel.load() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            HStack(spacing: 12) {
                ProgressView()
                Text("Loading recipe…").foregroundStyle(ScpColor.textMuted)
            }
            .padding(.top, 24)

        case .empty:
            ScpEmptyHint(text: "This recipe has no details yet.")

        case .failed(let error):
            VStack(alignment: .leading, spacing: 8) {
                Text(error.userMessage).foregroundStyle(ScpColor.missingIngredient)
                Button("Try again") { Task { await viewModel.load() } }
                    .buttonStyle(ScpSoftButtonStyle())
            }
            .padding(.top, 24)

        case .loaded(let recipe):
            hero(for: recipe)
            Text(recipe.title)
                .font(ScpFont.screenTitle)
                .foregroundStyle(ScpColor.textPrimary)
            matchBar
            statsCard(for: recipe)
            Picker("Section", selection: $section) {
                ForEach(DetailSection.allCases) { Text(LocalizedStringKey($0.rawValue)).tag($0) }
            }
            .pickerStyle(.segmented)
            switch section {
            case .ingredients: ingredients(of: recipe)
            case .instructions: instructions(of: recipe)
            }
        }
    }

    private func hero(for recipe: ScpRecipe) -> some View {
        AsyncImage(url: recipe.imageURL) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            ScpColor.chip
        }
        .frame(height: 220)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .accessibilityHidden(true)
    }

    private var matchBar: some View {
        HStack(spacing: 10) {
            ProgressView(value: viewModel.matchPercent)
                .tint(ScpColor.matchGreen)
            Text(viewModel.matchPercent, format: .percent.precision(.fractionLength(0)))
                .font(ScpFont.detail.weight(.semibold))
                .foregroundStyle(ScpColor.matchGreen)
            Text("match")
                .font(ScpFont.caption)
                .foregroundStyle(ScpColor.textMuted)
        }
    }

    private func statsCard(for recipe: ScpRecipe) -> some View {
        HStack(alignment: .top) {
            stat(title: "Time", value: Text("\(recipe.totalTimeMinutes) min"))
            Divider()
            VStack(spacing: 6) {
                Text("Servings")
                    .font(ScpFont.caption)
                    .foregroundStyle(ScpColor.textMuted)
                HStack(spacing: 10) {
                    Button { viewModel.decreaseServings() } label: {
                        Image(systemName: "minus.circle")
                    }
                    .accessibilityLabel("Fewer servings")
                    Text("\(viewModel.servings)")
                        .font(.headline)
                    Button { viewModel.increaseServings() } label: {
                        Image(systemName: "plus.circle")
                    }
                    .accessibilityLabel("More servings")
                }
                .foregroundStyle(ScpColor.brand)
            }
            .frame(maxWidth: .infinity)
            Divider()
            stat(
                title: "To buy",
                value: Text("≈ \(viewModel.estimatedMissingCost(in: recipe), format: .currency(code: "USD"))")
            )
        }
        .padding(14)
        .background(ScpColor.card, in: RoundedRectangle(cornerRadius: 16))
    }

    private func stat(title: LocalizedStringKey, value: Text) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(ScpFont.caption)
                .foregroundStyle(ScpColor.textMuted)
            value
                .font(.headline)
                .foregroundStyle(ScpColor.textPrimary)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func ingredients(of recipe: ScpRecipe) -> some View {
        let missing = viewModel.missingIngredients(in: recipe)
        let available = viewModel.availableIngredients(in: recipe)

        if !missing.isEmpty {
            Text("Missing")
                .font(ScpFont.sectionHeader)
                .foregroundStyle(ScpColor.missingIngredient)
                .textCase(.uppercase)
            ForEach(missing) { item in
                HStack {
                    Text(item.ingredient.name.capitalized)
                        .foregroundStyle(ScpColor.missingIngredient)
                    Spacer()
                    Text(ScpQuantityFormatter.amountText(for: item.quantity))
                        .foregroundStyle(ScpColor.textMuted)
                }
                .padding(12)
                .background(ScpColor.missingBackground, in: RoundedRectangle(cornerRadius: 12))
            }
        }

        if !viewModel.missingEquipment.isEmpty {
            Text("Equipment you need")
                .font(ScpFont.sectionHeader)
                .foregroundStyle(ScpColor.missingIngredient)
                .textCase(.uppercase)
            ForEach(viewModel.missingEquipment) { equipment in
                Text(equipment.name)
                    .foregroundStyle(ScpColor.missingIngredient)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(ScpColor.missingBackground, in: RoundedRectangle(cornerRadius: 12))
            }
        }

        if !available.isEmpty {
            Text("You have")
                .font(ScpFont.sectionHeader)
                .foregroundStyle(ScpColor.brand)
                .textCase(.uppercase)
            ForEach(available) { item in
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(ScpColor.matchGreen)
                    Text(item.ingredient.name.capitalized)
                        .foregroundStyle(ScpColor.textPrimary)
                    Spacer()
                    Text(ScpQuantityFormatter.amountText(for: item.quantity))
                        .foregroundStyle(ScpColor.textMuted)
                }
                .padding(12)
                .background(ScpColor.card, in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    @ViewBuilder
    private func instructions(of recipe: ScpRecipe) -> some View {
        if recipe.instructions.isEmpty {
            ScpEmptyHint(text: "No instructions were provided for this recipe.")
        } else {
            ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(index + 1)")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                        .background(ScpColor.brand, in: Circle())
                    Text(step)
                        .foregroundStyle(ScpColor.textPrimary)
                }
            }
        }
    }

    @ViewBuilder
    private var addButton: some View {
        if case .loaded(let recipe) = viewModel.state {
            let count = viewModel.missingIngredients(in: recipe).count
            if count > 0 {
                Button {
                    Task {
                        justAdded = await groceryList.addMissingItems(
                            of: recipe,
                            kitchen: kitchen,
                            servings: viewModel.servings
                        )
                    }
                } label: {
                    Text(justAdded ? "Added to grocery list" : "Add \(count) missing items to grocery list")
                }
                .buttonStyle(ScpPrimaryButtonStyle())
                .disabled(justAdded)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(ScpColor.background)
            }
        }
    }
}

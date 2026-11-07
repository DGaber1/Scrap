import SwiftUI
import ScrapCore

/// The filter button's sheet: sort order and what to show.
struct ScpFilterSheet: View {
    @Binding var options: ScpRecipeFilterOptions
    let onReset: () -> Void
    @Environment(\.dismiss) private var dismiss

    private static let timeChoices = [15, 30, 45, 60]

    var body: some View {
        NavigationStack {
            Form {
                Section("Sort by") {
                    Picker("Sort by", selection: $options.sortOrder) {
                        Text("Best match").tag(ScpRecipeFilterOptions.SortOrder.bestMatch)
                        Text("Fastest").tag(ScpRecipeFilterOptions.SortOrder.fastest)
                        Text("Lowest cost").tag(ScpRecipeFilterOptions.SortOrder.lowestCost)
                        Text("Highest protein").tag(ScpRecipeFilterOptions.SortOrder.highestProtein)
                    }
                }

                Section("Time and difficulty") {
                    Picker("Total time", selection: $options.maxTotalMinutes) {
                        Text("Any").tag(Int?.none)
                        ForEach(Self.timeChoices, id: \.self) { minutes in
                            Text("Up to \(minutes) min").tag(Int?.some(minutes))
                        }
                    }
                    Picker("Difficulty", selection: $options.maxDifficulty) {
                        Text("Any").tag(ScpRecipe.Difficulty?.none)
                        Text("Easy").tag(ScpRecipe.Difficulty?.some(.easy))
                        Text("Up to medium").tag(ScpRecipe.Difficulty?.some(.medium))
                    }
                }

                Section("Meal and cuisine") {
                    Picker("Meal", selection: $options.mealType) {
                        Text("Any").tag(ScpMealType?.none)
                        ForEach(ScpMealType.allCases, id: \.self) { meal in
                            Text(meal.rawValue.capitalized).tag(ScpMealType?.some(meal))
                        }
                    }
                    Picker("Cuisine", selection: $options.cuisine) {
                        Text("Any").tag(ScpCuisine?.none)
                        ForEach(ScpCuisine.allCases, id: \.self) { cuisine in
                            Text(cuisine.rawValue.capitalized).tag(ScpCuisine?.some(cuisine))
                        }
                    }
                }

                Section("Dietary") {
                    ForEach(ScpDietaryRestriction.allCases, id: \.self) { restriction in
                        Toggle(
                            Self.title(for: restriction),
                            isOn: Binding(
                                get: { options.requiredRestrictions.contains(restriction) },
                                set: { isOn in
                                    if isOn {
                                        options.requiredRestrictions.insert(restriction)
                                    } else {
                                        options.requiredRestrictions.remove(restriction)
                                    }
                                }
                            )
                        )
                    }
                }

                Section("Equipment") {
                    Toggle("Hide recipes that need equipment I don't have", isOn: $options.hidesRecipesNeedingMissingEquipment)
                }

                Section {
                    Button("Reset filters", role: .destructive, action: onReset)
                }
            }
            .scrollContentBackground(.hidden)
            .background(ScpColor.background)
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private static func title(for restriction: ScpDietaryRestriction) -> LocalizedStringKey {
        switch restriction {
        case .vegetarian: return "Vegetarian"
        case .vegan: return "Vegan"
        case .glutenFree: return "Gluten-free"
        case .dairyFree: return "Dairy-free"
        case .nutFree: return "Nut-free"
        }
    }
}

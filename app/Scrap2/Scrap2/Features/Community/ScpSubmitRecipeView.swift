import SwiftUI
import ScrapCore

/// A form for sharing your own recipe. New recipes wait for review before others see them.
struct ScpSubmitRecipeView: View {
    let community: ScpCommunityViewModel
    let authorID: UUID
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var servings = 2
    @State private var prepMinutes = 10
    @State private var cookMinutes = 20
    @State private var ingredientText = ""
    @State private var instructionText = ""
    @State private var didSubmit = false

    var body: some View {
        NavigationStack {
            Form {
                if didSubmit {
                    Section {
                        Label("Thanks! Your recipe is waiting for review.", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(ScpColor.brand)
                    }
                } else {
                    Section("Recipe") {
                        TextField("Title", text: $title)
                        Stepper("Servings: \(servings)", value: $servings, in: 1...24)
                        Stepper("Prep: \(prepMinutes) min", value: $prepMinutes, in: 0...240, step: 5)
                        Stepper("Cook: \(cookMinutes) min", value: $cookMinutes, in: 0...480, step: 5)
                    }
                    Section("Ingredients (one per line, like 2 cups flour)") {
                        TextEditor(text: $ingredientText)
                            .frame(minHeight: 120)
                    }
                    Section("Steps (one per line)") {
                        TextEditor(text: $instructionText)
                            .frame(minHeight: 120)
                    }
                    if community.submitError != nil {
                        Text("Add a title, at least one ingredient, and at least one step.")
                            .font(ScpFont.caption)
                            .foregroundStyle(ScpColor.missingIngredient)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(ScpColor.background)
            .navigationTitle("Share a recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(didSubmit ? "Close" : "Cancel") { dismiss() }
                }
                if !didSubmit {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Submit") {
                            Task {
                                didSubmit = await community.submit(
                                    title: title,
                                    servings: servings,
                                    prepMinutes: prepMinutes,
                                    cookMinutes: cookMinutes,
                                    ingredientText: ingredientText,
                                    instructionText: instructionText,
                                    authorID: authorID
                                )
                            }
                        }
                    }
                }
            }
            .onAppear { community.clearSubmitError() }
        }
    }
}

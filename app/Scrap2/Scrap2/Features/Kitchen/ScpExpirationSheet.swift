import SwiftUI
import ScrapCore

/// Pick the date an ingredient goes bad. Scrap reminds you a couple of days before.
struct ScpExpirationSheet: View {
    let item: ScpPantryItem
    let onSave: (Date) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var date: Date

    init(item: ScpPantryItem, onSave: @escaping (Date) -> Void) {
        self.item = item
        self.onSave = onSave
        _date = State(initialValue: item.expirationDate ?? Date().addingTimeInterval(7 * 24 * 60 * 60))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                DatePicker("Expires", selection: $date, in: Date()..., displayedComponents: .date)
                    .datePickerStyle(.graphical)
                Text("We'll remind you two days before.")
                    .font(ScpFont.caption)
                    .foregroundStyle(ScpColor.textMuted)
                Button("Save") {
                    onSave(date)
                    dismiss()
                }
                .buttonStyle(ScpPrimaryButtonStyle())
            }
            .padding(16)
            .background(ScpColor.background)
            .navigationTitle(item.ingredient.name.capitalized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

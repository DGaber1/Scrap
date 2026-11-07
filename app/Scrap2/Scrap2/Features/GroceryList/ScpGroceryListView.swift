import SwiftUI
import ScrapCore

/// The shopping list on ruled notebook paper.
struct ScpGroceryListView: View {
    let groceryList: ScpGroceryListViewModel
    @State private var newItemName = ""
    @FocusState private var isAddFieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header
                    ForEach(groceryList.items) { item in
                        row(for: item)
                    }
                    addRow
                    totalRow
                }
                .padding(.bottom, 24)
            }
            .scpNotebookPaper()
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 16)
            .padding(.top, 8)

            footer
        }
        .background(ScpColor.background)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Grocery list")
                .font(ScpFont.handwriting(34, relativeTo: .largeTitle))
                .foregroundStyle(ScpColor.ink)
            Text(subtitle)
                .font(ScpFont.handwriting(15, relativeTo: .subheadline))
                .foregroundStyle(ScpColor.textMuted)
        }
        .padding(.leading, ScpNotebookPaperStyle.marginX + 14)
        .padding(.top, 20)
        .padding(.bottom, 8)
        .frame(minHeight: ScpNotebookPaperStyle.lineSpacing * 2, alignment: .bottom)
    }

    private var subtitle: LocalizedStringKey {
        switch groceryList.recipeCount {
        case 0: return "tap to check off"
        case 1: return "for 1 recipe · tap to check off"
        default: return "for \(groceryList.recipeCount) recipes · tap to check off"
        }
    }

    private func row(for item: ScpGroceryListItem) -> some View {
        Button {
            Task { await groceryList.toggleChecked(id: item.id) }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: item.isChecked ? "checkmark.square.fill" : "square")
                    .foregroundStyle(item.isChecked ? ScpColor.brand : ScpColor.ink)
                Text(item.ingredient.name)
                    .strikethrough(item.isChecked)
                Spacer()
                Text(ScpQuantityFormatter.amountText(for: item.quantity))
                    .foregroundStyle(ScpColor.textMuted)
                if item.estimatedCost > 0 {
                    Text(item.estimatedCost, format: .currency(code: "USD"))
                        .foregroundStyle(ScpColor.textMuted)
                }
            }
            .font(ScpFont.handwriting(20))
            .foregroundStyle(item.isChecked ? ScpColor.textMuted : ScpColor.ink)
            .padding(.leading, ScpNotebookPaperStyle.marginX + 14)
            .padding(.trailing, 16)
            .frame(minHeight: ScpNotebookPaperStyle.lineSpacing)
        }
        .buttonStyle(.plain)
        .accessibilityValue(item.isChecked ? Text("Checked") : Text("Not checked"))
        .contextMenu {
            Button("Remove", role: .destructive) {
                Task { await groceryList.removeItem(id: item.id) }
            }
        }
    }

    private var addRow: some View {
        HStack(spacing: 10) {
            Image(systemName: "plus")
                .foregroundStyle(ScpColor.textMuted)
            TextField("add an item…", text: $newItemName)
                .font(ScpFont.handwriting(20))
                .focused($isAddFieldFocused)
                .submitLabel(.done)
                .onSubmit {
                    let name = newItemName
                    newItemName = ""
                    Task { await groceryList.addManualItem(named: name) }
                }
        }
        .padding(.leading, ScpNotebookPaperStyle.marginX + 14)
        .padding(.trailing, 16)
        .frame(minHeight: ScpNotebookPaperStyle.lineSpacing)
    }

    private var totalRow: some View {
        HStack {
            Text("Estimated total")
            Spacer()
            Text(groceryList.estimatedTotal, format: .currency(code: "USD"))
        }
        .font(ScpFont.handwriting(20))
        .foregroundStyle(ScpColor.ink)
        .padding(.leading, ScpNotebookPaperStyle.marginX + 14)
        .padding(.trailing, 16)
        .padding(.top, 12)
    }

    private var footer: some View {
        HStack(spacing: 12) {
            Button {
                Task { await groceryList.finishShopping() }
            } label: {
                Text("Purchased these items · Start new list")
            }
            .buttonStyle(ScpPrimaryButtonStyle())
            .disabled(groceryList.items.isEmpty)

            ShareLink(item: groceryList.shareText) {
                Image(systemName: "square.and.arrow.up")
                    .font(.title3)
                    .foregroundStyle(ScpColor.brand)
                    .frame(width: 52, height: 52)
                    .background(ScpColor.card, in: Circle())
            }
            .accessibilityLabel("Share list")
        }
        .padding(16)
    }
}

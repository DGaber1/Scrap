import Foundation
import SwiftUI
import ScrapCore

/// Shown when a recipe needs equipment you don't have: friends nearby who own one,
/// with "Ask to borrow", or add it to your grocery list instead.
struct ScpBorrowEquipmentView: View {
    let equipment: ScpEquipment
    let recipeTitle: String
    let friends: ScpFriendsViewModel
    let groceryList: ScpGroceryListViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var addedToList = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    equipmentCard
                    lendersSection
                    if let error = friends.error {
                        Text(error.userMessage)
                            .font(ScpFont.caption)
                            .foregroundStyle(ScpColor.missingIngredient)
                    }
                }
                .padding(16)
            }
            .background(ScpColor.background)
            .safeAreaInset(edge: .bottom) {
                Button {
                    Task {
                        await groceryList.addManualItem(named: equipment.name)
                        addedToList = groceryList.error == nil
                    }
                } label: {
                    if addedToList {
                        Label("Added to grocery list", systemImage: "checkmark")
                    } else {
                        Text("Add \(equipment.name.lowercased()) to grocery list")
                    }
                }
                .buttonStyle(ScpOutlineButtonStyle())
                .disabled(addedToList)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(ScpColor.background)
            }
            .navigationTitle("Missing equipment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .accessibilityLabel("Close")
                }
            }
        }
    }

    private var equipmentCard: some View {
        HStack(spacing: 16) {
            Text(equipment.emoji)
                .font(.system(size: 40))
                .frame(width: 72, height: 72)
                .background(ScpColor.chip, in: RoundedRectangle(cornerRadius: 16))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(equipment.name)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(ScpColor.textPrimary)
                Text("Needed for \(recipeTitle)")
                    .font(ScpFont.detail)
                    .foregroundStyle(ScpColor.textMuted)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(ScpColor.card, in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(ScpColor.divider))
    }

    @ViewBuilder
    private var lendersSection: some View {
        let lenders = friends.lenders(of: equipment)
        VStack(alignment: .leading, spacing: 0) {
            Text("Friends who have one")
                .font(ScpFont.sectionHeader)
                .foregroundStyle(ScpColor.brand)
                .textCase(.uppercase)
                .padding(.bottom, 8)
            if lenders.isEmpty {
                ScpEmptyHint(
                    text: "None of your friends have one yet. Add friends from the Community tab, or add it to your grocery list."
                )
            }
            ForEach(lenders) { lender in
                lenderRow(lender)
                Divider().overlay(ScpColor.divider)
            }
        }
    }

    private func lenderRow(_ lender: ScpProfile) -> some View {
        let asked = friends.hasAskedToBorrow(equipment, from: lender)
        return HStack(spacing: 14) {
            ScpAvatarView(username: lender.username, size: 46)
            VStack(alignment: .leading, spacing: 3) {
                Text(lender.username)
                    .font(.headline)
                    .foregroundStyle(ScpColor.textPrimary)
                Text(distanceText(for: lender))
                    .font(ScpFont.detail)
                    .foregroundStyle(ScpColor.textMuted)
                    .lineLimit(1)
            }
            Spacer(minLength: 8)
            Button {
                Task { await friends.askToBorrow(equipment, from: lender, recipeTitle: recipeTitle) }
            } label: {
                if asked {
                    Label("Asked", systemImage: "checkmark")
                } else {
                    Text("Ask to borrow")
                }
            }
            .buttonStyle(ScpPillButtonStyle(isFilled: !asked))
            .disabled(asked)
            .accessibilityLabel(asked ? Text("Asked \(lender.username)") : Text("Ask \(lender.username) to borrow"))
        }
        .padding(.vertical, 12)
    }

    private func distanceText(for lender: ScpProfile) -> String {
        let has = String(localized: "has \(equipment.withArticle)")
        guard let miles = lender.distanceMiles else { return has }
        let distance = miles.formatted(.number.precision(.fractionLength(1)))
        return String(localized: "\(distance) mi away · \(has)")
    }
}

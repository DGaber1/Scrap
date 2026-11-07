import SwiftUI
import ScrapCore

/// Equipment toggles plus dietary restriction toggles.
struct ScpEquipmentSection: View {
    let kitchen: ScpKitchenViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Equipment")
                .font(ScpFont.sectionHeader)
                .foregroundStyle(ScpColor.textMuted)
                .textCase(.uppercase)
            ForEach(ScpEquipment.allKnown) { equipment in
                toggleRow(
                    title: Text(equipment.name),
                    isOn: kitchen.hasEquipment(equipment)
                ) {
                    Task { await kitchen.toggleEquipment(equipment) }
                }
            }

            Text("Dietary needs")
                .font(ScpFont.sectionHeader)
                .foregroundStyle(ScpColor.textMuted)
                .textCase(.uppercase)
                .padding(.top, 8)
            ForEach(ScpDietaryRestriction.allCases, id: \.self) { restriction in
                toggleRow(
                    title: Text(Self.title(for: restriction)),
                    isOn: kitchen.hasRestriction(restriction)
                ) {
                    Task { await kitchen.toggleRestriction(restriction) }
                }
            }
        }
    }

    private func toggleRow(title: Text, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                title.foregroundStyle(ScpColor.textPrimary)
                Spacer()
                Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isOn ? ScpColor.brand : ScpColor.textMuted)
            }
            .padding(14)
            .background(ScpColor.card, in: RoundedRectangle(cornerRadius: 12))
        }
        .accessibilityAddTraits(isOn ? .isSelected : [])
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

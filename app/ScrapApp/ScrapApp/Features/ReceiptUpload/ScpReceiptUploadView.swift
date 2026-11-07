import SwiftUI

/// Placeholder for receipt scanning, opened from the "+" button in the tab bar.
struct ScpReceiptUploadView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScpPlaceholderView(
                systemImage: "doc.text.viewfinder",
                title: "Scan a receipt",
                message: "Soon you'll snap a grocery receipt and Scrap will add everything to your kitchen."
            )
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

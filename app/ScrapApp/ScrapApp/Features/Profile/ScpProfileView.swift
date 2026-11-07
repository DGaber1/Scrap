import SwiftUI

/// Profile tab. For now it only links to My Kitchen; accounts come later (REQ-D-07).
struct ScpProfileView: View {
    let kitchen: ScpKitchenViewModel
    let dependencies: ScpAppDependencies

    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    ScpKitchenView(kitchen: kitchen, dependencies: dependencies)
                } label: {
                    Label("My Kitchen", systemImage: "refrigerator")
                }
                .listRowBackground(ScpColor.card)

                Section {
                    Text("Sign-in and saved recipes are coming soon.")
                        .foregroundStyle(ScpColor.textMuted)
                        .listRowBackground(ScpColor.card)
                }
            }
            .scrollContentBackground(.hidden)
            .background(ScpColor.background)
            .navigationTitle("Profile")
        }
    }
}

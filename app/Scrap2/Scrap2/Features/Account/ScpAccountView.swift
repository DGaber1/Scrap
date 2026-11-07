import SwiftUI
import ScrapCore

/// Sign in or create an account. Shown when a guest tries to do something that needs one.
struct ScpAccountView: View {
    private enum Mode: String, CaseIterable, Identifiable {
        case signIn = "Sign in"
        case signUp = "Create account"
        var id: String { rawValue }
    }

    let session: ScpSessionViewModel
    let reason: LocalizedStringKey
    @Environment(\.dismiss) private var dismiss

    @State private var mode: Mode = .signUp
    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(reason)
                        .font(ScpFont.detail)
                        .foregroundStyle(ScpColor.textMuted)

                    Picker("Mode", selection: $mode) {
                        ForEach(Mode.allCases) { Text(LocalizedStringKey($0.rawValue)).tag($0) }
                    }
                    .pickerStyle(.segmented)

                    if mode == .signUp {
                        field("Name", text: $displayName)
                    }
                    field("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                    SecureField("Password (6+ characters)", text: $password)
                        .padding(14)
                        .background(ScpColor.card, in: RoundedRectangle(cornerRadius: 14))

                    if session.error != nil {
                        Text("Check your email and password (6+ characters) and try again.")
                            .font(ScpFont.caption)
                            .foregroundStyle(ScpColor.missingIngredient)
                    }

                    Button {
                        Task { await submit() }
                    } label: {
                        Text(mode == .signUp ? "Create account" : "Sign in")
                    }
                    .buttonStyle(ScpPrimaryButtonStyle())
                    .disabled(session.isWorking)

                    Text("Accounts are a preview for now. They last until you close the app, until we connect Supabase.")
                        .font(ScpFont.caption)
                        .foregroundStyle(ScpColor.textMuted)
                }
                .padding(16)
            }
            .background(ScpColor.background)
            .navigationTitle("Your account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Not now") { dismiss() }
                }
            }
            .onAppear { session.clearError() }
        }
    }

    private func field(_ title: LocalizedStringKey, text: Binding<String>) -> some View {
        TextField(title, text: text)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .padding(14)
            .background(ScpColor.card, in: RoundedRectangle(cornerRadius: 14))
    }

    private func submit() async {
        let worked: Bool
        switch mode {
        case .signIn:
            worked = await session.signIn(email: email, password: password)
        case .signUp:
            worked = await session.signUp(email: email, password: password, displayName: displayName)
        }
        if worked { dismiss() }
    }
}

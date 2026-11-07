import Foundation
import Observation
import ScrapCore

/// Who is signed in. Guests can browse, but saving recipes, submitting, and the like need an account (REQ-D-24).
@MainActor
@Observable
final class ScpSessionViewModel {
    private(set) var state: ScpSessionState = .guest
    private(set) var error: ScpError?
    private(set) var isWorking = false

    private let authService: any ScpAuthService

    init(authService: any ScpAuthService) {
        self.authService = authService
    }

    var user: ScpUser? {
        if case .signedIn(let user) = state { return user }
        return nil
    }

    func isAllowed(_ action: ScpAccessPolicy.Action) -> Bool {
        ScpAccessPolicy(session: state).isAllowed(action)
    }

    func load() async {
        if let user = await authService.currentUser() {
            state = .signedIn(user)
        }
    }

    /// Returns true when sign-in worked.
    func signIn(email: String, password: String) async -> Bool {
        guard Self.isValid(email: email, password: password) else {
            error = .invalidInput
            return false
        }
        return await perform { try await self.authService.signIn(email: email, password: password) }
    }

    /// Returns true when the account was created.
    func signUp(email: String, password: String, displayName: String) async -> Bool {
        let name = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard Self.isValid(email: email, password: password), !name.isEmpty else {
            error = .invalidInput
            return false
        }
        return await perform { try await self.authService.signUp(email: email, password: password, displayName: name) }
    }

    func signOut() async {
        await authService.signOut()
        state = .guest
        error = nil
    }

    func clearError() {
        error = nil
    }

    private func perform(_ request: () async throws -> ScpUser) async -> Bool {
        isWorking = true
        defer { isWorking = false }
        do {
            state = .signedIn(try await request())
            error = nil
            return true
        } catch {
            self.error = (error as? ScpError) ?? .unknown(String(describing: error))
            return false
        }
    }

    private static func isValid(email: String, password: String) -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.contains("@") && trimmed.contains(".") && password.count >= 6
    }
}

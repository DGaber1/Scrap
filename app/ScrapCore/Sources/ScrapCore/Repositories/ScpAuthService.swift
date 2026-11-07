import Foundation

/// Account creation and sign-in. The Supabase-backed implementation lives in ScrapApp.
public protocol ScpAuthService: Sendable {
    /// Creates an account and signs in.
    func signUp(email: String, password: String, displayName: String) async throws -> ScpUser
    /// Signs in to an existing account.
    func signIn(email: String, password: String) async throws -> ScpUser
    /// Signs out the current user.
    func signOut() async
    /// The signed-in user restored from storage, if any.
    func currentUser() async -> ScpUser?
}

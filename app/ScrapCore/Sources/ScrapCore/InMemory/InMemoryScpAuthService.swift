import Foundation

/// An auth service that accepts any credentials and keeps the user in memory.
public actor InMemoryScpAuthService: ScpAuthService {
    private var user: ScpUser?
    private let failure: ScpError?

    /// Creates a service. Pass `failure` to make every sign-in or sign-up throw it.
    public init(failure: ScpError? = nil) {
        self.failure = failure
    }

    public func signUp(email: String, password: String, displayName: String) async throws -> ScpUser {
        if let failure { throw failure }
        let created = ScpUser(email: email, displayName: displayName)
        user = created
        return created
    }

    public func signIn(email: String, password: String) async throws -> ScpUser {
        if let failure { throw failure }
        let signedIn = ScpUser(email: email, displayName: email)
        user = signedIn
        return signedIn
    }

    public func signOut() async {
        user = nil
    }

    public func currentUser() async -> ScpUser? {
        user
    }
}

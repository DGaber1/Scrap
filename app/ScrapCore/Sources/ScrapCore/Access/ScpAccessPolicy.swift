import Foundation

/// The single place that decides what a guest can and cannot do (REQ-D-08).
/// Views and view models ask this type; they never check login status themselves.
public struct ScpAccessPolicy: Sendable {

    /// Something a user might try to do that needs an account.
    public enum Action: CaseIterable, Sendable {
        case saveRecipe
        case comment
        case submitRecipe
        case keepGroceryListPastToday
        case addFriend
    }

    public let session: ScpSessionState

    /// Creates a policy for the given session.
    public init(session: ScpSessionState) {
        self.session = session
    }

    /// Whether `action` is allowed right now.
    public func isAllowed(_ action: Action) -> Bool {
        switch session {
        case .signedIn: return true
        case .guest: return false
        }
    }

    /// Whether the app should show the "create an account" prompt for `action`.
    public func shouldPromptToCreateAccount(for action: Action) -> Bool {
        !isAllowed(action)
    }
}

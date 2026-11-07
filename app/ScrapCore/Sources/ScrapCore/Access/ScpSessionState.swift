import Foundation

/// Whether anyone is signed in. The only input to ``ScpAccessPolicy``.
public enum ScpSessionState: Equatable, Sendable {
    case guest
    case signedIn(ScpUser)
}

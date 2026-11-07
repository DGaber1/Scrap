import Foundation

/// The one error type ScrapCore throws (REQ-D-22). Repositories and clients
/// map every failure onto a case here, and view models turn it into
/// `ScpViewState.failed`, so the UI never sees raw Foundation errors.
public enum ScpError: Error, Equatable, Sendable {
    /// The server could not be reached or returned an unexpected status.
    case network
    /// The API quota or rate limit was hit.
    case rateLimited
    /// The requested item does not exist.
    case notFound
    /// The user (or the API key) is not allowed to do this.
    case unauthorized
    /// A response arrived but could not be understood.
    case invalidData
    /// The caller passed a value that cannot be used (for example zero servings).
    case invalidInput
    /// Anything else. The text is for logs, never shown to the user.
    case unknown(String)
}

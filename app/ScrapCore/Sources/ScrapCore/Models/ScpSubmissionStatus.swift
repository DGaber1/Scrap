import Foundation

/// Where a user-contributed recipe is in the admin approval process.
public enum ScpSubmissionStatus: String, Codable, CaseIterable, Sendable {
    case pending
    case approved
    case rejected
}

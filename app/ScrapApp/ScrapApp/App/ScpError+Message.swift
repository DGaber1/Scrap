import Foundation
import ScrapCore

extension ScpError {
    /// Text to show the user for this error. Keys live in `Localizable.xcstrings` (REQ-D-23).
    var userMessage: String {
        switch self {
        case .network:
            return String(localized: "We couldn't reach the server. Check your connection and try again.")
        case .rateLimited:
            return String(localized: "We've hit our recipe search limit for now. Please try again in a bit.")
        case .notFound:
            return String(localized: "We couldn't find that.")
        case .unauthorized:
            return String(localized: "Please sign in to continue.")
        case .invalidData:
            return String(localized: "We got a response we didn't expect. Please try again.")
        case .invalidInput, .unknown:
            return String(localized: "Something went wrong. Please try again.")
        }
    }
}

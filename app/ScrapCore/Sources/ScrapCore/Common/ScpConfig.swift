import Foundation

/// API credentials, supplied by the app at launch. Nothing in this package
/// contains a real key (REQ-D-12): ScrapApp reads them from a configuration
/// file that is excluded from Git and passes them in here.
public struct ScpConfig: Sendable {
    public var spoonacularAPIKey: String
    public var supabaseURL: URL?
    public var supabaseAnonKey: String?

    /// Creates a configuration.
    public init(spoonacularAPIKey: String, supabaseURL: URL? = nil, supabaseAnonKey: String? = nil) {
        self.spoonacularAPIKey = spoonacularAPIKey
        self.supabaseURL = supabaseURL
        self.supabaseAnonKey = supabaseAnonKey
    }

    /// True when the Spoonacular key looks real (not empty and not the template placeholder).
    public var hasSpoonacularKey: Bool {
        let key = spoonacularAPIKey.trimmingCharacters(in: .whitespacesAndNewlines)
        return !key.isEmpty && !key.hasPrefix("REPLACE")
    }
}

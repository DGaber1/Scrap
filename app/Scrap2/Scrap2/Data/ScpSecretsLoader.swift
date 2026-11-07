import Foundation
import ScrapCore

/// Reads API keys from `Secrets.plist`, which is excluded from Git (REQ-D-12).
/// Copy `Secrets.example.plist` to `Secrets.plist` and fill in your own keys.
enum ScpSecretsLoader {

    /// The configuration in `Secrets.plist`, or `nil` when the file is missing or unreadable.
    static func load(bundle: Bundle = .main) -> ScpConfig? {
        guard
            let url = bundle.url(forResource: "Secrets", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil),
            let values = plist as? [String: Any],
            let spoonacularKey = values["SpoonacularAPIKey"] as? String
        else {
            return nil
        }
        return ScpConfig(
            spoonacularAPIKey: spoonacularKey,
            supabaseURL: (values["SupabaseURL"] as? String).flatMap { URL(string: $0) },
            supabaseAnonKey: values["SupabaseAnonKey"] as? String
        )
    }
}

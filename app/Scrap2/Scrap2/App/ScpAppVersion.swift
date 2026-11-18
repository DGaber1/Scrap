import Foundation

/// The app's version as stamped into Info.plist from git at build time.
/// The "Stamp version from git" build step writes these values; see app/VERSIONING.md.
struct ScpAppVersion: Equatable, Sendable {
    /// The release version from the latest `app-vX.Y` tag, such as "1.1".
    let version: String
    /// The build number: how many commits the build was made from, such as "87".
    let build: String
    /// The short commit hash, ending in "-dirty" when the build had uncommitted changes.
    let commit: String
    let isDebugBuild: Bool

    /// The version of the running app.
    static let current = ScpAppVersion(bundle: .main)

    init(version: String, build: String, commit: String, isDebugBuild: Bool) {
        self.version = version
        self.build = build
        self.commit = commit
        self.isDebugBuild = isDebugBuild
    }

    init(bundle: Bundle) {
        let info = bundle.infoDictionary ?? [:]
        let isDebug: Bool
        #if DEBUG
        isDebug = true
        #else
        isDebug = false
        #endif
        self.init(
            version: info["CFBundleShortVersionString"] as? String ?? "1.0",
            build: info["CFBundleVersion"] as? String ?? "1",
            commit: info["ScpGitCommit"] as? String ?? "unknown",
            isDebugBuild: isDebug
        )
    }

    /// Whether the build was made with changes that were not committed yet.
    var hasUncommittedChanges: Bool { commit.hasSuffix("-dirty") }

    /// "Debug build" or "Release build".
    var buildType: String {
        isDebugBuild ? String(localized: "Debug build") : String(localized: "Release build")
    }

    /// The short line at the bottom of Profile, such as "Scrap v1.1 (87)".
    var shortText: String { "Scrap v\(version) (\(build))" }

    /// Everything a bug report needs, on one line.
    var fullText: String { "Scrap \(version) (\(build)), commit \(commit), \(buildType)" }
}

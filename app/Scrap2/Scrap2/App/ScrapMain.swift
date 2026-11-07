import SwiftUI

/// The app's entry point. The one type that is not `Scp`-prefixed (REQ-D-10).
@main
struct ScrapMain: App {
    private let dependencies = ScpAppDependencies.makeDefault()

    var body: some Scene {
        WindowGroup {
            ScpRootView(dependencies: dependencies)
        }
    }
}

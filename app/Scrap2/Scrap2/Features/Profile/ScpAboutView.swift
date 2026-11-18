import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// About Scrap: the app's version, build, and commit, plus a way to report a problem.
/// Opened from Profile. Works for guests too.
struct ScpAboutView: View {
    let version: ScpAppVersion

    @State private var didCopy = false

    var body: some View {
        List {
            Section {
                appHeader
                    .listRowBackground(Color.clear)
            }

            Section {
                LabeledContent("Version", value: version.version)
                LabeledContent("Build", value: version.build)
                LabeledContent("Commit") {
                    Text(version.commit)
                        .font(.system(.subheadline, design: .monospaced))
                        .textSelection(.enabled)
                }
                LabeledContent("Build type") {
                    Text(version.buildType)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(ScpColor.brand)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(ScpColor.softGreen, in: Capsule())
                }
                Button(action: copyVersionInfo) {
                    Label(
                        didCopy ? "Copied" : "Copy version info",
                        systemImage: didCopy ? "checkmark" : "doc.on.doc"
                    )
                    .foregroundStyle(ScpColor.brand)
                }
            } header: {
                sectionHeader("Version")
            } footer: {
                if version.hasUncommittedChanges {
                    Text("This build includes changes that weren't committed yet.")
                }
            }
            .listRowBackground(ScpColor.card)

            Section {
                if let reportURL {
                    Link(destination: reportURL) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Report a problem")
                                    .foregroundStyle(ScpColor.textPrimary)
                                Text("Opens a GitHub issue with your version filled in")
                                    .font(ScpFont.caption)
                                    .foregroundStyle(ScpColor.textMuted)
                            }
                        } icon: {
                            Image(systemName: "flag")
                                .foregroundStyle(ScpColor.brand)
                        }
                    }
                }
            } header: {
                sectionHeader("Help")
            } footer: {
                Text("Made by Team Scrap\nStevens Institute of Technology")
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 24)
            }
            .listRowBackground(ScpColor.card)
        }
        .scrollContentBackground(.hidden)
        .background(ScpColor.background)
        .navigationTitle("About Scrap")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var appHeader: some View {
        VStack(spacing: 10) {
            Image(systemName: "fork.knife")
                .font(.system(size: 38, weight: .medium))
                .foregroundStyle(ScpColor.background)
                .frame(width: 84, height: 84)
                .background(ScpColor.brand, in: RoundedRectangle(cornerRadius: 20))
                .accessibilityHidden(true)
            Text("Scrap")
                .font(ScpFont.logo(34))
                .foregroundStyle(ScpColor.brand)
            Text("Cook with what you already have.")
                .font(ScpFont.detail)
                .foregroundStyle(ScpColor.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
    }

    private func sectionHeader(_ title: LocalizedStringKey) -> some View {
        Text(title)
            .font(ScpFont.sectionHeader)
            .foregroundStyle(ScpColor.brand)
    }

    /// A new GitHub issue on the team's repo, with the version details already in the body.
    private var reportURL: URL? {
        var components = URLComponents(string: "https://github.com/DGaber1/Scrap/issues/new")
        let body = """
        **What happened?**


        **What did you expect?**


        ---
        \(version.fullText)
        """
        components?.queryItems = [
            URLQueryItem(name: "title", value: "Bug: "),
            URLQueryItem(name: "body", value: body),
        ]
        return components?.url
    }

    private func copyVersionInfo() {
        #if canImport(UIKit)
        UIPasteboard.general.string = version.fullText
        #endif
        didCopy = true
        Task {
            try? await Task.sleep(for: .seconds(2))
            didCopy = false
        }
    }
}

#Preview {
    NavigationStack {
        ScpAboutView(version: ScpAppVersion(version: "1.1", build: "87", commit: "a1b2c3d", isDebugBuild: true))
    }
}

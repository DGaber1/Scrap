import Foundation
import SwiftUI
import ScrapCore
#if canImport(UIKit)
import UIKit
#endif

/// Friends: your invite link, finding people by username, friend requests, and your friends.
struct ScpFriendsView: View {
    let friends: ScpFriendsViewModel
    let feed: ScpFeedViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var query = ""
    @State private var didCopy = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let me = friends.me {
                        inviteCard(for: me)
                    }
                    searchField
                    if query.trimmingCharacters(in: .whitespaces).isEmpty {
                        requestsSection
                        friendsSection
                    } else {
                        searchResults
                    }
                    if let error = friends.error {
                        Text(error.userMessage)
                            .font(ScpFont.caption)
                            .foregroundStyle(ScpColor.missingIngredient)
                    }
                }
                .padding(16)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(ScpColor.background)
            .navigationTitle("Friends")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .accessibilityLabel("Close")
                }
            }
        }
    }

    // MARK: Invite link

    private func inviteCard(for me: ScpProfile) -> some View {
        let link = me.inviteLink?.absoluteString ?? ""
        return VStack(alignment: .leading, spacing: 14) {
            sectionHeader("Your invite link")
            HStack(spacing: 10) {
                HStack(spacing: 10) {
                    Image(systemName: "link")
                        .foregroundStyle(ScpColor.textMuted)
                    Text(link.replacingOccurrences(of: "https://", with: ""))
                        .foregroundStyle(ScpColor.textMuted)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(ScpColor.background, in: RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(ScpColor.divider))

                Button(didCopy ? "Copied" : "Copy") {
                    copy(link)
                }
                .buttonStyle(ScpPillButtonStyle(isFilled: !didCopy))
            }
            if let url = me.inviteLink {
                ShareLink(
                    item: url,
                    subject: Text("Cook with me on Scrap"),
                    message: Text("Add me on Scrap so we can share what we're cooking!")
                ) {
                    Label("Share via Messages", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(ScpOutlineButtonStyle())
            }
        }
        .padding(16)
        .background(ScpColor.card, in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(ScpColor.divider))
    }

    private func copy(_ link: String) {
        #if canImport(UIKit)
        UIPasteboard.general.string = link
        #endif
        didCopy = true
        Task {
            try? await Task.sleep(for: .seconds(2))
            didCopy = false
        }
    }

    // MARK: Search

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(ScpColor.textMuted)
            TextField("Find friends by username", text: $query)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            if !query.isEmpty {
                Button {
                    query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(ScpColor.textMuted)
                }
                .accessibilityLabel("Clear search")
            }
        }
        .padding(14)
        .background(ScpColor.card, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(ScpColor.divider))
    }

    @ViewBuilder
    private var searchResults: some View {
        let results = friends.search(query)
        if results.isEmpty {
            ScpEmptyHint(text: "No one with that username yet. Share your invite link instead.")
        } else {
            VStack(spacing: 0) {
                ForEach(results) { profile in
                    personRow(profile, detail: Text(profile.displayName)) {
                        relationshipButton(for: profile)
                    }
                    Divider().overlay(ScpColor.divider)
                }
            }
        }
    }

    @ViewBuilder
    private func relationshipButton(for profile: ScpProfile) -> some View {
        switch friends.relationship(with: profile) {
        case .friend:
            Label("Friends", systemImage: "checkmark")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(ScpColor.brand)
        case .requestedByYou:
            Text("Requested")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(ScpColor.textMuted)
        case .requestedYou:
            Button("Accept") { Task { await friends.accept(profile) } }
                .buttonStyle(ScpPillButtonStyle())
        case .none:
            Button("Add") { Task { await friends.sendRequest(to: profile) } }
                .buttonStyle(ScpPillButtonStyle())
        case .me:
            EmptyView()
        }
    }

    // MARK: Requests and friends

    @ViewBuilder
    private var requestsSection: some View {
        if !friends.requests.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                sectionHeader("Friend requests · \(friends.requests.count)")
                    .padding(.bottom, 8)
                ForEach(friends.requests) { profile in
                    personRow(profile, detail: Text("wants to be friends")) {
                        HStack(spacing: 8) {
                            Button {
                                Task { await friends.decline(profile) }
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(ScpColor.textMuted)
                                    .frame(width: 36, height: 36)
                                    .background(ScpColor.chip, in: Circle())
                            }
                            .accessibilityLabel("Decline \(profile.username)")
                            Button("Accept") { Task { await friends.accept(profile) } }
                                .buttonStyle(ScpPillButtonStyle())
                        }
                    }
                    Divider().overlay(ScpColor.divider)
                }
            }
        }
    }

    private var friendsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("Friends · \(friends.friends.count)")
                .padding(.bottom, 8)
            if friends.friends.isEmpty {
                ScpEmptyHint(text: "No friends yet. Search by username or share your invite link.")
            }
            ForEach(friends.friends) { profile in
                NavigationLink {
                    ScpFriendProfileView(profile: profile, friends: friends, feed: feed)
                } label: {
                    personRow(profile, detail: Text(equipmentSummary(for: profile))) {
                        Image(systemName: "chevron.right")
                            .foregroundStyle(ScpColor.textMuted)
                    }
                }
                .buttonStyle(.plain)
                Divider().overlay(ScpColor.divider)
            }
        }
    }

    private func equipmentSummary(for profile: ScpProfile) -> String {
        guard !profile.equipment.isEmpty else { return String(localized: "No equipment listed") }
        let names = profile.equipment.map { $0.name.lowercased() }.formatted(.list(type: .and, width: .narrow))
        return String(localized: "Has: \(names)")
    }

    private func personRow<Trailing: View>(
        _ profile: ScpProfile,
        detail: Text,
        @ViewBuilder trailing: () -> Trailing
    ) -> some View {
        HStack(spacing: 14) {
            ScpAvatarView(username: profile.username, size: 46)
            VStack(alignment: .leading, spacing: 3) {
                Text(profile.username)
                    .font(.headline)
                    .foregroundStyle(ScpColor.textPrimary)
                detail
                    .font(ScpFont.detail)
                    .foregroundStyle(ScpColor.textMuted)
                    .lineLimit(1)
            }
            Spacer(minLength: 8)
            trailing()
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }

    private func sectionHeader(_ text: LocalizedStringKey) -> some View {
        Text(text)
            .font(ScpFont.sectionHeader)
            .foregroundStyle(ScpColor.brand)
            .textCase(.uppercase)
    }
}

/// A friend's page: who they are, the equipment they could lend, and their posts.
struct ScpFriendProfileView: View {
    let profile: ScpProfile
    let friends: ScpFriendsViewModel
    let feed: ScpFeedViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 16) {
                    ScpAvatarView(username: profile.username, size: 72)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(profile.username)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(ScpColor.textPrimary)
                        Text(profile.displayName)
                            .foregroundStyle(ScpColor.textMuted)
                        if let miles = profile.distanceMiles {
                            Text("\(miles.formatted(.number.precision(.fractionLength(1)))) mi away")
                                .font(ScpFont.caption)
                                .foregroundStyle(ScpColor.textMuted)
                        }
                    }
                }

                if !profile.equipment.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Kitchen equipment")
                            .font(ScpFont.sectionHeader)
                            .foregroundStyle(ScpColor.brand)
                            .textCase(.uppercase)
                        ScpFlowLayout(spacing: 8) {
                            ForEach(profile.equipment) { item in
                                Text("\(item.emoji) \(item.name)")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(ScpColor.textPrimary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(ScpColor.card, in: Capsule())
                            }
                        }
                    }
                }

                Text("Posts")
                    .font(ScpFont.sectionHeader)
                    .foregroundStyle(ScpColor.brand)
                    .textCase(.uppercase)
                let posts = feed.posts(by: profile.id)
                if posts.isEmpty {
                    ScpEmptyHint(text: "No posts you can see yet.")
                }
                ForEach(posts) { post in
                    HStack(alignment: .top, spacing: 12) {
                        if !post.photos.isEmpty {
                            ScpPostPhotoGallery(photos: post.photos, height: 80)
                                .frame(width: 80)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(post.caption)
                                .foregroundStyle(ScpColor.textPrimary)
                                .lineLimit(3)
                            Text(ScpAgeFormatter.text(since: post.createdAt))
                                .font(ScpFont.caption)
                                .foregroundStyle(ScpColor.textMuted)
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(ScpColor.card, in: RoundedRectangle(cornerRadius: 16))
                }
            }
            .padding(16)
        }
        .background(ScpColor.background)
        .navigationTitle(profile.username)
        .navigationBarTitleDisplayMode(.inline)
    }
}

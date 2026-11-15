import Foundation
import SwiftUI
import ScrapCore

/// The comments on one post. Anyone can read them; posting one needs an account.
struct ScpCommentsSheet: View {
    let postID: UUID
    let feed: ScpFeedViewModel
    let canComment: Bool
    let onNeedAccount: () -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var draft = ""
    @State private var isSending = false

    var body: some View {
        NavigationStack {
            Group {
                if let post = feed.post(id: postID) {
                    commentList(for: post)
                } else {
                    ScpEmptyHint(text: "This post is no longer available.")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(ScpColor.background)
            .safeAreaInset(edge: .bottom) { composer }
            .navigationTitle("Comments")
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

    private func commentList(for post: ScpPost) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                if post.comments.isEmpty {
                    ScpEmptyHint(text: "No comments yet. Say something nice!")
                }
                ForEach(post.comments) { comment in
                    let username = feed.profile(id: comment.authorID)?.username ?? String(localized: "Scrap user")
                    HStack(alignment: .top, spacing: 12) {
                        ScpAvatarView(username: username, size: 34)
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(username)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(ScpColor.textPrimary)
                                Text(ScpAgeFormatter.text(since: comment.createdAt))
                                    .font(ScpFont.caption)
                                    .foregroundStyle(ScpColor.textMuted)
                            }
                            Text(comment.text)
                                .foregroundStyle(ScpColor.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .padding(16)
        }
    }

    @ViewBuilder
    private var composer: some View {
        if canComment {
            HStack(spacing: 10) {
                TextField("Add a comment…", text: $draft, axis: .vertical)
                    .lineLimit(1...4)
                    .padding(12)
                    .background(ScpColor.card, in: RoundedRectangle(cornerRadius: 14))
                Button {
                    send()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(ScpColor.brand)
                }
                .disabled(isSending || draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityLabel("Post comment")
            }
            .padding(12)
            .background(ScpColor.background)
        } else {
            ScpGuestSignUpBanner(text: "Sign up to join the conversation", onSignUp: onNeedAccount)
                .padding(12)
        }
    }

    private func send() {
        guard let post = feed.post(id: postID) else { return }
        let text = draft
        isSending = true
        Task {
            if await feed.addComment(text, to: post) {
                draft = ""
            }
            isSending = false
        }
    }
}

/// The cream card at the bottom of the feed asking guests to sign up.
struct ScpGuestSignUpBanner: View {
    let text: LocalizedStringKey
    let onSignUp: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text(text)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(ScpColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 8)
            Button("Sign up", action: onSignUp)
                .buttonStyle(ScpPillButtonStyle())
        }
        .padding(16)
        .background(ScpColor.card, in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(ScpColor.divider))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
    }
}

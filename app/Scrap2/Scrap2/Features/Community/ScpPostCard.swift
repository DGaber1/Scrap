import Foundation
import SwiftUI
import ScrapCore

/// One post in the community feed: author, photo, caption, the recipe it links to,
/// and the like, comment, save, and report actions.
/// Guests see the actions greyed out with a lock; tapping them asks them to sign up.
struct ScpPostCard<RecipeDestination: View>: View {
    let post: ScpPost
    let author: ScpProfile?
    let viewerID: UUID?
    /// The linked recipe, ranked against the viewer's kitchen.
    let rankedRecipe: ScpRankedRecipe?
    let onLike: () -> Void
    let onComment: () -> Void
    let onSave: () -> Void
    let onReport: () -> Void
    let onAuthorTap: () -> Void
    @ViewBuilder let recipeDestination: (ScpRankedRecipe) -> RecipeDestination

    @State private var confirmsReport = false

    private var isGuest: Bool { viewerID == nil }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            authorRow
            if !post.photos.isEmpty {
                ScpPostPhotoGallery(photos: post.photos)
            }
            if !post.caption.isEmpty {
                Text(post.caption)
                    .font(.body)
                    .foregroundStyle(ScpColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            recipeLink
            actions
        }
        .padding(.vertical, 4)
        .confirmationDialog("Report this post?", isPresented: $confirmsReport, titleVisibility: .visible) {
            Button("Report post", role: .destructive, action: onReport)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("We'll hide it for you and review it against our community guidelines.")
        }
    }

    private var authorRow: some View {
        HStack(spacing: 12) {
            Button(action: onAuthorTap) {
                HStack(spacing: 12) {
                    ScpAvatarView(username: author?.username ?? "?", size: 40)
                    Text(author?.username ?? String(localized: "Scrap user"))
                        .font(.headline)
                        .foregroundStyle(ScpColor.textPrimary)
                }
            }
            .buttonStyle(.plain)
            if post.visibility == .friends {
                Image(systemName: "person.2.fill")
                    .font(.caption)
                    .foregroundStyle(ScpColor.textMuted)
                    .accessibilityLabel("Friends only")
            }
            Spacer()
            Text(ScpAgeFormatter.text(since: post.createdAt))
                .font(ScpFont.detail)
                .foregroundStyle(ScpColor.textMuted)
        }
    }

    @ViewBuilder
    private var recipeLink: some View {
        if let rankedRecipe {
            NavigationLink {
                recipeDestination(rankedRecipe)
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "fork.knife")
                        .foregroundStyle(ScpColor.brand)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(rankedRecipe.recipe.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(ScpColor.textPrimary)
                            .lineLimit(1)
                        Text(recipeSubtitle(for: rankedRecipe))
                            .font(ScpFont.caption)
                            .foregroundStyle(ScpColor.textMuted)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(ScpColor.textMuted)
                }
                .padding(12)
                .background(ScpColor.card, in: RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
        } else if let title = post.ownRecipeTitle {
            Label(title, systemImage: "book.closed")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(ScpColor.brand)
        }
    }

    private func recipeSubtitle(for ranked: ScpRankedRecipe) -> String {
        let match = ranked.matchPercent.formatted(.percent.precision(.fractionLength(0)))
        let minutes = ranked.recipe.totalTimeMinutes
        return minutes > 0
            ? String(localized: "\(match) match · \(minutes) min")
            : String(localized: "\(match) match")
    }

    private var actions: some View {
        HStack(spacing: 18) {
            Button(action: onLike) {
                HStack(spacing: 6) {
                    Image(systemName: post.isLiked(by: viewerID) ? "heart.fill" : "heart")
                        .foregroundStyle(post.isLiked(by: viewerID) ? ScpColor.missingIngredient : actionColor)
                    Text("\(post.likeCount)")
                        .foregroundStyle(actionColor)
                }
            }
            .accessibilityLabel(post.isLiked(by: viewerID) ? Text("Unlike") : Text("Like"))
            .accessibilityValue(Text("\(post.likeCount) likes"))

            Button(action: onComment) {
                HStack(spacing: 6) {
                    Image(systemName: "bubble.left")
                    Text("\(post.comments.count)")
                }
                .foregroundStyle(actionColor)
            }
            .accessibilityLabel(Text("Comments"))
            .accessibilityValue(Text("\(post.comments.count) comments"))

            Spacer()

            Button(action: onSave) {
                Image(systemName: post.isSaved(by: viewerID) ? "bookmark.fill" : "bookmark")
                    .foregroundStyle(post.isSaved(by: viewerID) ? ScpColor.brand : actionColor)
            }
            .accessibilityLabel(post.isSaved(by: viewerID) ? Text("Remove from saved") : Text("Save post"))

            if isGuest {
                Image(systemName: "lock")
                    .font(.subheadline)
                    .foregroundStyle(ScpColor.textMuted)
                    .accessibilityLabel("Sign up to like, save, and comment")
            } else {
                Menu {
                    Button("Report post", systemImage: "flag", role: .destructive) { confirmsReport = true }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(ScpColor.textMuted)
                        .frame(width: 28, height: 28)
                }
                .accessibilityLabel("More options")
            }
        }
        .font(.title3)
        .buttonStyle(.plain)
    }

    private var actionColor: Color {
        isGuest ? ScpColor.textMuted : ScpColor.textPrimary
    }
}

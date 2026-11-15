import Foundation

/// Sample people, friendships, and posts so the community screens have something
/// to show before Supabase is connected. All names are invented.
public enum ScpSampleCommunity {

    /// Fixed IDs so sample data is the same on every launch.
    private static func id(_ number: Int) -> UUID {
        UUID(uuidString: String(format: "00000000-0000-0000-0000-%012d", number)) ?? UUID()
    }

    public static let maya = ScpProfile(
        id: id(1), username: "maya.cooks", displayName: "Maya",
        equipment: [.stovetop, .oven, .airFryer], distanceMiles: 0.4
    )
    public static let alex = ScpProfile(
        id: id(2), username: "yourfriendalex", displayName: "Alex",
        equipment: [.stovetop, .airFryer, .blender], distanceMiles: 1.2
    )
    public static let sam = ScpProfile(
        id: id(3), username: "sam.eats", displayName: "Sam",
        equipment: [.stovetop, .airFryer, .standMixer], distanceMiles: 0.8
    )
    public static let priya = ScpProfile(
        id: id(4), username: "priya.preps", displayName: "Priya",
        equipment: [.stovetop, .oven, .instantPot], distanceMiles: 1.6
    )
    public static let jordan = ScpProfile(
        id: id(5), username: "jordan.bakes", displayName: "Jordan",
        equipment: [.oven, .standMixer, .blender], distanceMiles: 2.3
    )
    public static let leo = ScpProfile(
        id: id(6), username: "leo.latenight", displayName: "Leo",
        equipment: [.stovetop, .blender]
    )
    public static let nina = ScpProfile(
        id: id(7), username: "nina.noodles", displayName: "Nina",
        equipment: [.stovetop, .instantPot], distanceMiles: 3.1
    )

    /// Everyone in the sample community.
    public static let profiles: [ScpProfile] = [maya, alex, sam, priya, jordan, leo, nina]

    /// Who a newly signed-in user starts out friends with.
    public static let starterFriendIDs: [UUID] = [sam.id, priya.id, jordan.id, leo.id]

    /// Who has already sent a newly signed-in user a friend request.
    public static let starterRequesterIDs: [UUID] = [maya.id, alex.id]

    /// Friendships among the sample people themselves.
    public static let friendships: [(UUID, UUID)] = [
        (maya.id, alex.id), (maya.id, sam.id), (sam.id, priya.id), (jordan.id, leo.id), (nina.id, priya.id),
    ]

    /// Sample posts, dated relative to `now`.
    public static func posts(now: Date = Date()) -> [ScpPost] {
        let hour: TimeInterval = 60 * 60
        let recipes = ScpSampleData.communityRecipes
        return [
            ScpPost(
                authorID: maya.id,
                caption: "Made this with leftover chicken! So good 💚",
                photos: [.placeholder("pasta")],
                linkedRecipe: recipes.first,
                visibility: .everyone,
                createdAt: now.addingTimeInterval(-2 * hour),
                comments: [
                    ScpComment(authorID: alex.id, text: "Need this recipe asap", createdAt: now.addingTimeInterval(-1.5 * hour)),
                    ScpComment(authorID: sam.id, text: "Leftover chicken hits different", createdAt: now.addingTimeInterval(-hour)),
                ],
                baseLikeCount: 42
            ),
            ScpPost(
                authorID: sam.id,
                caption: "Air fryer gnocchi in 12 minutes. Dorm cooking is undefeated.",
                photos: [.placeholder("gnocchi")],
                ownRecipeTitle: "Crispy air fryer gnocchi",
                visibility: .friends,
                createdAt: now.addingTimeInterval(-5 * hour),
                comments: [
                    ScpComment(authorID: priya.id, text: "Bringing my sauce over tonight", createdAt: now.addingTimeInterval(-4 * hour)),
                ],
                baseLikeCount: 17
            ),
            ScpPost(
                authorID: priya.id,
                caption: "Sunday meal prep: five lunches for under $15.",
                photos: [.placeholder("mealprep")],
                visibility: .everyone,
                createdAt: now.addingTimeInterval(-26 * hour),
                baseLikeCount: 88
            ),
            ScpPost(
                authorID: jordan.id,
                caption: "Banana pancakes with the last two bananas before they went bad.",
                photos: [.placeholder("pancakes")],
                linkedRecipe: recipes.count > 1 ? recipes[1] : nil,
                visibility: .friends,
                createdAt: now.addingTimeInterval(-30 * hour),
                baseLikeCount: 9
            ),
            ScpPost(
                authorID: nina.id,
                caption: "Instant Pot ramen for a rainy night.",
                photos: [.placeholder("ramen")],
                visibility: .everyone,
                createdAt: now.addingTimeInterval(-50 * hour),
                baseLikeCount: 31
            ),
        ]
    }
}

import Foundation

/// A recipe, from Spoonacular or contributed by a user.
public struct ScpRecipe: Codable, Identifiable, Equatable, Sendable {

    /// How hard a recipe is to make.
    public enum Difficulty: String, Codable, CaseIterable, Comparable, Sendable {
        case easy
        case medium
        case hard

        private var rank: Int {
            switch self {
            case .easy: return 0
            case .medium: return 1
            case .hard: return 2
            }
        }

        public static func < (lhs: Difficulty, rhs: Difficulty) -> Bool {
            lhs.rank < rhs.rank
        }
    }

    public let id: String
    public var title: String
    public var ingredients: [ScpRecipeIngredient]
    public var instructions: [String]
    public var prepTimeMinutes: Int
    public var cookTimeMinutes: Int
    public var difficulty: Difficulty
    public var servings: Int
    public var proteinGramsPerServing: Double?
    public var requiredEquipment: [ScpEquipment]
    public var dietaryTags: Set<ScpDietaryRestriction>
    public var mealTypes: Set<ScpMealType>
    public var cuisine: ScpCuisine?
    public var source: ScpRecipeSource
    public var imageURL: URL?
    public var videoURL: URL?
    /// Set only for community recipes.
    public var contributedByUserID: UUID?

    /// Creates a recipe. Everything beyond the first eight arguments is optional.
    public init(
        id: String,
        title: String,
        ingredients: [ScpRecipeIngredient],
        instructions: [String],
        prepTimeMinutes: Int,
        cookTimeMinutes: Int,
        difficulty: Difficulty,
        servings: Int,
        proteinGramsPerServing: Double? = nil,
        requiredEquipment: [ScpEquipment] = [],
        dietaryTags: Set<ScpDietaryRestriction> = [],
        mealTypes: Set<ScpMealType> = [],
        cuisine: ScpCuisine? = nil,
        source: ScpRecipeSource = .spoonacular,
        imageURL: URL? = nil,
        videoURL: URL? = nil,
        contributedByUserID: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.ingredients = ingredients
        self.instructions = instructions
        self.prepTimeMinutes = prepTimeMinutes
        self.cookTimeMinutes = cookTimeMinutes
        self.difficulty = difficulty
        self.servings = servings
        self.proteinGramsPerServing = proteinGramsPerServing
        self.requiredEquipment = requiredEquipment
        self.dietaryTags = dietaryTags
        self.mealTypes = mealTypes
        self.cuisine = cuisine
        self.source = source
        self.imageURL = imageURL
        self.videoURL = videoURL
        self.contributedByUserID = contributedByUserID
    }

    /// Prep plus cook time.
    public var totalTimeMinutes: Int { prepTimeMinutes + cookTimeMinutes }
}

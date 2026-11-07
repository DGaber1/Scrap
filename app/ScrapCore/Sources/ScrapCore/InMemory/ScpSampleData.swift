import Foundation

/// Realistic sample recipes and a sample kitchen for SwiftUI previews, tests,
/// and the first prototype before any API key is configured.
public enum ScpSampleData {

    private static func item(_ name: String, _ amount: Double, _ unit: ScpMeasurementUnit) -> ScpRecipeIngredient {
        ScpRecipeIngredient(ingredient: ScpIngredient(name: name), quantity: ScpQuantity(amount: amount, unit: unit))
    }

    /// Two sample recipes that look like they came from other Scrap users.
    public static let communityRecipes: [ScpRecipe] = [
        ScpRecipe(
            id: "community-1",
            title: "Dorm Room Fried Rice",
            ingredients: [item("Rice", 2, .cup), item("Egg", 2, .piece), item("Soy sauce", 2, .tablespoon), item("Frozen peas", 0.5, .cup)],
            instructions: [
                "Scramble the eggs in a hot pan and set aside.",
                "Fry the cooked rice and peas for three minutes.",
                "Stir in the soy sauce and eggs and serve.",
            ],
            prepTimeMinutes: 5,
            cookTimeMinutes: 10,
            difficulty: .easy,
            servings: 2,
            requiredEquipment: [.stovetop],
            mealTypes: [.dinner],
            cuisine: .asian,
            source: .community
        ),
        ScpRecipe(
            id: "community-2",
            title: "Three-Ingredient Banana Pancakes",
            ingredients: [item("Banana", 1, .piece), item("Egg", 2, .piece), item("Oats", 0.5, .cup)],
            instructions: [
                "Blend the banana, eggs, and oats until smooth.",
                "Cook spoonfuls on a greased pan until golden on both sides.",
            ],
            prepTimeMinutes: 5,
            cookTimeMinutes: 10,
            difficulty: .easy,
            servings: 2,
            requiredEquipment: [.stovetop, .blender],
            dietaryTags: [.vegetarian, .dairyFree],
            mealTypes: [.breakfast],
            cuisine: .american,
            source: .community
        ),
    ]

    /// Five sample recipes covering a range of times, difficulties, and diets.
    public static let recipes: [ScpRecipe] = [
        ScpRecipe(
            id: "sample-1",
            title: "Garlic Butter Chicken Pasta",
            ingredients: [
                item("Chicken breast", 1, .pound),
                item("Pasta", 8, .ounce),
                item("Spinach", 2, .cup),
                item("Heavy cream", 0.5, .cup),
                item("Parmesan", 0.25, .cup),
            ],
            instructions: [
                "Season and sear the chicken breast until cooked through, then slice.",
                "Cook the pasta according to the package instructions.",
                "In the same pan, wilt the spinach, then stir in the heavy cream and parmesan.",
                "Toss the pasta and chicken through the sauce and serve.",
            ],
            prepTimeMinutes: 10,
            cookTimeMinutes: 15,
            difficulty: .medium,
            servings: 2,
            proteinGramsPerServing: 38,
            requiredEquipment: [.stovetop],
            mealTypes: [.dinner],
            cuisine: .italian
        ),
        ScpRecipe(
            id: "sample-2",
            title: "Chickpea Salad Wraps",
            ingredients: [
                item("Chickpeas", 1, .cup),
                item("Tortilla", 2, .piece),
                item("Spinach", 1, .cup),
            ],
            instructions: [
                "Mash the chickpeas lightly and mix with your favorite dressing.",
                "Fill the tortillas with the chickpea mixture and spinach, then roll.",
            ],
            prepTimeMinutes: 15,
            cookTimeMinutes: 0,
            difficulty: .easy,
            servings: 2,
            proteinGramsPerServing: 12,
            dietaryTags: [.vegetarian, .vegan, .dairyFree, .nutFree],
            mealTypes: [.lunch],
            cuisine: .mediterranean
        ),
        ScpRecipe(
            id: "sample-3",
            title: "Fluffy Scrambled Eggs",
            ingredients: [
                item("Egg", 3, .piece),
                item("Milk", 2, .tablespoon),
                item("Butter", 1, .tablespoon),
            ],
            instructions: [
                "Whisk the eggs with the milk and a pinch of salt.",
                "Melt the butter in a pan over low heat.",
                "Pour in the eggs and stir slowly until just set.",
            ],
            prepTimeMinutes: 2,
            cookTimeMinutes: 5,
            difficulty: .easy,
            servings: 1,
            proteinGramsPerServing: 20,
            requiredEquipment: [.stovetop],
            dietaryTags: [.vegetarian, .glutenFree, .nutFree],
            mealTypes: [.breakfast],
            cuisine: .american
        ),
        ScpRecipe(
            id: "sample-4",
            title: "Spinach and Egg Fried Rice",
            ingredients: [
                item("Rice", 2, .cup),
                item("Egg", 2, .piece),
                item("Spinach", 1, .cup),
                item("Soy sauce", 2, .tablespoon),
                item("Garlic", 2, .piece),
            ],
            instructions: [
                "Scramble the eggs in a hot pan and set them aside.",
                "Fry the garlic, add the rice and soy sauce, and stir for three minutes.",
                "Fold in the spinach and eggs until the spinach wilts.",
            ],
            prepTimeMinutes: 10,
            cookTimeMinutes: 10,
            difficulty: .easy,
            servings: 2,
            proteinGramsPerServing: 14,
            requiredEquipment: [.stovetop],
            dietaryTags: [.vegetarian, .dairyFree, .nutFree],
            mealTypes: [.dinner, .lunch],
            cuisine: .asian
        ),
        ScpRecipe(
            id: "sample-5",
            title: "Air Fryer Garlic Chicken",
            ingredients: [
                item("Chicken breast", 1, .pound),
                item("Garlic", 4, .piece),
                item("Olive oil", 1, .tablespoon),
            ],
            instructions: [
                "Rub the chicken with the oil and minced garlic.",
                "Air fry at 400 degrees Fahrenheit for 18 minutes, flipping halfway.",
            ],
            prepTimeMinutes: 5,
            cookTimeMinutes: 18,
            difficulty: .easy,
            servings: 2,
            proteinGramsPerServing: 35,
            requiredEquipment: [.airFryer],
            dietaryTags: [.dairyFree, .glutenFree, .nutFree],
            mealTypes: [.dinner],
            cuisine: .american
        ),
    ]

    /// Common ingredients for offline autocomplete.
    public static let commonIngredients: [ScpIngredient] = [
        "Chicken breast", "Chicken thigh", "Chicken broth", "Chickpeas", "Chicken drumsticks",
        "Egg", "Milk", "Butter", "Heavy cream", "Parmesan", "Cheddar cheese", "Garlic", "Onion",
        "Tomato", "Spinach", "Rice", "Pasta", "Tortilla", "Soy sauce", "Olive oil", "Flour",
        "Sugar", "Salt", "Black pepper", "Paprika", "Cumin", "Lemon", "Basil", "Potato", "Carrot",
        "Broccoli", "Ground beef", "Bacon", "Frozen peas", "Black beans", "Greek yogurt",
    ].map { ScpIngredient(name: $0) }

    /// A kitchen holding eggs, spinach, rice, garlic, and a stovetop.
    public static let kitchen = ScpKitchen(
        pantryItems: [
            ScpPantryItem(ingredient: ScpIngredient(name: "Egg"), location: .fridge),
            ScpPantryItem(ingredient: ScpIngredient(name: "Spinach"), location: .fridge),
            ScpPantryItem(ingredient: ScpIngredient(name: "Rice")),
            ScpPantryItem(ingredient: ScpIngredient(name: "Garlic")),
        ],
        equipment: [.stovetop]
    )
}

import Foundation

/// The built-in table of ingredient swaps.
///
/// Every option lists how much to use and which dietary needs it satisfies. The
/// flag letters in the source map to `ScpDietaryRestriction`:
/// `v` vegetarian, `n` vegan (also vegetarian and dairy-free), `d` dairy-free,
/// `g` gluten-free, `t` nut-free. Options are deliberately conservative: when an
/// ingredient is only sometimes safe (such as tamari for gluten), the flag is left off.
enum ScpSubstitutionTable {

    /// Swaps keyed by the normalized name of the ingredient being replaced.
    static let entries: [String: [ScpSubstitutionOption]] = {
        var table: [String: [ScpSubstitutionOption]] = [:]
        table["butter"] = [
            ScpSubstitutionOption(name: "Olive oil", ratio: "Use ¾ as much (¾ cup oil for 1 cup butter)", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Coconut oil", ratio: "1:1, melted or solid to match the recipe", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree]),
            ScpSubstitutionOption(name: "Margarine", ratio: "1:1", suitableFor: [.vegetarian, .glutenFree, .nutFree]),
            ScpSubstitutionOption(name: "Applesauce", ratio: "Use ½ as much in cakes and muffins", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Greek yogurt", ratio: "Use ½ as much in baking", suitableFor: [.vegetarian, .glutenFree, .nutFree]),
        ]
        table["milk"] = [
            ScpSubstitutionOption(name: "Oat milk", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Soy milk", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Almond milk", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree]),
            ScpSubstitutionOption(name: "Coconut milk", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree]),
            ScpSubstitutionOption(name: "Evaporated milk and water", ratio: "½ cup evaporated milk + ½ cup water for 1 cup", suitableFor: [.vegetarian, .glutenFree, .nutFree]),
        ]
        table["heavy cream"] = [
            ScpSubstitutionOption(name: "Coconut cream", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree]),
            ScpSubstitutionOption(name: "Milk and butter", ratio: "¾ cup milk + ¼ cup melted butter for 1 cup", suitableFor: [.vegetarian, .glutenFree, .nutFree]),
            ScpSubstitutionOption(name: "Evaporated milk", ratio: "1:1", suitableFor: [.vegetarian, .glutenFree, .nutFree]),
            ScpSubstitutionOption(name: "Half-and-half", ratio: "1:1, a little thinner", suitableFor: [.vegetarian, .glutenFree, .nutFree]),
        ]
        table["half-and-half"] = [
            ScpSubstitutionOption(name: "Milk and heavy cream", ratio: "½ cup milk + ½ cup cream for 1 cup", suitableFor: [.vegetarian, .glutenFree, .nutFree]),
            ScpSubstitutionOption(name: "Milk and butter", ratio: "⅞ cup milk + 1 tbsp melted butter for 1 cup", suitableFor: [.vegetarian, .glutenFree, .nutFree]),
            ScpSubstitutionOption(name: "Evaporated milk", ratio: "1:1", suitableFor: [.vegetarian, .glutenFree, .nutFree]),
            ScpSubstitutionOption(name: "Oat milk", ratio: "1:1, thinner", suitableFor: [.vegetarian, .vegan, .dairyFree, .nutFree]),
        ]
        table["egg"] = [
            ScpSubstitutionOption(name: "Applesauce", ratio: "¼ cup per egg, for baking", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Flax egg", ratio: "1 tbsp ground flax + 3 tbsp water per egg, rest 5 min", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Chia egg", ratio: "1 tbsp chia seeds + 3 tbsp water per egg, rest 5 min", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Mashed banana", ratio: "¼ cup per egg, for baking", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Silken tofu", ratio: "¼ cup blended per egg", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Aquafaba", ratio: "3 tbsp chickpea liquid per egg", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["sour cream"] = [
            ScpSubstitutionOption(name: "Greek yogurt", ratio: "1:1", suitableFor: [.vegetarian, .glutenFree, .nutFree]),
            ScpSubstitutionOption(name: "Plain yogurt", ratio: "1:1, a little thinner", suitableFor: [.vegetarian, .glutenFree, .nutFree]),
            ScpSubstitutionOption(name: "Cottage cheese", ratio: "1:1, blended smooth", suitableFor: [.glutenFree, .nutFree]),
        ]
        table["buttermilk"] = [
            ScpSubstitutionOption(name: "Milk and lemon juice", ratio: "1 cup milk + 1 tbsp lemon juice, rest 5 min", suitableFor: [.vegetarian, .glutenFree, .nutFree]),
            ScpSubstitutionOption(name: "Milk and white vinegar", ratio: "1 cup milk + 1 tbsp vinegar, rest 5 min", suitableFor: [.vegetarian, .glutenFree, .nutFree]),
            ScpSubstitutionOption(name: "Plain yogurt and milk", ratio: "¾ cup yogurt + ¼ cup milk for 1 cup", suitableFor: [.vegetarian, .glutenFree, .nutFree]),
            ScpSubstitutionOption(name: "Soy milk and lemon juice", ratio: "1 cup soy milk + 1 tbsp lemon juice, rest 5 min", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        let yogurtOptions: [ScpSubstitutionOption] = [
            ScpSubstitutionOption(name: "Sour cream", ratio: "1:1", suitableFor: [.vegetarian, .glutenFree, .nutFree]),
            ScpSubstitutionOption(name: "Buttermilk", ratio: "1:1, thinner", suitableFor: [.vegetarian, .glutenFree, .nutFree]),
            ScpSubstitutionOption(name: "Cottage cheese", ratio: "1:1, blended smooth", suitableFor: [.glutenFree, .nutFree]),
        ]
        table["yogurt"] = yogurtOptions
        table["plain yogurt"] = yogurtOptions
        table["greek yogurt"] = yogurtOptions
        table["cream cheese"] = [
            ScpSubstitutionOption(name: "Mascarpone", ratio: "1:1", suitableFor: [.vegetarian, .glutenFree, .nutFree]),
            ScpSubstitutionOption(name: "Greek yogurt", ratio: "1:1, strained if it is watery", suitableFor: [.vegetarian, .glutenFree, .nutFree]),
            ScpSubstitutionOption(name: "Neufchatel", ratio: "1:1", suitableFor: [.vegetarian, .glutenFree, .nutFree]),
        ]
        table["parmesan"] = [
            ScpSubstitutionOption(name: "Pecorino romano", ratio: "1:1", suitableFor: [.glutenFree, .nutFree]),
            ScpSubstitutionOption(name: "Grana padano", ratio: "1:1", suitableFor: [.glutenFree, .nutFree]),
            ScpSubstitutionOption(name: "Asiago", ratio: "1:1", suitableFor: [.glutenFree, .nutFree]),
            ScpSubstitutionOption(name: "Nutritional yeast", ratio: "Use ½ as much", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["cheddar"] = [
            ScpSubstitutionOption(name: "Monterey jack", ratio: "1:1", suitableFor: [.glutenFree, .nutFree]),
            ScpSubstitutionOption(name: "Colby", ratio: "1:1", suitableFor: [.glutenFree, .nutFree]),
            ScpSubstitutionOption(name: "Gouda", ratio: "1:1", suitableFor: [.glutenFree, .nutFree]),
            ScpSubstitutionOption(name: "Vegan cheese shreds", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .dairyFree]),
        ]
        table["mozzarella"] = [
            ScpSubstitutionOption(name: "Provolone", ratio: "1:1", suitableFor: [.glutenFree, .nutFree]),
            ScpSubstitutionOption(name: "Monterey jack", ratio: "1:1", suitableFor: [.glutenFree, .nutFree]),
            ScpSubstitutionOption(name: "Vegan mozzarella", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .dairyFree]),
        ]
        table["ricotta"] = [
            ScpSubstitutionOption(name: "Cottage cheese", ratio: "1:1, drained", suitableFor: [.glutenFree, .nutFree]),
            ScpSubstitutionOption(name: "Crumbled firm tofu and lemon juice", ratio: "1:1 crumbled tofu with 1 tbsp lemon juice per cup", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["mayonnaise"] = [
            ScpSubstitutionOption(name: "Greek yogurt", ratio: "1:1", suitableFor: [.vegetarian, .glutenFree, .nutFree]),
            ScpSubstitutionOption(name: "Sour cream", ratio: "1:1", suitableFor: [.vegetarian, .glutenFree, .nutFree]),
            ScpSubstitutionOption(name: "Mashed avocado", ratio: "1:1, best in sandwiches and salads", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["sugar"] = [
            ScpSubstitutionOption(name: "Honey", ratio: "¾ cup for 1 cup; cut other liquid by ¼ cup", suitableFor: [.vegetarian, .glutenFree, .nutFree]),
            ScpSubstitutionOption(name: "Maple syrup", ratio: "¾ cup for 1 cup; cut other liquid by 3 tbsp", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Brown sugar", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["brown sugar"] = [
            ScpSubstitutionOption(name: "Sugar and molasses", ratio: "1 cup sugar + 1 tbsp molasses", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Sugar", ratio: "1:1, slightly less moist", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Coconut sugar", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree]),
        ]
        table["honey"] = [
            ScpSubstitutionOption(name: "Maple syrup", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Agave syrup", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Sugar and water", ratio: "1 cup sugar + ¼ cup water for 1 cup", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["molasses"] = [
            ScpSubstitutionOption(name: "Maple syrup", ratio: "1:1, milder flavor", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Honey", ratio: "1:1, milder flavor", suitableFor: [.vegetarian, .glutenFree, .nutFree]),
            ScpSubstitutionOption(name: "Dark corn syrup", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["corn syrup"] = [
            ScpSubstitutionOption(name: "Maple syrup", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Honey", ratio: "1:1", suitableFor: [.vegetarian, .glutenFree, .nutFree]),
            ScpSubstitutionOption(name: "Golden syrup", ratio: "1:1", suitableFor: [.vegetarian, .glutenFree, .nutFree]),
        ]
        let flourOptions: [ScpSubstitutionOption] = [
            ScpSubstitutionOption(name: "Bread flour", ratio: "1:1, a bit chewier", suitableFor: [.vegetarian, .vegan, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Whole wheat flour", ratio: "1:1, denser; add a splash more liquid", suitableFor: [.vegetarian, .vegan, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Gluten-free flour blend", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Oat flour", ratio: "1⅓ cups for 1 cup", suitableFor: [.vegetarian, .vegan, .dairyFree, .nutFree]),
        ]
        table["flour"] = flourOptions
        table["all-purpose flour"] = flourOptions
        table["baking powder"] = [
            ScpSubstitutionOption(name: "Baking soda and cream of tartar", ratio: "¼ tsp soda + ½ tsp cream of tartar for 1 tsp", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["baking soda"] = [
            ScpSubstitutionOption(name: "Baking powder", ratio: "Use 3 times as much", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["cornstarch"] = [
            ScpSubstitutionOption(name: "Arrowroot powder", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Potato starch", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "All-purpose flour", ratio: "Use 2 times as much to thicken", suitableFor: [.vegetarian, .vegan, .dairyFree, .nutFree]),
        ]
        table["bread crumbs"] = [
            ScpSubstitutionOption(name: "Panko", ratio: "1:1, crunchier", suitableFor: [.vegetarian, .vegan, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Rolled oats", ratio: "1:1, pulsed fine", suitableFor: [.vegetarian, .vegan, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Crushed crackers", ratio: "1:1", suitableFor: [.vegetarian, .nutFree]),
        ]
        table["cocoa powder"] = [
            ScpSubstitutionOption(name: "Carob powder", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["chocolate chips"] = [
            ScpSubstitutionOption(name: "Chopped chocolate bar", ratio: "1:1", suitableFor: [.glutenFree]),
            ScpSubstitutionOption(name: "Raisins", ratio: "1:1, for a non-chocolate version", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["vanilla extract"] = [
            ScpSubstitutionOption(name: "Maple syrup", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Vanilla bean paste", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Almond extract", ratio: "Use ½ as much", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree]),
        ]
        table["banana"] = [
            ScpSubstitutionOption(name: "Applesauce", ratio: "½ cup per banana, in baking", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Pumpkin puree", ratio: "½ cup per banana, in baking", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["vegetable oil"] = [
            ScpSubstitutionOption(name: "Canola oil", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Olive oil", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Melted butter", ratio: "1:1", suitableFor: [.vegetarian, .glutenFree, .nutFree]),
            ScpSubstitutionOption(name: "Applesauce", ratio: "1:1, in baking only", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["olive oil"] = [
            ScpSubstitutionOption(name: "Vegetable oil", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Avocado oil", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Melted butter", ratio: "1:1", suitableFor: [.vegetarian, .glutenFree, .nutFree]),
        ]
        table["lemon juice"] = [
            ScpSubstitutionOption(name: "Lime juice", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "White wine vinegar", ratio: "Use ½ as much", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["lime juice"] = [
            ScpSubstitutionOption(name: "Lemon juice", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "White wine vinegar", ratio: "Use ½ as much", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        let vinegarOptions: [ScpSubstitutionOption] = [
            ScpSubstitutionOption(name: "Apple cider vinegar", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Lemon juice", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "White wine vinegar", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["vinegar"] = vinegarOptions
        table["white vinegar"] = vinegarOptions
        table["apple cider vinegar"] = [
            ScpSubstitutionOption(name: "White vinegar", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Lemon juice", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Rice vinegar", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["soy sauce"] = [
            ScpSubstitutionOption(name: "Coconut aminos", ratio: "1:1, a bit sweeter", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Tamari", ratio: "1:1; check the label for gluten", suitableFor: [.vegetarian, .vegan, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Liquid aminos", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .dairyFree, .nutFree]),
        ]
        table["tomato paste"] = [
            ScpSubstitutionOption(name: "Tomato sauce", ratio: "Use 3 times as much, then simmer to thicken", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Ketchup", ratio: "1:1, a little sweeter", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["tomato sauce"] = [
            ScpSubstitutionOption(name: "Tomato paste and water", ratio: "½ cup paste + ½ cup water for 1 cup", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Crushed tomatoes", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        let diced_tomatoesOptions: [ScpSubstitutionOption] = [
            ScpSubstitutionOption(name: "Crushed tomatoes", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Tomato sauce", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Fresh tomatoes", ratio: "About 2 cups chopped per can; simmer longer", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["diced tomatoes"] = diced_tomatoesOptions
        table["canned tomatoes"] = diced_tomatoesOptions
        table["dijon mustard"] = [
            ScpSubstitutionOption(name: "Whole grain mustard", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Yellow mustard", ratio: "1:1, milder", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["chicken broth"] = [
            ScpSubstitutionOption(name: "Vegetable broth", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Water and bouillon cube", ratio: "1 cup water + 1 cube", suitableFor: [.nutFree]),
        ]
        table["vegetable broth"] = [
            ScpSubstitutionOption(name: "Chicken broth", ratio: "1:1", suitableFor: [.glutenFree, .nutFree]),
            ScpSubstitutionOption(name: "Water and bouillon cube", ratio: "1 cup water + 1 cube", suitableFor: [.nutFree]),
        ]
        table["white wine"] = [
            ScpSubstitutionOption(name: "Chicken broth and white vinegar", ratio: "1:1 broth with 1 tsp vinegar per ½ cup", suitableFor: [.glutenFree, .nutFree]),
            ScpSubstitutionOption(name: "White grape juice", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["red wine"] = [
            ScpSubstitutionOption(name: "Beef broth and red wine vinegar", ratio: "1:1 broth with 1 tsp vinegar per ½ cup", suitableFor: [.glutenFree, .nutFree]),
            ScpSubstitutionOption(name: "Cranberry juice", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["coconut milk"] = [
            ScpSubstitutionOption(name: "Heavy cream", ratio: "1:1", suitableFor: [.vegetarian, .glutenFree, .nutFree]),
            ScpSubstitutionOption(name: "Whole milk", ratio: "1:1, thinner", suitableFor: [.vegetarian, .glutenFree, .nutFree]),
        ]
        table["peanut butter"] = [
            ScpSubstitutionOption(name: "Almond butter", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree]),
            ScpSubstitutionOption(name: "Sunflower seed butter", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Tahini", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["chicken breast"] = [
            ScpSubstitutionOption(name: "Chicken thighs", ratio: "1:1, cook a bit longer", suitableFor: [.glutenFree, .nutFree]),
            ScpSubstitutionOption(name: "Turkey breast", ratio: "1:1", suitableFor: [.glutenFree, .nutFree]),
            ScpSubstitutionOption(name: "Firm tofu", ratio: "1:1 by weight", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["ground beef"] = [
            ScpSubstitutionOption(name: "Ground turkey", ratio: "1:1", suitableFor: [.glutenFree, .nutFree]),
            ScpSubstitutionOption(name: "Ground chicken", ratio: "1:1", suitableFor: [.glutenFree, .nutFree]),
            ScpSubstitutionOption(name: "Cooked lentils", ratio: "About 1½ cups cooked per pound", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Finely chopped mushrooms", ratio: "1:1 by weight", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["bacon"] = [
            ScpSubstitutionOption(name: "Pancetta", ratio: "1:1", suitableFor: [.glutenFree, .nutFree]),
            ScpSubstitutionOption(name: "Turkey bacon", ratio: "1:1", suitableFor: [.glutenFree, .nutFree]),
            ScpSubstitutionOption(name: "Smoked tofu", ratio: "1:1 by weight", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["shrimp"] = [
            ScpSubstitutionOption(name: "Scallops", ratio: "1:1", suitableFor: [.glutenFree, .nutFree]),
            ScpSubstitutionOption(name: "Firm white fish pieces", ratio: "1:1", suitableFor: [.glutenFree, .nutFree]),
        ]
        table["salmon"] = [
            ScpSubstitutionOption(name: "Trout", ratio: "1:1", suitableFor: [.glutenFree, .nutFree]),
            ScpSubstitutionOption(name: "Arctic char", ratio: "1:1", suitableFor: [.glutenFree, .nutFree]),
        ]
        table["black beans"] = [
            ScpSubstitutionOption(name: "Pinto beans", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Kidney beans", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["kidney beans"] = [
            ScpSubstitutionOption(name: "Black beans", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Pinto beans", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["chickpeas"] = [
            ScpSubstitutionOption(name: "Cannellini beans", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "White beans", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["rice"] = [
            ScpSubstitutionOption(name: "Quinoa", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Couscous", ratio: "1:1, cooks faster", suitableFor: [.vegetarian, .vegan, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Cauliflower rice", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["brown rice"] = [
            ScpSubstitutionOption(name: "White rice", ratio: "1:1, cooks faster", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Quinoa", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["quinoa"] = [
            ScpSubstitutionOption(name: "Rice", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Couscous", ratio: "1:1, cooks faster", suitableFor: [.vegetarian, .vegan, .dairyFree, .nutFree]),
        ]
        table["pasta"] = [
            ScpSubstitutionOption(name: "Rice noodles", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Gluten-free pasta", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Zucchini noodles", ratio: "1:1, no boiling", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["spinach"] = [
            ScpSubstitutionOption(name: "Kale", ratio: "1:1, cook a bit longer", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Swiss chard", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Arugula", ratio: "1:1, best raw", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Frozen spinach", ratio: "⅓ as much, squeezed dry", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["kale"] = [
            ScpSubstitutionOption(name: "Spinach", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Swiss chard", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Collard greens", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["onion"] = [
            ScpSubstitutionOption(name: "Shallots", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Leeks", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Green onions", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Onion powder", ratio: "1 tbsp per medium onion", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["garlic"] = [
            ScpSubstitutionOption(name: "Garlic powder", ratio: "⅛ tsp per clove", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Chives", ratio: "1 tbsp chopped per clove, milder", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["potato"] = [
            ScpSubstitutionOption(name: "Sweet potato", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Cauliflower", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["sweet potato"] = [
            ScpSubstitutionOption(name: "Butternut squash", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Potato", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Carrots", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["carrot"] = [
            ScpSubstitutionOption(name: "Parsnip", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Sweet potato", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["celery"] = [
            ScpSubstitutionOption(name: "Fennel bulb", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Bok choy stalks", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["bell pepper"] = [
            ScpSubstitutionOption(name: "Poblano pepper", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Celery", ratio: "1:1, in cooked dishes", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["mushroom"] = [
            ScpSubstitutionOption(name: "Zucchini", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Eggplant", ratio: "1:1, diced", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["zucchini"] = [
            ScpSubstitutionOption(name: "Yellow squash", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Eggplant", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["broccoli"] = [
            ScpSubstitutionOption(name: "Cauliflower", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Broccolini", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Green beans", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["cauliflower"] = [
            ScpSubstitutionOption(name: "Broccoli", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Romanesco", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["walnut"] = [
            ScpSubstitutionOption(name: "Pecans", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree]),
            ScpSubstitutionOption(name: "Sunflower seeds", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["almond"] = [
            ScpSubstitutionOption(name: "Cashews", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree]),
            ScpSubstitutionOption(name: "Sunflower seeds", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["cilantro"] = [
            ScpSubstitutionOption(name: "Parsley", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Basil", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["parsley"] = [
            ScpSubstitutionOption(name: "Cilantro", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Chives", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Basil", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["basil"] = [
            ScpSubstitutionOption(name: "Oregano", ratio: "Use ½ as much", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Italian seasoning", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["oregano"] = [
            ScpSubstitutionOption(name: "Basil", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Thyme", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Italian seasoning", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["thyme"] = [
            ScpSubstitutionOption(name: "Oregano", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Rosemary", ratio: "Use ½ as much", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Italian seasoning", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["cumin"] = [
            ScpSubstitutionOption(name: "Ground coriander", ratio: "1:1", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Chili powder", ratio: "Use ½ as much", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["chili powder"] = [
            ScpSubstitutionOption(name: "Paprika and cayenne", ratio: "1 tbsp paprika + ¼ tsp cayenne for 1 tbsp", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Cumin and paprika", ratio: "½ tbsp each for 1 tbsp", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["paprika"] = [
            ScpSubstitutionOption(name: "Chili powder", ratio: "1:1, spicier", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
            ScpSubstitutionOption(name: "Cayenne", ratio: "Use ¼ as much, much spicier", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        table["ginger"] = [
            ScpSubstitutionOption(name: "Ground ginger", ratio: "¼ tsp for 1 tbsp fresh", suitableFor: [.vegetarian, .vegan, .glutenFree, .dairyFree, .nutFree]),
        ]
        return table
    }()
}

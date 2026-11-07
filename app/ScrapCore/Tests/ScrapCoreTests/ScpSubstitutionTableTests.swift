import XCTest

@testable import ScrapCore

final class ScpSubstitutionTableTests: XCTestCase {
    private typealias Fx = ScpTestFixtures

    func test_table_coversManyIngredients() {
        XCTAssertGreaterThanOrEqual(ScpSubstitutionTable.entries.count, 60)
    }

    func test_table_everyOptionHasAnAmount() {
        for (key, options) in ScpSubstitutionTable.entries {
            XCTAssertFalse(options.isEmpty, "\(key) has no options")
            for option in options {
                XCTAssertFalse(option.ratio.isEmpty, "\(key) -> \(option.name) has no amount")
                XCTAssertFalse(option.name.isEmpty, "\(key) has an unnamed option")
            }
        }
    }

    func test_table_keysAreNormalized() {
        for key in ScpSubstitutionTable.entries.keys {
            XCTAssertEqual(key, ScpIngredient.normalizedID(for: key))
        }
    }

    func test_table_noIngredientIsItsOwnSwap() {
        for (key, options) in ScpSubstitutionTable.entries {
            XCTAssertFalse(
                options.contains { ScpIngredient.normalizedID(for: $0.name) == key },
                "\(key) lists itself"
            )
        }
    }

    func test_table_veganOptionsAreAlsoVegetarianAndDairyFree() {
        for (key, options) in ScpSubstitutionTable.entries {
            for option in options where option.suitableFor.contains(.vegan) {
                XCTAssertTrue(option.suitableFor.contains(.vegetarian), "\(key) -> \(option.name)")
                XCTAssertTrue(option.suitableFor.contains(.dairyFree), "\(key) -> \(option.name)")
            }
        }
    }

    func test_table_veganOptionsDoNotNameAnimalProducts() {
        let animalWords = ["honey", "cheese", "yogurt", "chicken", "beef", "turkey", "pork", "bacon", "cream cheese"]
        for (key, options) in ScpSubstitutionTable.entries {
            for option in options where option.suitableFor.contains(.vegan) {
                let name = option.name.lowercased()
                guard !name.contains("vegan") else { continue }
                for word in animalWords {
                    XCTAssertFalse(name.contains(word), "\(key) -> \(option.name) is tagged vegan")
                }
            }
        }
    }

    func test_finder_includesTheAmountToUse() {
        let result = ScpSubstitutionFinder().substitutions(for: Fx.ingredient("Butter"), in: ScpKitchen())

        XCTAssertTrue(result.allSatisfy { $0.ratio != nil })
    }

    func test_finder_findsIngredientsDescribedWithExtraWords() {
        let finder = ScpSubstitutionFinder()

        XCTAssertFalse(finder.substitutions(for: Fx.ingredient("Unsalted Butter"), in: ScpKitchen()).isEmpty)
        XCTAssertFalse(finder.substitutions(for: Fx.ingredient("large eggs"), in: ScpKitchen()).isEmpty)
        XCTAssertFalse(finder.substitutions(for: Fx.ingredient("Whole Milk"), in: ScpKitchen()).isEmpty)
        XCTAssertFalse(finder.substitutions(for: Fx.ingredient("Potatoes"), in: ScpKitchen()).isEmpty)
        XCTAssertFalse(finder.substitutions(for: Fx.ingredient("mushrooms"), in: ScpKitchen()).isEmpty)
    }

    func test_finder_doesNotConfuseCompoundIngredients() {
        let finder = ScpSubstitutionFinder()

        let peanutButter = finder.substitutions(for: Fx.ingredient("Peanut Butter"), in: ScpKitchen())

        XCTAssertFalse(peanutButter.contains { $0.replacement.id == "olive oil" })
    }

    func test_finder_hidesSwapsThatBreakDietaryRestrictions() {
        var kitchen = ScpKitchen()
        kitchen.restrictions = [.vegan]

        let result = ScpSubstitutionFinder().substitutions(for: Fx.ingredient("butter"), in: kitchen)

        XCTAssertFalse(result.isEmpty)
        XCTAssertFalse(result.contains { $0.replacement.id == "margarine" })
        XCTAssertFalse(result.contains { $0.replacement.id == "greek yogurt" })
        XCTAssertTrue(result.contains { $0.replacement.id == "olive oil" })
    }

    func test_finder_nutFreeKitchenHidesNutBasedSwaps() {
        var kitchen = ScpKitchen()
        kitchen.restrictions = [.nutFree]

        let result = ScpSubstitutionFinder().substitutions(for: Fx.ingredient("peanut butter"), in: kitchen)

        XCTAssertEqual(Set(result.map(\.replacement.id)), ["sunflower seed butter", "tahini"])
    }

    func test_finder_swapWithTwoPartsIsInKitchenOnlyWhenBothArePresent() {
        let both = Fx.kitchen("milk", "lemon juice")
        let one = Fx.kitchen("milk")
        let finder = ScpSubstitutionFinder()

        let withBoth = finder.substitutions(for: Fx.ingredient("buttermilk"), in: both)
        let withOne = finder.substitutions(for: Fx.ingredient("buttermilk"), in: one)

        XCTAssertEqual(withBoth.first?.replacement.id, "milk and lemon juice")
        XCTAssertEqual(withBoth.first?.isInKitchen, true)
        XCTAssertTrue(withOne.allSatisfy { !$0.isInKitchen })
    }
}

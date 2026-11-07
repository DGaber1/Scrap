import Foundation

/// A kitchen appliance or tool. Equipment a recipe needs but the user lacks
/// counts as a missing item, just like a missing ingredient.
public struct ScpEquipment: Codable, Identifiable, Equatable, Hashable, Sendable {
    public let id: String
    public var name: String

    /// Creates a piece of equipment.
    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }

    /// A small starter set; the real list grows as recipes require more.
    public static let airFryer = ScpEquipment(id: "air-fryer", name: "Air Fryer")
    public static let blender = ScpEquipment(id: "blender", name: "Blender")
    public static let standMixer = ScpEquipment(id: "stand-mixer", name: "Stand Mixer")
    public static let instantPot = ScpEquipment(id: "instant-pot", name: "Instant Pot")
    public static let oven = ScpEquipment(id: "oven", name: "Oven")
    public static let stovetop = ScpEquipment(id: "stovetop", name: "Stovetop")

    /// Every piece of equipment the app knows about, in display order.
    public static let allKnown: [ScpEquipment] = [.stovetop, .oven, .airFryer, .blender, .standMixer, .instantPot]
}

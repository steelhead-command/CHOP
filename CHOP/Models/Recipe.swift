import Foundation

// MARK: - Product

enum Product: String, Codable, CaseIterable {
    case smokedFish
    case roastedNuts
    case driedHerbs
    case bakedBread
    case preserves
    case mapleSyrup
    case smokedMeats
    case charcoal

    var displayName: String {
        switch self {
        case .smokedFish: return "Smoked Fish"
        case .roastedNuts: return "Roasted Nuts"
        case .driedHerbs: return "Dried Herbs"
        case .bakedBread: return "Baked Bread"
        case .preserves: return "Preserves"
        case .mapleSyrup: return "Maple Syrup"
        case .smokedMeats: return "Smoked Meats"
        case .charcoal: return "Charcoal"
        }
    }

    var sellPrice: Int {
        switch self {
        case .smokedFish: return 100
        case .roastedNuts: return 50
        case .driedHerbs: return 80
        case .bakedBread: return 60
        case .preserves: return 150
        case .mapleSyrup: return 250
        case .smokedMeats: return 400
        case .charcoal: return 50
        }
    }

    var emoji: String {
        switch self {
        case .smokedFish: return "🐟"
        case .roastedNuts: return "🥜"
        case .driedHerbs: return "🌿"
        case .bakedBread: return "🍞"
        case .preserves: return "🫙"
        case .mapleSyrup: return "🍯"
        case .smokedMeats: return "🥓"
        case .charcoal: return "ite"
        }
    }
}

// MARK: - Inventory Item

enum InventoryItem: String, Codable, CaseIterable {
    case softWood
    case mediumWood
    case hardWood
    case rawFish
    case rawNuts
    case rawBerries
    case rawHerbs
    case flour
    case sugar
    case mapleSap
    case premiumMeat
    case charcoal
    case whetstones
    case ironScrap

    var displayName: String {
        switch self {
        case .softWood: return "Soft Wood"
        case .mediumWood: return "Medium Wood"
        case .hardWood: return "Hard Wood"
        case .rawFish: return "Raw Fish"
        case .rawNuts: return "Nuts"
        case .rawBerries: return "Berries"
        case .rawHerbs: return "Herbs"
        case .flour: return "Flour"
        case .sugar: return "Sugar"
        case .mapleSap: return "Maple Sap"
        case .premiumMeat: return "Premium Meat"
        case .charcoal: return "Charcoal"
        case .whetstones: return "Whetstones"
        case .ironScrap: return "Iron Scrap"
        }
    }

    var purchasePrice: Int {
        switch self {
        case .softWood: return 2
        case .mediumWood: return 4
        case .hardWood: return 8
        case .rawFish: return 40
        case .rawNuts: return 3  // Per nut
        case .rawBerries: return 2  // Per berry
        case .rawHerbs: return 8  // Per herb
        case .flour: return 20
        case .sugar: return 25
        case .mapleSap: return 60
        case .premiumMeat: return 100
        case .charcoal: return 10
        case .whetstones: return 30
        case .ironScrap: return 15
        }
    }
}

// MARK: - Ingredient Requirement

struct IngredientRequirement: Codable, Equatable {
    let item: InventoryItem
    let quantity: Int
}

// MARK: - Recipe

struct Recipe: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let inputs: [IngredientRequirement]
    let output: Product
    let outputQuantity: Int
    let processingTime: TimeInterval
    let minimumTemperature: Int

    var displayName: String { name }
    var sellPrice: Int { output.sellPrice * outputQuantity }

    var icon: String {
        switch output {
        case .smokedFish: return "fish.fill"
        case .roastedNuts: return "leaf.circle.fill"
        case .driedHerbs: return "leaf.fill"
        case .bakedBread: return "rectangle.fill"
        case .preserves: return "flask.fill"
        case .mapleSyrup: return "drop.fill"
        case .smokedMeats: return "flame.fill"
        case .charcoal: return "square.fill"
        }
    }

    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - All Recipes

extension Recipe {
    static let all: [Recipe] = [
        Recipe(
            id: "roasted_nuts",
            name: "Roasted Nuts",
            inputs: [IngredientRequirement(item: .rawNuts, quantity: 10)],
            output: .roastedNuts,
            outputQuantity: 1,
            processingTime: 15 * 60,  // 15 minutes
            minimumTemperature: 200
        ),
        Recipe(
            id: "smoked_fish",
            name: "Smoked Fish",
            inputs: [
                IngredientRequirement(item: .rawFish, quantity: 1),
                IngredientRequirement(item: .hardWood, quantity: 2)
            ],
            output: .smokedFish,
            outputQuantity: 1,
            processingTime: 30 * 60,  // 30 minutes
            minimumTemperature: 400
        ),
        Recipe(
            id: "dried_herbs",
            name: "Dried Herbs",
            inputs: [IngredientRequirement(item: .rawHerbs, quantity: 5)],
            output: .driedHerbs,
            outputQuantity: 1,
            processingTime: 20 * 60,  // 20 minutes
            minimumTemperature: 150
        ),
        Recipe(
            id: "baked_bread",
            name: "Baked Bread",
            inputs: [IngredientRequirement(item: .flour, quantity: 1)],
            output: .bakedBread,
            outputQuantity: 1,
            processingTime: 25 * 60,  // 25 minutes
            minimumTemperature: 300
        ),
        Recipe(
            id: "preserves",
            name: "Preserves",
            inputs: [
                IngredientRequirement(item: .rawBerries, quantity: 10),
                IngredientRequirement(item: .sugar, quantity: 1)
            ],
            output: .preserves,
            outputQuantity: 1,
            processingTime: 60 * 60,  // 1 hour
            minimumTemperature: 200
        ),
        Recipe(
            id: "maple_syrup",
            name: "Maple Syrup",
            inputs: [IngredientRequirement(item: .mapleSap, quantity: 1)],
            output: .mapleSyrup,
            outputQuantity: 1,
            processingTime: 2 * 60 * 60,  // 2 hours
            minimumTemperature: 400
        ),
        Recipe(
            id: "smoked_meats",
            name: "Smoked Meats",
            inputs: [
                IngredientRequirement(item: .premiumMeat, quantity: 1),
                IngredientRequirement(item: .hardWood, quantity: 2)
            ],
            output: .smokedMeats,
            outputQuantity: 1,
            processingTime: 4 * 60 * 60,  // 4 hours
            minimumTemperature: 500
        ),
        Recipe(
            id: "charcoal",
            name: "Charcoal",
            inputs: [IngredientRequirement(item: .softWood, quantity: 10)],
            output: .charcoal,
            outputQuantity: 1,
            processingTime: 45 * 60,  // 45 minutes
            minimumTemperature: 600
        )
    ]

    static func recipe(for id: String) -> Recipe? {
        all.first { $0.id == id }
    }
}

import Foundation

struct Inventory: Codable {
    // Wood stores
    var softWood: Int
    var mediumWood: Int
    var hardWood: Int

    // Raw materials (gathered)
    var rawFish: Int
    var rawNuts: Int
    var rawBerries: Int
    var rawHerbs: Int

    // Purchasable ingredients
    var flour: Int
    var sugar: Int
    var mapleSap: Int
    var premiumMeat: Int

    // Crafting materials
    var charcoal: Int
    var whetstones: Int
    var ironScrap: Int

    // Processed goods (ready to sell)
    var smokedFish: Int
    var roastedNuts: Int
    var driedHerbs: Int
    var bakedBread: Int
    var preserves: Int
    var mapleSyrup: Int
    var smokedMeats: Int

    // MARK: - Computed Properties

    var totalWood: Int {
        softWood + mediumWood + hardWood
    }

    var wood: [WoodType: Int] {
        [.soft: softWood, .medium: mediumWood, .hard: hardWood]
    }

    func woodCount(for type: WoodType) -> Int {
        switch type {
        case .soft: return softWood
        case .medium: return mediumWood
        case .hard: return hardWood
        }
    }

    var woodValue: Int {
        (softWood * WoodType.soft.sellPrice) +
        (mediumWood * WoodType.medium.sellPrice) +
        (hardWood * WoodType.hard.sellPrice)
    }

    // MARK: - Defaults

    static var initial: Inventory {
        Inventory(
            softWood: 0,
            mediumWood: 0,
            hardWood: 0,
            rawFish: 0,
            rawNuts: 0,
            rawBerries: 0,
            rawHerbs: 0,
            flour: 0,
            sugar: 0,
            mapleSap: 0,
            premiumMeat: 0,
            charcoal: 0,
            whetstones: 0,
            ironScrap: 0,
            smokedFish: 0,
            roastedNuts: 0,
            driedHerbs: 0,
            bakedBread: 0,
            preserves: 0,
            mapleSyrup: 0,
            smokedMeats: 0
        )
    }

    // MARK: - Mutating Methods

    mutating func addWood(_ type: WoodType, count: Int = 1) {
        switch type {
        case .soft:
            softWood += count
        case .medium:
            mediumWood += count
        case .hard:
            hardWood += count
        }
    }

    mutating func removeWood(_ type: WoodType, count: Int = 1) -> Bool {
        switch type {
        case .soft:
            guard softWood >= count else { return false }
            softWood -= count
        case .medium:
            guard mediumWood >= count else { return false }
            mediumWood -= count
        case .hard:
            guard hardWood >= count else { return false }
            hardWood -= count
        }
        return true
    }
}

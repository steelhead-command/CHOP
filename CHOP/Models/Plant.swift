import Foundation

// MARK: - Type Aliases

typealias Plant = PlantedItem

// MARK: - Plant Type

enum PlantType: String, Codable, CaseIterable {
    case hazelTree
    case walnutTree
    case mapleTree
    case blueberryBush
    case raspberryBush
    case blackberryBush
    case herbGarden

    var displayName: String {
        switch self {
        case .hazelTree: return "Hazel Tree"
        case .walnutTree: return "Walnut Tree"
        case .mapleTree: return "Maple Tree"
        case .blueberryBush: return "Blueberry Bush"
        case .raspberryBush: return "Raspberry Bush"
        case .blackberryBush: return "Blackberry Bush"
        case .herbGarden: return "Herb Garden"
        }
    }

    var price: Int {
        switch self {
        case .hazelTree: return 300
        case .walnutTree: return 500
        case .mapleTree: return 800
        case .blueberryBush: return 200
        case .raspberryBush: return 350
        case .blackberryBush: return 500
        case .herbGarden: return 400
        }
    }

    var matureTime: TimeInterval {
        switch self {
        case .hazelTree: return 2 * 24 * 3600       // 2 days
        case .walnutTree: return 3 * 24 * 3600      // 3 days
        case .mapleTree: return 5 * 24 * 3600       // 5 days
        case .blueberryBush: return 1 * 24 * 3600   // 1 day
        case .raspberryBush: return 2 * 24 * 3600   // 2 days
        case .blackberryBush: return 3 * 24 * 3600  // 3 days
        case .herbGarden: return 2 * 24 * 3600      // 2 days
        }
    }

    var harvestCooldown: TimeInterval {
        24 * 3600  // 24 hours for all plants
    }

    var dailyYield: Int {
        switch self {
        case .hazelTree: return 10
        case .walnutTree: return 15
        case .mapleTree: return 1       // 1 sap bucket
        case .blueberryBush: return 15
        case .raspberryBush: return 20
        case .blackberryBush: return 25
        case .herbGarden: return 8
        }
    }

    var yieldItem: InventoryItem {
        switch self {
        case .hazelTree, .walnutTree: return .rawNuts
        case .mapleTree: return .mapleSap
        case .blueberryBush, .raspberryBush, .blackberryBush: return .rawBerries
        case .herbGarden: return .rawHerbs
        }
    }

    var estimatedDailyValue: Int {
        switch self {
        case .hazelTree: return 50
        case .walnutTree: return 75
        case .mapleTree: return 125
        case .blueberryBush: return 35
        case .raspberryBush: return 50
        case .blackberryBush: return 60
        case .herbGarden: return 65
        }
    }

    var emoji: String {
        switch self {
        case .hazelTree, .walnutTree: return "🌳"
        case .mapleTree: return "🍁"
        case .blueberryBush: return "🫐"
        case .raspberryBush: return "🍇"
        case .blackberryBush: return "🫐"
        case .herbGarden: return "🌿"
        }
    }

    var icon: String {
        switch self {
        case .hazelTree, .walnutTree, .mapleTree: return "tree.fill"
        case .blueberryBush, .raspberryBush, .blackberryBush: return "leaf.circle.fill"
        case .herbGarden: return "leaf.fill"
        }
    }

    // Simplified categorization for GatheringHubView
    static var berryBush: PlantType { .blueberryBush }
    static var nutTree: PlantType { .hazelTree }
}

// MARK: - Planted Item

struct PlantedItem: Codable, Identifiable {
    let id: UUID
    let type: PlantType
    let plantedAt: Date
    var lastHarvestedAt: Date?

    init(type: PlantType) {
        self.id = UUID()
        self.type = type
        self.plantedAt = Date()
        self.lastHarvestedAt = nil
    }

    // MARK: - Computed Properties

    var isMatured: Bool {
        Date() >= plantedAt.addingTimeInterval(type.matureTime)
    }

    var maturityProgress: Double {
        let elapsed = Date().timeIntervalSince(plantedAt)
        return min(1.0, elapsed / type.matureTime)
    }

    var timeUntilMature: TimeInterval? {
        guard !isMatured else { return nil }
        return plantedAt.addingTimeInterval(type.matureTime).timeIntervalSince(Date())
    }

    var harvestReady: Bool {
        guard isMatured else { return false }
        guard let lastHarvest = lastHarvestedAt else { return true }
        return Date() >= lastHarvest.addingTimeInterval(type.harvestCooldown)
    }

    var timeUntilHarvest: TimeInterval? {
        guard isMatured else { return timeUntilMature }
        guard let lastHarvest = lastHarvestedAt else { return nil }
        let nextHarvest = lastHarvest.addingTimeInterval(type.harvestCooldown)
        let remaining = nextHarvest.timeIntervalSince(Date())
        return remaining > 0 ? remaining : nil
    }

    var availableYield: Int {
        harvestReady ? type.dailyYield : 0
    }

    // MARK: - Mutating

    mutating func harvest() -> Int {
        guard harvestReady else { return 0 }
        lastHarvestedAt = Date()
        return type.dailyYield
    }
}

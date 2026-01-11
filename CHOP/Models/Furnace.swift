import Foundation
import SwiftUI

// MARK: - Type Aliases

typealias FurnaceSlot = ProcessingSlot

// MARK: - Furnace Tier

enum FurnaceTier: String, Codable, CaseIterable {
    case stoneHearth
    case brickFurnace
    case ironClad
    case greatForge

    var displayName: String {
        switch self {
        case .stoneHearth: return "Stone Hearth"
        case .brickFurnace: return "Brick Furnace"
        case .ironClad: return "Iron-Clad Furnace"
        case .greatForge: return "Great Forge"
        }
    }

    var maxSlots: Int {
        switch self {
        case .stoneHearth: return 1
        case .brickFurnace: return 2
        case .ironClad: return 2
        case .greatForge: return 3
        }
    }

    var upgradePrice: Int {
        switch self {
        case .stoneHearth: return 0
        case .brickFurnace: return 500
        case .ironClad: return 1500
        case .greatForge: return 4000
        }
    }

    var charcoalRequired: Int {
        switch self {
        case .stoneHearth: return 0
        case .brickFurnace: return 0
        case .ironClad: return 5
        case .greatForge: return 20
        }
    }

    var logsRequiredToUnlock: Int {
        switch self {
        case .stoneHearth: return 0
        case .brickFurnace: return 100
        case .ironClad: return 500
        case .greatForge: return 2000
        }
    }

    var next: FurnaceTier? {
        switch self {
        case .stoneHearth: return .brickFurnace
        case .brickFurnace: return .ironClad
        case .ironClad: return .greatForge
        case .greatForge: return nil
        }
    }

}

// MARK: - Furnace State

struct FurnaceState: Codable {
    var tier: FurnaceTier
    var currentTemperature: Int
    var fuelRemaining: TimeInterval
    var lastUpdatedAt: Date
    var processingSlots: [ProcessingSlot]
    var completedProducts: [CompletedProduct]

    // MARK: - Computed Properties

    var temperatureState: TemperatureState {
        switch currentTemperature {
        case 0..<200: return .cold
        case 200..<500: return .warm
        case 500..<800: return .hot
        default: return .veryHot
        }
    }

    var isBurning: Bool {
        fuelRemaining > 0
    }

    var currentFuel: WoodType? {
        isBurning ? .medium : nil  // Simplified; in full implementation would track actual fuel type
    }

    // MARK: - Update Temperature

    mutating func update() {
        let elapsed = Date().timeIntervalSince(lastUpdatedAt)
        fuelRemaining = max(0, fuelRemaining - elapsed)

        if fuelRemaining <= 0 {
            // Temperature decays when no fuel
            let decay = Int(elapsed / 60) * 10
            currentTemperature = max(0, currentTemperature - decay)
        }

        lastUpdatedAt = Date()
    }

    mutating func addFuel(woodType: WoodType, count: Int) {
        fuelRemaining += woodType.burnTime * Double(count)
        currentTemperature = min(1000, currentTemperature + woodType.temperatureContribution)
    }

    // MARK: - Defaults

    static var initial: FurnaceState {
        FurnaceState(
            tier: .stoneHearth,
            currentTemperature: 0,
            fuelRemaining: 0,
            lastUpdatedAt: Date(),
            processingSlots: [ProcessingSlot()],
            completedProducts: []
        )
    }
}

// MARK: - Temperature State

enum TemperatureState: CustomStringConvertible {
    case cold
    case warm
    case hot
    case veryHot

    var displayName: String {
        switch self {
        case .cold: return "Cold"
        case .warm: return "Warm"
        case .hot: return "Hot"
        case .veryHot: return "Very Hot"
        }
    }

    var description: String { displayName }

    var uiColor: Color {
        switch self {
        case .cold: return .furnaceCold
        case .warm: return .furnaceWarm
        case .hot: return .furnaceHot
        case .veryHot: return .furnaceVeryHot
        }
    }
}

// MARK: - Processing Slot

struct ProcessingSlot: Codable, Identifiable {
    let id: UUID
    var recipe: Recipe?
    var startedAt: Date?

    init(id: UUID = UUID(), recipe: Recipe? = nil, startedAt: Date? = nil) {
        self.id = id
        self.recipe = recipe
        self.startedAt = startedAt
    }

    var progress: Double? {
        guard let recipe = recipe, let started = startedAt else { return nil }
        let elapsed = Date().timeIntervalSince(started)
        return min(1.0, elapsed / recipe.processingTime)
    }

    var isComplete: Bool {
        guard let progress = progress else { return false }
        return progress >= 1.0
    }

    var remainingTime: TimeInterval? {
        guard let recipe = recipe, let started = startedAt else { return nil }
        let elapsed = Date().timeIntervalSince(started)
        return max(0, recipe.processingTime - elapsed)
    }

    var isEmpty: Bool {
        recipe == nil
    }
}

// MARK: - Completed Product

struct CompletedProduct: Codable, Identifiable {
    let id: UUID
    let product: Product
    let quantity: Int
    let completedAt: Date

    init(product: Product, quantity: Int = 1) {
        self.id = UUID()
        self.product = product
        self.quantity = quantity
        self.completedAt = Date()
    }
}

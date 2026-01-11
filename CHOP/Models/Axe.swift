import SwiftUI

// MARK: - Axe Type

enum AxeType: String, Codable, CaseIterable {
    case sharp
    case balanced
    case heavy
    case diamond

    var displayName: String {
        switch self {
        case .sharp: return "Sharp"
        case .balanced: return "Balanced"
        case .heavy: return "Heavy"
        case .diamond: return "Diamond"
        }
    }

    var description: String {
        switch self {
        case .sharp: return "One-chops almost everything. Low durability."
        case .balanced: return "Versatile and reliable. Moderate durability."
        case .heavy: return "Usually two-chops. Very durable."
        case .diamond: return "Never needs repair. Balanced performance."
        }
    }

    var baseDurability: Int {
        switch self {
        case .sharp: return 40
        case .balanced: return 70
        case .heavy: return 100
        case .diamond: return Int.max
        }
    }
}

// MARK: - Axe Tier

enum AxeTier: String, Codable, CaseIterable {
    case basic
    case mid
    case premium
    case master
    case diamond

    var displayName: String {
        switch self {
        case .basic: return "Basic"
        case .mid: return "Mid-Tier"
        case .premium: return "Premium"
        case .master: return "Master"
        case .diamond: return "Diamond"
        }
    }

    var durabilityMultiplier: Double {
        switch self {
        case .basic: return 1.0
        case .mid: return 1.15
        case .premium: return 1.3
        case .master: return 1.45
        case .diamond: return Double.infinity
        }
    }

    var price: Int {
        switch self {
        case .basic: return 150
        case .mid: return 400
        case .premium: return 800
        case .master: return 1500
        case .diamond: return 0  // Real money purchase
        }
    }

    func baseDurability(for type: AxeType) -> Int {
        let base = type.baseDurability
        return type == .diamond ? Int.max : Int(Double(base) * durabilityMultiplier)
    }

    func tierName(for type: AxeType) -> String {
        switch (type, self) {
        case (.sharp, .basic): return "Basic Sharp"
        case (.sharp, .mid): return "Keen Edge"
        case (.sharp, .premium): return "Razor"
        case (.sharp, .master): return "Master's Razor"

        case (.balanced, .basic): return "Basic Balanced"
        case (.balanced, .mid): return "Tempered"
        case (.balanced, .premium): return "Forgemaster"
        case (.balanced, .master): return "Master's Axe"

        case (.heavy, .basic): return "Basic Heavy"
        case (.heavy, .mid): return "Forged Heavy"
        case (.heavy, .premium): return "Ironclad"
        case (.heavy, .master): return "Unbreakable"

        case (.diamond, _): return "Diamond Axe"

        default: return "\(self.displayName) \(type.displayName)"
        }
    }
}

// MARK: - Owned Axe

struct OwnedAxe: Codable, Identifiable, Equatable {
    let id: UUID
    let type: AxeType
    let tier: AxeTier
    var currentDurability: Int
    var maxDurability: Int
    var cosmeticSkin: String?
    var isEquipped: Bool

    // MARK: - Computed Properties

    var displayName: String {
        tier.tierName(for: type)
    }

    var durabilityPercent: Double {
        guard maxDurability > 0 else { return 1.0 }
        return Double(currentDurability) / Double(maxDurability)
    }

    var isDiamond: Bool {
        type == .diamond
    }

    var isBroken: Bool {
        !isDiamond && currentDurability <= 0
    }

    var needsRepair: Bool {
        !isDiamond && durabilityPercent < 0.25
    }

    // MARK: - Repair Costs

    var repairCostCoins: Int {
        guard !isDiamond else { return 0 }
        let basePrice = tier.price
        let damagePercent = 1.0 - durabilityPercent

        let costPercent: Double
        switch damagePercent {
        case 0..<0.25: costPercent = 0.10
        case 0.25..<0.50: costPercent = 0.15
        case 0.50..<0.75: costPercent = 0.25
        case 0.75..<1.0: costPercent = 0.35
        default: costPercent = 0.50
        }

        return Int(Double(basePrice) * costPercent)
    }

    var repairCostAmber: Int {
        return 25  // Flat rate for instant repair
    }

    // MARK: - Factory

    static func create(type: AxeType, tier: AxeTier) -> OwnedAxe {
        let baseDurability = type.baseDurability
        let maxDurability = type == .diamond
            ? Int.max
            : Int(Double(baseDurability) * tier.durabilityMultiplier)

        return OwnedAxe(
            id: UUID(),
            type: type,
            tier: tier,
            currentDurability: maxDurability,
            maxDurability: maxDurability,
            cosmeticSkin: nil,
            isEquipped: false
        )
    }

    static var starterAxe: OwnedAxe {
        var axe = OwnedAxe.create(type: .balanced, tier: .basic)
        axe.currentDurability = 50  // Slightly worn to encourage upgrade
        axe.isEquipped = true
        return axe
    }
}

// MARK: - Chop Calculation

extension OwnedAxe {
    /// Returns the number of chops required for a given wood type
    func chopsRequired(for woodType: WoodType) -> Int {
        switch (type, woodType) {
        // Sharp axes
        case (.sharp, .soft): return 1
        case (.sharp, .medium): return 1
        case (.sharp, .hard): return Bool.random() ? 1 : 2  // 50/50

        // Balanced axes
        case (.balanced, .soft): return 1
        case (.balanced, .medium): return Double.random(in: 0...1) < 0.7 ? 1 : 2
        case (.balanced, .hard): return 2

        // Heavy axes
        case (.heavy, .soft): return Double.random(in: 0...1) < 0.8 ? 1 : 2
        case (.heavy, .medium): return 2
        case (.heavy, .hard): return 2

        // Diamond (balanced stats)
        case (.diamond, .soft): return 1
        case (.diamond, .medium): return Double.random(in: 0...1) < 0.7 ? 1 : 2
        case (.diamond, .hard): return 2
        }
    }
}

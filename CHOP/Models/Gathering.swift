import Foundation

// MARK: - Gathering Activity

enum GatheringActivity: String, Codable, CaseIterable, Identifiable {
    var id: String { rawValue }
    case fishing
    case berries
    case nuts
    case herbs

    var displayName: String {
        switch self {
        case .fishing: return "Fishing Hole"
        case .berries: return "Berry Fields"
        case .nuts: return "Nut Grove"
        case .herbs: return "Herb Meadow"
        }
    }

    var description: String {
        switch self {
        case .fishing: return "The fish are biting!"
        case .berries: return "Bushes are full."
        case .nuts: return "Time to shake some trees."
        case .herbs: return "Fragrant herbs await."
        }
    }

    var cooldown: TimeInterval {
        switch self {
        case .fishing: return 4 * 3600      // 4 hours
        case .berries: return 6 * 3600      // 6 hours
        case .nuts: return 8 * 3600         // 8 hours
        case .herbs: return 8 * 3600        // 8 hours
        }
    }

    var yield: Int {
        switch self {
        case .fishing: return 5       // 5 fish
        case .berries: return 15      // 15 berries
        case .nuts: return 10         // 10 nuts
        case .herbs: return 8         // 8 herbs
        }
    }

    var unlockRequirement: FurnaceTier? {
        switch self {
        case .herbs: return .brickFurnace
        default: return nil
        }
    }

    var emoji: String {
        switch self {
        case .fishing: return "🎣"
        case .berries: return "🫐"
        case .nuts: return "🌰"
        case .herbs: return "🌿"
        }
    }

    var yieldItem: InventoryItem {
        switch self {
        case .fishing: return .rawFish
        case .berries: return .rawBerries
        case .nuts: return .rawNuts
        case .herbs: return .rawHerbs
        }
    }
}

// MARK: - Gathering State

struct GatheringState: Codable {
    var fishingLastCompleted: Date?
    var berriesLastCompleted: Date?
    var nutsLastCompleted: Date?
    var herbsLastCompleted: Date?

    static var initial: GatheringState {
        GatheringState(
            fishingLastCompleted: nil,
            berriesLastCompleted: nil,
            nutsLastCompleted: nil,
            herbsLastCompleted: nil
        )
    }

    func isReady(_ activity: GatheringActivity) -> Bool {
        guard let last = lastCompleted(activity) else { return true }
        return Date() >= last.addingTimeInterval(activity.cooldown)
    }

    func timeUntilReady(_ activity: GatheringActivity) -> TimeInterval? {
        guard let last = lastCompleted(activity) else { return nil }
        let readyTime = last.addingTimeInterval(activity.cooldown)
        let remaining = readyTime.timeIntervalSince(Date())
        return remaining > 0 ? remaining : nil
    }

    private func lastCompleted(_ activity: GatheringActivity) -> Date? {
        switch activity {
        case .fishing: return fishingLastCompleted
        case .berries: return berriesLastCompleted
        case .nuts: return nutsLastCompleted
        case .herbs: return herbsLastCompleted
        }
    }

    mutating func markCompleted(_ activity: GatheringActivity) {
        switch activity {
        case .fishing: fishingLastCompleted = Date()
        case .berries: berriesLastCompleted = Date()
        case .nuts: nutsLastCompleted = Date()
        case .herbs: herbsLastCompleted = Date()
        }
    }
}

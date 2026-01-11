import Foundation

struct Statistics: Codable {
    // Run statistics
    var totalRuns: Int
    var highScore: Int
    var totalLogsChopped: Int
    var longestStreak: Int

    // Per wood type
    var softWoodChopped: Int
    var mediumWoodChopped: Int
    var hardWoodChopped: Int

    // Knot statistics
    var knotsEncountered: Int
    var knotsBroken: Int
    var knotsFailed: Int

    // Economy statistics
    var totalCoinsEarned: Int
    var totalCoinsSpent: Int
    var totalProductsSold: Int

    // Gathering statistics
    var fishCaught: Int
    var berriesPicked: Int
    var nutsGathered: Int
    var herbsCollected: Int

    // Axe statistics
    var axesBroken: Int
    var axesRepaired: Int

    // Time statistics
    var totalPlayTime: TimeInterval
    var longestSession: TimeInterval

    // MARK: - Computed Properties

    var knotSuccessRate: Double {
        guard knotsEncountered > 0 else { return 0 }
        return Double(knotsBroken) / Double(knotsEncountered)
    }

    var averageLogsPerRun: Double {
        guard totalRuns > 0 else { return 0 }
        return Double(totalLogsChopped) / Double(totalRuns)
    }

    // MARK: - Defaults

    static var initial: Statistics {
        Statistics(
            totalRuns: 0,
            highScore: 0,
            totalLogsChopped: 0,
            longestStreak: 0,
            softWoodChopped: 0,
            mediumWoodChopped: 0,
            hardWoodChopped: 0,
            knotsEncountered: 0,
            knotsBroken: 0,
            knotsFailed: 0,
            totalCoinsEarned: 0,
            totalCoinsSpent: 0,
            totalProductsSold: 0,
            fishCaught: 0,
            berriesPicked: 0,
            nutsGathered: 0,
            herbsCollected: 0,
            axesBroken: 0,
            axesRepaired: 0,
            totalPlayTime: 0,
            longestSession: 0
        )
    }
}

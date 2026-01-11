import Foundation

// MARK: - Log

struct Log {
    let id: UUID
    let woodType: WoodType
    let hasKnot: Bool
    let grainAngle: Double
    var chopsRequired: Int
    var currentChops: Int

    init(woodType: WoodType, hasKnot: Bool, chopsRequired: Int) {
        self.id = UUID()
        self.woodType = woodType
        self.hasKnot = hasKnot
        self.grainAngle = Double.random(in: -15...15)
        self.chopsRequired = chopsRequired
        self.currentChops = 0
    }

    var isSplit: Bool {
        currentChops >= chopsRequired
    }
}

// MARK: - Knot State

enum KnotState: Equatable {
    case awaitingStrike(number: Int)
    case waitPeriod(strike: Int, remaining: TimeInterval)
    case windowOpen(strike: Int, remaining: TimeInterval)
    case success
    case failed

    static let waitPeriods: [Int: TimeInterval] = [1: 0.4, 2: 0.35, 3: 0.3]
    static let windowDurations: [Int: TimeInterval] = [1: 0.6, 2: 0.5, 3: 0.45]
}

// MARK: - Run State

struct RunState {
    var score: Int
    var logsChopped: Int
    var strikes: Int
    var currentMultiplier: Double
    var consecutiveOneChops: Int

    var equippedAxe: OwnedAxe
    var currentDurability: Int

    var currentLog: Log?
    var logQueue: [Log]

    var woodHarvested: [WoodType: Int]
    var amberFound: Int

    var runStartedAt: Date
    var knotState: KnotState?

    // MARK: - Computed

    var isGameOver: Bool {
        strikes >= 3 || currentDurability <= 0
    }

    var gameOverReason: GameOverReason? {
        if strikes >= 3 { return .maxStrikes }
        if currentDurability <= 0 { return .axeBroken }
        return nil
    }

    // MARK: - Factory

    static func new(with axe: OwnedAxe) -> RunState {
        RunState(
            score: 0,
            logsChopped: 0,
            strikes: 0,
            currentMultiplier: 1.0,
            consecutiveOneChops: 0,
            equippedAxe: axe,
            currentDurability: axe.currentDurability,
            currentLog: nil,
            logQueue: [],
            woodHarvested: [.soft: 0, .medium: 0, .hard: 0],
            amberFound: 0,
            runStartedAt: Date(),
            knotState: nil
        )
    }
}

// MARK: - Game Over Reason

enum GameOverReason: String, Codable {
    case maxStrikes
    case axeBroken
    case playerQuit

    var title: String {
        switch self {
        case .maxStrikes: return "Run Complete"
        case .axeBroken: return "Axe Broken!"
        case .playerQuit: return "Run Ended"
        }
    }

    var message: String {
        switch self {
        case .maxStrikes: return "Three strikes and you're out!"
        case .axeBroken: return "Your axe couldn't take any more."
        case .playerQuit: return "You ended the run early."
        }
    }
}

// MARK: - Run Result

struct RunResult: Equatable {
    let score: Int
    let logsChopped: Int
    let woodHarvested: [WoodType: Int]
    let amberFound: Int
    let gameOverReason: GameOverReason
    let isNewHighScore: Bool
    let previousHighScore: Int
    let duration: TimeInterval
    let axeDurabilityRemaining: Int
    let axeType: AxeType
    let axeTier: AxeTier

    var totalWoodValue: Int {
        woodHarvested.reduce(0) { total, pair in
            total + (pair.key.sellPrice * pair.value)
        }
    }

    var softWood: Int { woodHarvested[.soft] ?? 0 }
    var mediumWood: Int { woodHarvested[.medium] ?? 0 }
    var hardWood: Int { woodHarvested[.hard] ?? 0 }

    static func == (lhs: RunResult, rhs: RunResult) -> Bool {
        lhs.score == rhs.score && lhs.logsChopped == rhs.logsChopped
    }
}

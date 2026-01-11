import Foundation

struct PlayerState: Codable {
    // Currency
    var coins: Int
    var amber: Int

    // Progression
    var totalLogsChopped: Int
    var highScore: Int

    // Settings
    var hapticEnabled: Bool
    var soundEnabled: Bool
    var musicEnabled: Bool

    // Timestamps
    var lastPlayedAt: Date
    var accountCreatedAt: Date

    // Premium purchases
    var hasDiamondAxe: Bool
    var purchasedAmberTotal: Int

    // MARK: - Defaults

    static var initial: PlayerState {
        PlayerState(
            coins: 0,
            amber: 0,
            totalLogsChopped: 0,
            highScore: 0,
            hapticEnabled: true,
            soundEnabled: true,
            musicEnabled: true,
            lastPlayedAt: Date(),
            accountCreatedAt: Date(),
            hasDiamondAxe: false,
            purchasedAmberTotal: 0
        )
    }
}

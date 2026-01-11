import Foundation

struct GameSave: Codable {
    var playerState: PlayerState
    var inventory: Inventory
    var ownedAxes: [OwnedAxe]
    var plants: [PlantedItem]
    var furnaceState: FurnaceState
    var gatheringState: GatheringState
    var statistics: Statistics
    var dailyDeals: DailyDeals

    var savedAt: Date
    var gameVersion: String

    // MARK: - Computed

    var equippedAxe: OwnedAxe? {
        ownedAxes.first { $0.isEquipped }
    }

    // MARK: - Initial State

    static func newGame() -> GameSave {
        GameSave(
            playerState: .initial,
            inventory: .initial,
            ownedAxes: [OwnedAxe.starterAxe],
            plants: [],
            furnaceState: .initial,
            gatheringState: .initial,
            statistics: .initial,
            dailyDeals: .generate(),
            savedAt: Date(),
            gameVersion: "1.0.0"
        )
    }

    // MARK: - Persistence Keys

    private static let saveKey = "CHOPGameSave"

    static func load() -> GameSave? {
        guard let data = UserDefaults.standard.data(forKey: saveKey) else { return nil }
        return try? JSONDecoder().decode(GameSave.self, from: data)
    }

    func save() {
        var copy = self
        copy.savedAt = Date()
        if let data = try? JSONEncoder().encode(copy) {
            UserDefaults.standard.set(data, forKey: GameSave.saveKey)
        }
    }

    static func deleteSave() {
        UserDefaults.standard.removeObject(forKey: saveKey)
    }
}

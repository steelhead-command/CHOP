import SwiftUI
import Combine

@MainActor
class GameStateManager: ObservableObject {
    // MARK: - Published State

    @Published var gameSave: GameSave
    @Published var currentRun: RunState?
    @Published var isInRun: Bool = false

    // MARK: - Convenience Accessors

    var playerState: PlayerState {
        get { gameSave.playerState }
        set { gameSave.playerState = newValue }
    }

    var inventory: Inventory {
        get { gameSave.inventory }
        set { gameSave.inventory = newValue }
    }

    var ownedAxes: [OwnedAxe] {
        get { gameSave.ownedAxes }
        set { gameSave.ownedAxes = newValue }
    }

    var equippedAxe: OwnedAxe? {
        ownedAxes.first { $0.isEquipped }
    }

    var furnaceState: FurnaceState {
        get { gameSave.furnaceState }
        set { gameSave.furnaceState = newValue }
    }

    var gatheringState: GatheringState {
        get { gameSave.gatheringState }
        set { gameSave.gatheringState = newValue }
    }

    var statistics: Statistics {
        get { gameSave.statistics }
        set { gameSave.statistics = newValue }
    }

    var dailyDeals: DailyDeals {
        get { gameSave.dailyDeals }
        set { gameSave.dailyDeals = newValue }
    }

    var coins: Int {
        get { playerState.coins }
        set { playerState.coins = newValue }
    }

    var amber: Int {
        get { playerState.amber }
        set { playerState.amber = newValue }
    }

    // MARK: - Initialization

    init() {
        if let saved = GameSave.load() {
            self.gameSave = saved
        } else {
            self.gameSave = GameSave.newGame()
        }

        // Refresh daily deals if expired
        if gameSave.dailyDeals.isExpired {
            gameSave.dailyDeals = DailyDeals.generate()
        }

        // Update furnace state
        gameSave.furnaceState.update()
    }

    // MARK: - Save

    func save() {
        gameSave.save()
    }

    // MARK: - Currency

    func addCoins(_ amount: Int) {
        coins += amount
        statistics.totalCoinsEarned += amount
        save()
    }

    func spendCoins(_ amount: Int) -> Bool {
        guard coins >= amount else { return false }
        coins -= amount
        statistics.totalCoinsSpent += amount
        save()
        return true
    }

    func addAmber(_ amount: Int) {
        amber += amount
        save()
    }

    func spendAmber(_ amount: Int) -> Bool {
        guard amber >= amount else { return false }
        amber -= amount
        save()
        return true
    }

    // MARK: - Axe Management

    func equipAxe(_ axe: OwnedAxe) {
        for i in ownedAxes.indices {
            ownedAxes[i].isEquipped = (ownedAxes[i].id == axe.id)
        }
        save()
    }

    func repairAxe(_ axe: OwnedAxe, withAmber: Bool = false) -> Bool {
        guard let index = ownedAxes.firstIndex(where: { $0.id == axe.id }) else { return false }

        if withAmber {
            guard spendAmber(axe.repairCostAmber) else { return false }
        } else {
            guard spendCoins(axe.repairCostCoins) else { return false }
        }

        ownedAxes[index].currentDurability = ownedAxes[index].maxDurability
        statistics.axesRepaired += 1
        save()
        return true
    }

    func purchaseAxe(type: AxeType, tier: AxeTier) -> Bool {
        guard spendCoins(tier.price) else { return false }

        let newAxe = OwnedAxe.create(type: type, tier: tier)
        ownedAxes.append(newAxe)
        save()
        return true
    }

    // MARK: - Run Management

    func startRun() -> Bool {
        guard let axe = equippedAxe, !axe.isBroken else { return false }

        currentRun = RunState.new(with: axe)
        isInRun = true
        return true
    }

    func endRun() -> RunResult? {
        guard var run = currentRun else { return nil }

        let isNewHighScore = run.score > playerState.highScore
        let previousHighScore = playerState.highScore

        if isNewHighScore {
            playerState.highScore = run.score
        }

        // Update statistics
        statistics.totalRuns += 1
        statistics.totalLogsChopped += run.logsChopped
        statistics.softWoodChopped += run.woodHarvested[.soft] ?? 0
        statistics.mediumWoodChopped += run.woodHarvested[.medium] ?? 0
        statistics.hardWoodChopped += run.woodHarvested[.hard] ?? 0

        if run.consecutiveOneChops > statistics.longestStreak {
            statistics.longestStreak = run.consecutiveOneChops
        }

        // Add wood to inventory
        for (woodType, count) in run.woodHarvested {
            inventory.addWood(woodType, count: count)
        }

        // Add amber
        amber += run.amberFound

        // Update player totals
        playerState.totalLogsChopped += run.logsChopped

        // Update axe durability
        if let index = ownedAxes.firstIndex(where: { $0.id == run.equippedAxe.id }) {
            ownedAxes[index].currentDurability = run.currentDurability
            if run.currentDurability <= 0 {
                statistics.axesBroken += 1
            }
        }

        let result = RunResult(
            score: run.score,
            logsChopped: run.logsChopped,
            woodHarvested: run.woodHarvested,
            amberFound: run.amberFound,
            gameOverReason: run.gameOverReason ?? .playerQuit,
            isNewHighScore: isNewHighScore,
            previousHighScore: previousHighScore,
            duration: Date().timeIntervalSince(run.runStartedAt),
            axeDurabilityRemaining: run.currentDurability,
            axeType: run.equippedAxe.type,
            axeTier: run.equippedAxe.tier
        )

        currentRun = nil
        isInRun = false
        save()

        return result
    }

    // MARK: - Furnace

    func addFuel(woodType: WoodType, count: Int) -> Bool {
        guard inventory.removeWood(woodType, count: count) else { return false }
        furnaceState.addFuel(woodType: woodType, count: count)
        save()
        return true
    }

    func addFuel(_ woodType: WoodType) {
        _ = addFuel(woodType: woodType, count: 1)
    }

    func startProcessing(recipe: Recipe, inSlot slotIndex: Int) {
        guard slotIndex < furnaceState.processingSlots.count else { return }
        furnaceState.processingSlots[slotIndex] = ProcessingSlot(recipe: recipe, startedAt: Date())
        save()
    }

    func saveGame() {
        save()
    }

    // MARK: - Plants

    func purchasePlant(type: PlantType) -> Bool {
        guard spendCoins(type.price) else { return false }

        let plant = PlantedItem(type: type)
        gameSave.plants.append(plant)
        save()
        return true
    }

    func harvestPlant(at index: Int) -> Int {
        guard gameSave.plants.indices.contains(index) else { return 0 }

        var plant = gameSave.plants[index]
        let yield = plant.harvest()

        if yield > 0 {
            gameSave.plants[index] = plant

            // Add to inventory based on type
            switch plant.type.yieldItem {
            case .rawNuts:
                inventory.rawNuts += yield
            case .rawBerries:
                inventory.rawBerries += yield
            case .rawHerbs:
                inventory.rawHerbs += yield
            case .mapleSap:
                inventory.mapleSap += yield
            default:
                break
            }

            save()
        }

        return yield
    }
}

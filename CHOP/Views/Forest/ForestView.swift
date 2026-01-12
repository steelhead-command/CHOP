import SwiftUI

struct ForestView: View {
    @EnvironmentObject var gameState: GameStateManager
    @EnvironmentObject var audioManager: AudioManager
    @Binding var currentScreen: AppScreen

    @StateObject private var choppingState = ChoppingSceneState()
    @State private var runState: RunState?
    @State private var showNopePopup = false
    @State private var nopeMessage = "NOPE!"
    @State private var screenShake = false

    private let nopeMessages = [
        "NOPE!",
        "Stubborn log!",
        "That one fought back!",
        "Nuh-uh!",
        "Not today!"
    ]

    var body: some View {
        ZStack {
            // Full chopping scene with background, log, block, axe
            ChoppingScene(
                sceneState: choppingState,
                currentLog: runState?.currentLog,
                equippedAxe: runState?.equippedAxe,
                knotState: runState?.knotState,
                onChop: handleChop
            )
            .modifier(ShakeEffect(shake: screenShake))

            // HUD overlay
            VStack(spacing: 0) {
                ForestHUD(runState: runState)
                    .padding(.horizontal)
                    .padding(.top, 8)

                Spacer()

                // Durability bar
                if let run = runState {
                    DurabilityBar(current: run.currentDurability, max: run.equippedAxe.maxDurability)
                        .padding(.horizontal, 32)
                        .padding(.bottom, 16)
                }

                // Bottom buttons
                HStack {
                    Button("PAUSE") {
                        // TODO: Pause functionality
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(8)

                    Spacer()

                    Button("HOME") {
                        endRun()
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }

            // NOPE popup
            if showNopePopup {
                NopePopup(message: nopeMessage)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .onAppear {
            startRun()
        }
    }

    // MARK: - Run Management

    private func startRun() {
        guard gameState.startRun() else {
            currentScreen = .homestead
            return
        }
        runState = gameState.currentRun
        generateNextLog()
    }

    private func endRun() {
        if let result = gameState.endRun() {
            withAnimation(.spring(response: 0.3)) {
                currentScreen = .results(result)
            }
        } else {
            currentScreen = .homestead
        }
    }

    // MARK: - Log Generation

    private func generateNextLog() {
        guard var run = runState else { return }

        let logsChopped = run.logsChopped
        let lastFailed = run.knotState == .failed

        // Generate log based on difficulty curve
        let difficultyFactor = log10(Double(logsChopped + 10)) / 3.0

        // Wood type probabilities
        let softChance = max(0.2, 0.6 - difficultyFactor * 0.4)
        let hardChance = min(0.3, 0.1 + difficultyFactor * 0.2)

        let woodType: WoodType
        let random = Double.random(in: 0...1)
        if random < softChance {
            woodType = .soft
        } else if random < softChance + (1 - softChance - hardChance) {
            woodType = .medium
        } else {
            woodType = .hard
        }

        // Knot probability (not on soft wood, not after failed knot)
        let knotChance = lastFailed ? 0 : min(0.25, 0.05 + difficultyFactor * 0.15)
        let hasKnot = woodType != .soft && Double.random(in: 0...1) < knotChance

        // Calculate chops required
        let chopsRequired = hasKnot ? 3 : run.equippedAxe.chopsRequired(for: woodType)

        let log = Log(woodType: woodType, hasKnot: hasKnot, chopsRequired: chopsRequired)
        run.currentLog = log
        run.knotState = hasKnot ? .awaitingStrike(number: 1) : nil
        runState = run
        gameState.currentRun = run

        // Reset animation state for new log
        choppingState.prepareNewLog()
    }

    // MARK: - Chop Handling

    private func handleChop() -> Bool {
        guard var run = runState, var log = run.currentLog else { return false }

        // Consume durability
        run.currentDurability -= 1

        // Check for axe break
        if run.currentDurability <= 0 && !run.equippedAxe.isDiamond {
            HapticManager.shared.axeBreak()
            runState = run
            gameState.currentRun = run
            endRun()
            return false
        }

        log.currentChops += 1

        if log.hasKnot {
            return handleKnotChop(&run, &log)
        } else {
            return handleNormalChop(&run, &log)
        }
    }

    private func handleNormalChop(_ run: inout RunState, _ log: inout Log) -> Bool {
        if log.currentChops >= log.chopsRequired {
            // Log split successfully
            let wasOneChop = log.currentChops == 1

            if wasOneChop {
                run.consecutiveOneChops += 1
                run.currentMultiplier = min(2.0, 1.0 + Double(run.consecutiveOneChops - 1) * 0.25)
                HapticManager.shared.multiplierUp()
            } else {
                run.consecutiveOneChops = 0
                run.currentMultiplier = 1.0
            }

            // Calculate score
            let basePoints = log.woodType.basePoints
            let points = Int(Double(basePoints) * run.currentMultiplier)
            run.score += points

            // Add wood to harvest
            run.woodHarvested[log.woodType, default: 0] += 1
            run.logsChopped += 1

            // Check for amber (1 in 50 chance)
            if Int.random(in: 1...50) == 1 {
                run.amberFound += 1
                HapticManager.shared.amberFound()
            }

            // Play haptic
            switch log.woodType {
            case .soft: HapticManager.shared.chopSoftWood()
            case .medium: HapticManager.shared.chopMediumWood()
            case .hard: HapticManager.shared.chopHardWood()
            }

            run.currentLog = nil
            runState = run
            gameState.currentRun = run

            // Generate next log after split animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                generateNextLog()
            }

            return true  // Log was split

        } else if log.currentChops >= 3 {
            // Strike! (3+ chops on a log)
            triggerStrike(&run)
            run.currentLog = nil
            runState = run
            gameState.currentRun = run

            if run.strikes >= 3 {
                endRun()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    generateNextLog()
                }
            }
            return false
        } else {
            // Partial chop, continue
            HapticManager.shared.mediumTap()
            run.currentLog = log
            runState = run
            gameState.currentRun = run
            return false  // Not split yet
        }
    }

    private func handleKnotChop(_ run: inout RunState, _ log: inout Log) -> Bool {
        // Simplified knot handling - in full implementation, this would use timing windows
        if log.currentChops >= 3 {
            // Knot broken successfully!
            HapticManager.shared.knotBreakSuccess()

            run.woodHarvested[.hard, default: 0] += 1
            run.logsChopped += 1
            run.score += Int(Double(log.woodType.basePoints + log.woodType.knotBonus) * run.currentMultiplier)

            gameState.statistics.knotsBroken += 1
            gameState.statistics.knotsEncountered += 1

            run.knotState = .success
            run.currentLog = nil
            runState = run
            gameState.currentRun = run

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                generateNextLog()
            }
            return true
        } else {
            // Knot strike in progress
            HapticManager.shared.knotStrike()
            run.currentLog = log
            run.knotState = .awaitingStrike(number: log.currentChops + 1)
            runState = run
            gameState.currentRun = run
            return false
        }
    }

    private func triggerStrike(_ run: inout RunState) {
        run.strikes += 1
        run.consecutiveOneChops = 0
        run.currentMultiplier = 1.0

        HapticManager.shared.strikeEarned()

        // Show NOPE popup
        nopeMessage = nopeMessages.randomElement() ?? "NOPE!"
        withAnimation(.spring(response: 0.3)) {
            showNopePopup = true
            screenShake = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeOut(duration: 0.2)) {
                showNopePopup = false
                screenShake = false
            }
        }
    }
}

// MARK: - Forest HUD

struct ForestHUD: View {
    let runState: RunState?

    var body: some View {
        HStack {
            // Score
            VStack(alignment: .leading, spacing: 2) {
                Text("SCORE")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
                Text("\(runState?.score ?? 0)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }

            Spacer()

            // Streak
            if let multiplier = runState?.currentMultiplier, multiplier > 1.0 {
                Text("×\(String(format: "%.2f", multiplier))")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.amberGold)
            }

            Spacer()

            // Strikes
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(index < (runState?.strikes ?? 0) ? Color.red : Color.white.opacity(0.3))
                        .frame(width: 12, height: 12)
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.2))
        .cornerRadius(12)
    }
}

// MARK: - Durability Bar

struct DurabilityBar: View {
    let current: Int
    let max: Int

    var percentage: Double {
        guard max > 0 else { return 1.0 }
        return Double(current) / Double(max)
    }

    var body: some View {
        VStack(spacing: 4) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.black.opacity(0.3))

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.durabilityColor(for: percentage))
                        .frame(width: geometry.size.width * percentage)
                }
            }
            .frame(height: 8)

            HStack {
                Image(systemName: "hammer.fill")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))

                Text("\(Int(percentage * 100))%")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }
}

// MARK: - NOPE Popup

struct NopePopup: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.system(size: 48, weight: .black, design: .rounded))
            .foregroundColor(.red)
            .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
            .rotationEffect(.degrees(Double.random(in: -5...5)))
    }
}

// MARK: - Shake Effect

struct ShakeEffect: GeometryEffect {
    var shake: Bool
    var animatableData: CGFloat = 0

    func effectValue(size: CGSize) -> ProjectionTransform {
        guard shake else { return ProjectionTransform(.identity) }
        let translation = sin(animatableData * .pi * 4) * 3
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

#Preview {
    ForestView(currentScreen: .constant(.forest))
        .environmentObject(GameStateManager())
        .environmentObject(AudioManager())
}

import SwiftUI

struct ChoppingScene: View {
    @ObservedObject var sceneState: ChoppingSceneState
    let currentLog: Log?
    let equippedAxe: OwnedAxe?
    let knotState: KnotState?
    let onChop: () -> Bool  // Returns true if log was split

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                ForestSceneBackground()

                // Main chopping area
                VStack {
                    Spacer()

                    ZStack {
                        // Chopping block
                        ChoppingBlockView(showImpactMark: sceneState.axeState == .impact)

                        // Log on block
                        if let log = currentLog {
                            LogView(
                                woodType: log.woodType,
                                hasKnot: log.hasKnot,
                                animationState: sceneState.logState
                            )
                            .offset(y: -70)
                        }

                        // Split particles
                        if sceneState.showSplitParticles, let log = currentLog {
                            WoodSplitParticles(woodType: log.woodType)
                                .offset(y: -70)
                        }

                        // Axe
                        if let axe = equippedAxe {
                            AxeView(
                                state: sceneState.axeState,
                                axeTier: axe.tier,
                                axeType: axe.type
                            )
                            .offset(x: 80, y: -150)
                        }
                    }
                    .padding(.bottom, geometry.size.height * 0.15)
                }

                // Knot indicator overlay
                if let knot = knotState {
                    KnotIndicator(knotState: knot)
                        .transition(.scale.combined(with: .opacity))
                }

                // Instruction overlay (first time or idle)
                if sceneState.showInstruction {
                    InstructionOverlay()
                        .transition(.opacity)
                }
            }
            .contentShape(Rectangle())  // Make entire area tappable
            .gesture(
                DragGesture(minimumDistance: 20)
                    .onChanged { value in
                        sceneState.handleSwipeChange(translation: value.translation)
                    }
                    .onEnded { value in
                        sceneState.handleSwipeEnd(translation: value.translation, onChop: onChop)
                    }
            )
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if sceneState.axeState == .idle {
                            sceneState.handleSwipeStart(at: value.location)
                        }
                    }
            )
        }
    }
}

// MARK: - Standalone Chopping Scene (for testing/preview)

struct StandaloneChoppingScene: View {
    @StateObject private var sceneState = ChoppingSceneState()
    @State private var testLog = Log(woodType: .medium, hasKnot: false, chopsRequired: 3)
    @State private var chopCount = 0

    var body: some View {
        ChoppingScene(
            sceneState: sceneState,
            currentLog: testLog,
            equippedAxe: OwnedAxe(
                id: UUID(),
                type: .balanced,
                tier: .mid,
                currentDurability: 100,
                maxDurability: 100,
                cosmeticSkin: nil,
                isEquipped: true
            ),
            knotState: nil,
            onChop: {
                chopCount += 1
                if chopCount >= testLog.chopsRequired {
                    chopCount = 0
                    // Generate new log after animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        testLog = Log(
                            woodType: WoodType.allCases.randomElement() ?? .medium,
                            hasKnot: Bool.random(),
                            chopsRequired: Int.random(in: 2...4)
                        )
                        sceneState.prepareNewLog()
                    }
                    return true  // Log split
                }
                return false  // Partial chop
            }
        )
        .overlay(alignment: .topTrailing) {
            // Debug info
            VStack(alignment: .trailing, spacing: 4) {
                Text("Chops: \(chopCount)/\(testLog.chopsRequired)")
                Text("Wood: \(testLog.woodType.displayName)")
                Text("Knot: \(testLog.hasKnot ? "Yes" : "No")")
            }
            .font(.caption)
            .padding(8)
            .background(Color.black.opacity(0.5))
            .foregroundColor(.white)
            .cornerRadius(8)
            .padding()
        }
    }
}

// MARK: - Previews

#Preview("Chopping Scene") {
    StandaloneChoppingScene()
}

#Preview("Chopping Scene - With Knot") {
    let sceneState = ChoppingSceneState()

    return ChoppingScene(
        sceneState: sceneState,
        currentLog: Log(woodType: .hard, hasKnot: true, chopsRequired: 4),
        equippedAxe: OwnedAxe(
            id: UUID(),
            type: .heavy,
            tier: .premium,
            currentDurability: 50,
            maxDurability: 100,
            cosmeticSkin: nil,
            isEquipped: true
        ),
        knotState: .windowOpen(strike: 1, remaining: 0.4),
        onChop: { false }
    )
}

#Preview("Chopping Scene - Impact") {
    let sceneState = ChoppingSceneState()
    sceneState.axeState = .impact

    return ChoppingScene(
        sceneState: sceneState,
        currentLog: Log(woodType: .soft, hasKnot: false, chopsRequired: 2),
        equippedAxe: OwnedAxe(
            id: UUID(),
            type: .sharp,
            tier: .basic,
            currentDurability: 80,
            maxDurability: 100,
            cosmeticSkin: nil,
            isEquipped: true
        ),
        knotState: nil,
        onChop: { false }
    )
}

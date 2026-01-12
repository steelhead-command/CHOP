import SwiftUI

/// Debug mode for testing chopping mechanics without game over conditions
struct DebugChoppingView: View {
    @StateObject private var sceneState = ChoppingSceneState()
    @State private var testLog: Log
    @State private var chopCount = 0
    @State private var totalChops = 0
    @State private var logsChopped = 0

    // Debug controls
    @State private var selectedWoodType: WoodType = .medium
    @State private var hasKnot = false
    @State private var showDebugPanel = true
    @State private var animationSpeed: Double = 1.0
    @State private var hapticsEnabled = true

    // FPS tracking
    @State private var fps: Int = 60
    @State private var frameCount = 0
    @State private var lastFPSUpdate = Date()

    init() {
        _testLog = State(initialValue: Log(woodType: .medium, hasKnot: false, chopsRequired: 2))
    }

    var body: some View {
        ZStack {
            // Main chopping scene
            ChoppingScene(
                sceneState: sceneState,
                currentLog: testLog,
                equippedAxe: debugAxe,
                knotState: hasKnot ? .awaitingStrike(number: min(chopCount + 1, 3)) : nil,
                onChop: handleChop
            )

            // Debug overlay
            VStack {
                // Top bar with FPS and stats
                HStack {
                    // FPS counter
                    Text("FPS: \(fps)")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(fps >= 55 ? .green : fps >= 30 ? .yellow : .red)
                        .padding(6)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(6)

                    Spacer()

                    // Stats
                    HStack(spacing: 12) {
                        Text("Chops: \(totalChops)")
                        Text("Logs: \(logsChopped)")
                    }
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(6)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(6)

                    Spacer()

                    // Toggle debug panel
                    Button {
                        withAnimation {
                            showDebugPanel.toggle()
                        }
                    } label: {
                        Image(systemName: showDebugPanel ? "gearshape.fill" : "gearshape")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(6)
                    }
                }
                .padding()

                Spacer()

                // Debug control panel
                if showDebugPanel {
                    DebugControlPanel(
                        selectedWoodType: $selectedWoodType,
                        hasKnot: $hasKnot,
                        animationSpeed: $animationSpeed,
                        hapticsEnabled: $hapticsEnabled,
                        onReset: resetScene,
                        onGenerateLog: generateNewLog
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .onAppear {
            sceneState.animationSpeed = animationSpeed
            sceneState.hapticsEnabled = hapticsEnabled
            startFPSTracking()
        }
        .onChange(of: animationSpeed) { _, newValue in
            sceneState.animationSpeed = newValue
        }
        .onChange(of: hapticsEnabled) { _, newValue in
            sceneState.hapticsEnabled = newValue
        }
    }

    // MARK: - Debug Axe

    private var debugAxe: OwnedAxe {
        OwnedAxe(
            id: UUID(),
            type: .balanced,
            tier: .diamond,  // Diamond never breaks
            currentDurability: Int.max,
            maxDurability: Int.max,
            cosmeticSkin: nil,
            isEquipped: true
        )
    }

    // MARK: - Chop Handling

    private func handleChop() -> Bool {
        chopCount += 1
        totalChops += 1

        if chopCount >= testLog.chopsRequired {
            // Log split
            chopCount = 0
            logsChopped += 1

            // Generate new log after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + sceneState.splitDuration + 0.2) {
                generateNewLog()
            }
            return true
        }
        return false
    }

    // MARK: - Log Generation

    private func generateNewLog() {
        let chopsRequired = hasKnot ? 3 : (selectedWoodType == .soft ? 1 : selectedWoodType == .medium ? 2 : 3)
        testLog = Log(woodType: selectedWoodType, hasKnot: hasKnot, chopsRequired: chopsRequired)
        sceneState.prepareNewLog()
    }

    private func resetScene() {
        chopCount = 0
        totalChops = 0
        logsChopped = 0
        sceneState.resetForDebug()
        generateNewLog()
    }

    // MARK: - FPS Tracking

    private func startFPSTracking() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            fps = frameCount
            frameCount = 0
        }

        // Frame counter using display link simulation
        Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { _ in
            frameCount += 1
        }
    }
}

// MARK: - Debug Control Panel

struct DebugControlPanel: View {
    @Binding var selectedWoodType: WoodType
    @Binding var hasKnot: Bool
    @Binding var animationSpeed: Double
    @Binding var hapticsEnabled: Bool
    let onReset: () -> Void
    let onGenerateLog: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            // Wood type selector
            VStack(alignment: .leading, spacing: 8) {
                Text("WOOD TYPE")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))

                HStack(spacing: 8) {
                    ForEach(WoodType.allCases, id: \.self) { woodType in
                        Button {
                            selectedWoodType = woodType
                        } label: {
                            Text(woodType.displayName)
                                .font(.caption)
                                .foregroundColor(selectedWoodType == woodType ? .white : .white.opacity(0.7))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedWoodType == woodType ? woodType.color : Color.white.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                }
            }

            // Knot toggle
            Toggle(isOn: $hasKnot) {
                Text("Has Knot")
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .tint(.amberGold)

            // Animation speed slider
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Animation Speed")
                        .font(.caption)
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(String(format: "%.1f", animationSpeed))x")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }

                Slider(value: $animationSpeed, in: 0.5...2.0, step: 0.1)
                    .tint(.chopOrange)
            }

            // Haptics toggle
            Toggle(isOn: $hapticsEnabled) {
                Text("Haptics")
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .tint(.chopOrange)

            // Action buttons
            HStack(spacing: 12) {
                Button {
                    onGenerateLog()
                } label: {
                    Text("New Log")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.chopOrange)
                        .cornerRadius(8)
                }

                Button {
                    onReset()
                } label: {
                    Text("Reset")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.85))
        .cornerRadius(16)
        .padding()
    }
}

// MARK: - Previews

#Preview("Debug Chopping View") {
    DebugChoppingView()
}

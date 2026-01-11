import SwiftUI

struct HomesteadView: View {
    @EnvironmentObject var gameState: GameStateManager
    @Binding var currentScreen: AppScreen

    @State private var showAxeSelection = false
    @State private var showFurnaceDetail = false

    var body: some View {
        ZStack {
            // Background
            Color.chopBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar with currencies
                CurrencyBar()
                    .padding(.horizontal)
                    .padding(.top, 8)

                Spacer()

                // Main content
                VStack(spacing: 24) {
                    // Forest button (tap to chop)
                    ForestButton {
                        if gameState.equippedAxe != nil {
                            withAnimation(.spring(response: 0.3)) {
                                currentScreen = .forest
                            }
                        } else {
                            showAxeSelection = true
                        }
                    }

                    // Middle section - Furnace and Wood Pile
                    HStack(spacing: 32) {
                        // Wood pile
                        WoodPileView()

                        // Furnace
                        FurnacePreview {
                            showFurnaceDetail = true
                        }
                    }

                    // Bottom section - Axe rack, Smoker, Orchard
                    HStack(spacing: 20) {
                        AxeRackButton {
                            showAxeSelection = true
                        }

                        SmokerPreview()

                        OrchardPreview()
                    }
                }
                .padding(.horizontal)

                Spacer()

                // Navigation hints
                HStack {
                    Text("◀ STORE")
                        .font(.caption)
                        .foregroundColor(.chopSecondaryText)

                    Spacer()

                    Text("GATHERING ▶")
                        .font(.caption)
                        .foregroundColor(.chopSecondaryText)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 8)

                // High score
                HighScoreBar()
                    .padding(.horizontal)
                    .padding(.bottom, 16)
            }
        }
        .sheet(isPresented: $showAxeSelection) {
            AxeSelectionView(isPresented: $showAxeSelection)
        }
        .sheet(isPresented: $showFurnaceDetail) {
            FurnaceDetailView(isPresented: $showFurnaceDetail)
        }
    }
}

// MARK: - Currency Badge

struct CurrencyBadge: View {
    let icon: String
    let amount: Int

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(.amberGold)
                .font(.caption)
            Text("\(amount)")
                .font(.headline)
                .foregroundColor(.chopText)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.5))
        .cornerRadius(16)
    }
}

// MARK: - Currency Bar

struct CurrencyBar: View {
    @EnvironmentObject var gameState: GameStateManager

    var body: some View {
        HStack {
            CurrencyBadge(icon: "circle.fill", amount: gameState.coins)
            Spacer()
            CurrencyBadge(icon: "diamond.fill", amount: gameState.amber)
        }
    }
}

// MARK: - Forest Button

struct ForestButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: "tree.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.forestGreen)

                Text("TAP TO CHOP")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.chopText)
            }
            .frame(width: 120, height: 100)
            .background(Color.white.opacity(0.7))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Wood Pile View

struct WoodPileView: View {
    @EnvironmentObject var gameState: GameStateManager

    var body: some View {
        VStack(spacing: 4) {
            // Wood pile icon
            Image(systemName: "square.stack.3d.up.fill")
                .font(.system(size: 32))
                .foregroundColor(Color(hex: "8B6914"))

            Text("\(gameState.inventory.totalWood)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.chopText)

            Text("logs")
                .font(.caption2)
                .foregroundColor(.chopSecondaryText)
        }
        .frame(width: 80, height: 80)
        .background(Color.white.opacity(0.5))
        .cornerRadius(12)
    }
}

// MARK: - Furnace Preview

struct FurnacePreview: View {
    @EnvironmentObject var gameState: GameStateManager
    let action: () -> Void

    var body: some View {
        let temperatureColor = gameState.furnaceState.temperatureState.uiColor

        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    if gameState.furnaceState.isBurning {
                        Circle()
                            .fill(temperatureColor.opacity(0.3))
                            .frame(width: 50, height: 50)
                    }

                    Image(systemName: "flame.fill")
                        .font(.system(size: 32))
                        .foregroundColor(temperatureColor)
                }

                Text("\(gameState.furnaceState.currentTemperature)°")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.chopText)
            }
            .frame(width: 80, height: 80)
            .background(Color.white.opacity(0.5))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Axe Rack Button

struct AxeRackButton: View {
    @EnvironmentObject var gameState: GameStateManager
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: "hammer.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.chopText)

                if let axe = gameState.equippedAxe {
                    Text(axe.displayName)
                        .font(.caption2)
                        .foregroundColor(.chopSecondaryText)
                        .lineLimit(1)
                } else {
                    Text("Select Axe")
                        .font(.caption2)
                        .foregroundColor(.chopWarning)
                }
            }
            .frame(width: 70, height: 60)
            .background(Color.white.opacity(0.5))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Smoker Preview

struct SmokerPreview: View {
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "smoke.fill")
                .font(.system(size: 24))
                .foregroundColor(.gray)

            Text("Smoker")
                .font(.caption2)
                .foregroundColor(.chopSecondaryText)
        }
        .frame(width: 70, height: 60)
        .background(Color.white.opacity(0.5))
        .cornerRadius(8)
    }
}

// MARK: - Orchard Preview

struct OrchardPreview: View {
    @EnvironmentObject var gameState: GameStateManager

    var readyCount: Int {
        gameState.gameSave.plants.filter { $0.harvestReady }.count
    }

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 24))
                .foregroundColor(.forestGreen)

            if readyCount > 0 {
                Text("ready!")
                    .font(.caption2)
                    .foregroundColor(.chopSuccess)
            } else {
                Text("\(gameState.gameSave.plants.count) plants")
                    .font(.caption2)
                    .foregroundColor(.chopSecondaryText)
            }
        }
        .frame(width: 70, height: 60)
        .background(Color.white.opacity(0.5))
        .cornerRadius(8)
    }
}

// MARK: - High Score Bar

struct HighScoreBar: View {
    @EnvironmentObject var gameState: GameStateManager

    var body: some View {
        HStack {
            Spacer()
            Text("HIGH SCORE: \(gameState.playerState.highScore) logs")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.chopSecondaryText)
            Spacer()
        }
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.3))
        .cornerRadius(8)
    }
}

#Preview {
    HomesteadView(currentScreen: .constant(.homestead))
        .environmentObject(GameStateManager())
}

import SwiftUI

struct ResultsView: View {
    let result: RunResult
    @Binding var currentScreen: AppScreen
    @EnvironmentObject var gameState: GameStateManager

    var body: some View {
        ZStack {
            Color.chopBackground
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Title
                VStack(spacing: 8) {
                    if result.isNewHighScore {
                        Text("NEW HIGH SCORE!")
                            .font(.headline)
                            .foregroundColor(.amberGold)
                    }

                    Text(result.gameOverReason.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.chopText)

                    Text(scoreMessage)
                        .font(.title3)
                        .foregroundColor(.chopSecondaryText)
                }

                // Score display
                if result.isNewHighScore {
                    VStack(spacing: 4) {
                        Text("\(result.logsChopped)")
                            .font(.system(size: 72, weight: .bold, design: .rounded))
                            .foregroundColor(.chopOrange)

                        Text("logs")
                            .font(.title3)
                            .foregroundColor(.chopSecondaryText)

                        Text("Previous: \(result.previousHighScore)")
                            .font(.caption)
                            .foregroundColor(.chopSecondaryText)
                    }
                    .padding()
                    .background(Color.amberGold.opacity(0.1))
                    .cornerRadius(16)
                } else {
                    VStack(spacing: 4) {
                        Text("\(result.logsChopped)")
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .foregroundColor(.chopText)

                        Text("logs")
                            .font(.title3)
                            .foregroundColor(.chopSecondaryText)
                    }
                }

                // Harvest breakdown
                VStack(alignment: .leading, spacing: 12) {
                    Text("HARVESTED")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.chopSecondaryText)

                    HStack(spacing: 16) {
                        HarvestItem(
                            icon: "square.stack.fill",
                            color: Color(hex: "A67C52"),
                            count: result.softWood,
                            value: result.softWood * WoodType.soft.sellPrice
                        )

                        HarvestItem(
                            icon: "square.stack.fill",
                            color: Color(hex: "8B6914"),
                            count: result.mediumWood,
                            value: result.mediumWood * WoodType.medium.sellPrice
                        )

                        HarvestItem(
                            icon: "square.stack.fill",
                            color: Color(hex: "5C4612"),
                            count: result.hardWood,
                            value: result.hardWood * WoodType.hard.sellPrice
                        )

                        if result.amberFound > 0 {
                            HarvestItem(
                                icon: "diamond.fill",
                                color: .amberGold,
                                count: result.amberFound,
                                value: nil
                            )
                        }
                    }

                    HStack {
                        Text("TOTAL")
                            .font(.caption)
                            .foregroundColor(.chopSecondaryText)
                        Spacer()
                        Text("+\(result.totalWoodValue) coins")
                            .font(.headline)
                            .foregroundColor(.chopSuccess)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.5))
                .cornerRadius(12)
                .padding(.horizontal)

                // Axe status
                if result.axeDurabilityRemaining > 0 {
                    HStack {
                        Image(systemName: "hammer.fill")
                            .foregroundColor(.chopSecondaryText)
                        Text("\(result.axeTier.tierName(for: result.axeType))")
                            .foregroundColor(.chopText)
                        Spacer()
                        Text("\(result.axeDurabilityRemaining) durability")
                            .foregroundColor(.chopSecondaryText)
                    }
                    .font(.caption)
                    .padding()
                    .background(Color.white.opacity(0.5))
                    .cornerRadius(12)
                    .padding(.horizontal)
                } else {
                    HStack {
                        Image(systemName: "hammer.fill")
                            .foregroundColor(.chopError)
                        Text("\(result.axeTier.tierName(for: result.axeType))")
                            .foregroundColor(.chopError)
                        Spacer()
                        Text("BROKEN")
                            .fontWeight(.semibold)
                            .foregroundColor(.chopError)
                    }
                    .font(.caption)
                    .padding()
                    .background(Color.chopError.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                Spacer()

                // Action buttons
                HStack(spacing: 16) {
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            currentScreen = .forest
                        }
                    } label: {
                        Text("CHOP AGAIN")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.chopOrange)
                            .cornerRadius(12)
                    }

                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            currentScreen = .homestead
                        }
                    } label: {
                        Text("HOME")
                            .font(.headline)
                            .foregroundColor(.chopText)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
        }
    }

    private var scoreMessage: String {
        switch result.logsChopped {
        case 0..<20: return "Just warming up."
        case 20..<50: return "A good start."
        case 50..<100: return "Strong work."
        case 100..<150: return "Impressive!"
        case 150..<200: return "Masterful."
        default: return "Legendary!"
        }
    }
}

// MARK: - Harvest Item

struct HarvestItem: View {
    let icon: String
    let color: Color
    let count: Int
    let value: Int?

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)

            Text("×\(count)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.chopText)

            if let value = value {
                Text("+\(value)")
                    .font(.caption2)
                    .foregroundColor(.chopSuccess)
            }
        }
        .frame(width: 60)
    }
}

#Preview {
    ResultsView(
        result: RunResult(
            score: 1247,
            logsChopped: 78,
            woodHarvested: [.soft: 47, .medium: 22, .hard: 9],
            amberFound: 2,
            gameOverReason: .maxStrikes,
            isNewHighScore: true,
            previousHighScore: 64,
            duration: 180,
            axeDurabilityRemaining: 12,
            axeType: .sharp,
            axeTier: .mid
        ),
        currentScreen: .constant(.results(RunResult(
            score: 0, logsChopped: 0, woodHarvested: [:], amberFound: 0,
            gameOverReason: .maxStrikes, isNewHighScore: false, previousHighScore: 0,
            duration: 0, axeDurabilityRemaining: 0, axeType: .balanced, axeTier: .basic
        )))
    )
    .environmentObject(GameStateManager())
}

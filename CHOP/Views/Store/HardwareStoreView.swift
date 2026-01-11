import SwiftUI

struct HardwareStoreView: View {
    @EnvironmentObject var gameState: GameStateManager
    @Binding var currentScreen: AppScreen

    @State private var selectedCategory: StoreCategory = .axes

    enum StoreCategory: String, CaseIterable {
        case axes = "Axes"
        case furnace = "Furnace"
        case gathering = "Gathering"
        case cosmetics = "Cosmetics"
    }

    var body: some View {
        ZStack {
            Color.chopBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            currentScreen = .homestead
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.chopText)
                    }

                    Spacer()

                    Text("HARDWARE STORE")
                        .font(.headline)
                        .foregroundColor(.chopText)

                    Spacer()

                    // Balance spacer
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.clear)
                }
                .padding()

                // Currency display
                HStack(spacing: 16) {
                    CurrencyBadge(icon: "circle.fill", amount: gameState.coins)
                    CurrencyBadge(icon: "diamond.fill", amount: gameState.amber)
                }
                .padding(.horizontal)

                // Category tabs
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(StoreCategory.allCases, id: \.self) { category in
                            CategoryTab(
                                title: category.rawValue,
                                isSelected: selectedCategory == category
                            ) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedCategory = category
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 12)

                // Content
                ScrollView {
                    switch selectedCategory {
                    case .axes:
                        AxeStoreSection()
                    case .furnace:
                        FurnaceStoreSection()
                    case .gathering:
                        GatheringStoreSection()
                    case .cosmetics:
                        CosmeticsStoreSection()
                    }
                }
            }
        }
    }
}

// MARK: - Category Tab

struct CategoryTab: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .chopText)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.chopOrange : Color.white.opacity(0.5))
                .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Store Sections

struct AxeStoreSection: View {
    @EnvironmentObject var gameState: GameStateManager

    var body: some View {
        LazyVStack(spacing: 16) {
            ForEach(AxeType.allCases, id: \.self) { axeType in
                ForEach(AxeTier.allCases.filter { $0 != .diamond }, id: \.self) { tier in
                    AxeStoreItem(axeType: axeType, tier: tier)
                }
            }

            // Diamond Axe (IAP)
            DiamondAxeItem()
        }
        .padding()
    }
}

struct AxeStoreItem: View {
    @EnvironmentObject var gameState: GameStateManager
    let axeType: AxeType
    let tier: AxeTier

    var isOwned: Bool {
        gameState.gameSave.ownedAxes.contains { $0.type == axeType && $0.tier == tier }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(tier.tierName(for: axeType))
                    .font(.headline)
                    .foregroundColor(.chopText)

                Text(axeType.description)
                    .font(.caption)
                    .foregroundColor(.chopSecondaryText)
            }

            Spacer()

            if isOwned {
                Text("OWNED")
                    .font(.caption)
                    .foregroundColor(.chopSuccess)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.chopSuccess.opacity(0.1))
                    .cornerRadius(8)
            } else {
                Button {
                    purchaseAxe()
                } label: {
                    Text("\(tier.price) coins")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.chopOrange)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .disabled(gameState.coins < tier.price)
            }
        }
        .padding()
        .background(Color.white.opacity(0.5))
        .cornerRadius(12)
    }

    private func purchaseAxe() {
        guard gameState.spendCoins(tier.price) else { return }

        let newAxe = OwnedAxe(
            id: UUID(),
            type: axeType,
            tier: tier,
            currentDurability: tier.baseDurability(for: axeType),
            maxDurability: tier.baseDurability(for: axeType),
            cosmeticSkin: nil,
            isEquipped: false
        )
        gameState.gameSave.ownedAxes.append(newAxe)
        gameState.saveGame()
    }
}

struct DiamondAxeItem: View {
    @EnvironmentObject var gameState: GameStateManager

    var isOwned: Bool {
        gameState.gameSave.ownedAxes.contains { $0.isDiamond }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Diamond Axe")
                        .font(.headline)
                        .foregroundColor(.chopText)

                    Image(systemName: "sparkles")
                        .foregroundColor(.amberGold)
                }

                Text("Never breaks. Ever.")
                    .font(.caption)
                    .foregroundColor(.chopSecondaryText)
            }

            Spacer()

            if isOwned {
                Text("OWNED")
                    .font(.caption)
                    .foregroundColor(.chopSuccess)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.chopSuccess.opacity(0.1))
                    .cornerRadius(8)
            } else {
                Button {
                    // Trigger IAP
                } label: {
                    Text("$2.99")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.amberGold)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.amberGold.opacity(0.2), Color.white.opacity(0.5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.amberGold, lineWidth: 1)
        )
    }
}

struct FurnaceStoreSection: View {
    var body: some View {
        LazyVStack(spacing: 16) {
            ForEach(FurnaceTier.allCases, id: \.self) { tier in
                FurnaceUpgradeItem(tier: tier)
            }
        }
        .padding()
    }
}

struct FurnaceUpgradeItem: View {
    @EnvironmentObject var gameState: GameStateManager
    let tier: FurnaceTier

    var isUnlocked: Bool {
        gameState.furnaceState.tier.rawValue >= tier.rawValue
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(tier.displayName)
                    .font(.headline)
                    .foregroundColor(.chopText)

                Text("\(tier.maxSlots) slots • Unlocks at \(tier.logsRequiredToUnlock) logs")
                    .font(.caption)
                    .foregroundColor(.chopSecondaryText)
            }

            Spacer()

            if isUnlocked {
                Text("UNLOCKED")
                    .font(.caption)
                    .foregroundColor(.chopSuccess)
            } else {
                Text("\(tier.upgradePrice) coins")
                    .font(.caption)
                    .foregroundColor(.chopSecondaryText)
            }
        }
        .padding()
        .background(Color.white.opacity(0.5))
        .cornerRadius(12)
    }
}

struct GatheringStoreSection: View {
    var body: some View {
        LazyVStack(spacing: 16) {
            GatheringItem(name: "Fishing Hole Access", price: 0, description: "Free with game")
            GatheringItem(name: "Berry Sapling", price: 500, description: "Plant in orchard")
            GatheringItem(name: "Nut Tree Sapling", price: 500, description: "Plant in orchard")
            GatheringItem(name: "Herb Seedling", price: 500, description: "Plant in orchard")
        }
        .padding()
    }
}

struct GatheringItem: View {
    let name: String
    let price: Int
    let description: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                    .foregroundColor(.chopText)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.chopSecondaryText)
            }

            Spacer()

            if price == 0 {
                Text("FREE")
                    .font(.caption)
                    .foregroundColor(.chopSuccess)
            } else {
                Button {
                    // Purchase
                } label: {
                    Text("\(price) coins")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.chopOrange)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(Color.white.opacity(0.5))
        .cornerRadius(12)
    }
}

struct CosmeticsStoreSection: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Cosmetics coming soon!")
                .font(.headline)
                .foregroundColor(.chopSecondaryText)

            Text("Axe skins, trail effects, and more...")
                .font(.caption)
                .foregroundColor(.chopSecondaryText)
        }
        .padding()
    }
}

#Preview {
    HardwareStoreView(currentScreen: .constant(.store))
        .environmentObject(GameStateManager())
}

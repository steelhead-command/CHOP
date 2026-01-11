import SwiftUI

struct GatheringHubView: View {
    @EnvironmentObject var gameState: GameStateManager
    @Binding var currentScreen: AppScreen

    @State private var selectedActivity: GatheringActivity?

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(hex: "87CEEB"),  // Sky
                    Color(hex: "90EE90")   // Light green
                ],
                startPoint: .top,
                endPoint: .bottom
            )
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

                    Text("GATHERING")
                        .font(.headline)
                        .foregroundColor(.chopText)

                    Spacer()

                    // Balance spacer
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.clear)
                }
                .padding()
                .background(Color.white.opacity(0.3))

                ScrollView {
                    VStack(spacing: 24) {
                        // Fishing section
                        GatheringActivityCard(
                            activity: .fishing,
                            title: "Fishing Hole",
                            description: "Cast your line and catch fish for the furnace",
                            icon: "water.waves",
                            color: .blue,
                            isAvailable: true
                        ) {
                            selectedActivity = .fishing
                        }

                        // Orchard section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("ORCHARD")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.chopSecondaryText)
                                .padding(.horizontal)

                            // Berry bushes
                            GatheringActivityCard(
                                activity: .berries,
                                title: "Berry Bushes",
                                description: "Swipe to collect ripe berries",
                                icon: "leaf.circle.fill",
                                color: .pink,
                                isAvailable: hasPlants(of: .berryBush)
                            ) {
                                selectedActivity = .berries
                            }

                            // Nut trees
                            GatheringActivityCard(
                                activity: .nuts,
                                title: "Nut Trees",
                                description: "Shake trees to harvest nuts",
                                icon: "tree.circle.fill",
                                color: Color(hex: "8B4513"),
                                isAvailable: hasPlants(of: .nutTree)
                            ) {
                                selectedActivity = .nuts
                            }

                            // Herb garden
                            GatheringActivityCard(
                                activity: .herbs,
                                title: "Herb Garden",
                                description: "Gentle swipes to gather herbs",
                                icon: "leaf.fill",
                                color: .forestGreen,
                                isAvailable: hasPlants(of: .herbGarden)
                            ) {
                                selectedActivity = .herbs
                            }
                        }

                        // Plant status
                        if !gameState.gameSave.plants.isEmpty {
                            PlantStatusSection()
                        }
                    }
                    .padding()
                }
            }
        }
        .sheet(item: $selectedActivity) { activity in
            GatheringActivityView(activity: activity, isPresented: Binding(
                get: { selectedActivity != nil },
                set: { if !$0 { selectedActivity = nil } }
            ))
        }
    }

    private func hasPlants(of type: PlantType) -> Bool {
        gameState.gameSave.plants.contains { $0.type == type }
    }
}

// MARK: - Gathering Activity Card

struct GatheringActivityCard: View {
    let activity: GatheringActivity
    let title: String
    let description: String
    let icon: String
    let color: Color
    let isAvailable: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(isAvailable ? color : .gray)
                    .frame(width: 50)

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(isAvailable ? .chopText : .chopSecondaryText)

                    Text(description)
                        .font(.caption)
                        .foregroundColor(.chopSecondaryText)
                }

                Spacer()

                // Arrow
                Image(systemName: "chevron.right")
                    .foregroundColor(.chopSecondaryText)
            }
            .padding()
            .background(Color.white.opacity(isAvailable ? 0.7 : 0.3))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .disabled(!isAvailable)
    }
}

// MARK: - Plant Status Section

struct PlantStatusSection: View {
    @EnvironmentObject var gameState: GameStateManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PLANT STATUS")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.chopSecondaryText)

            ForEach(gameState.gameSave.plants) { plant in
                PlantStatusRow(plant: plant)
            }
        }
    }
}

struct PlantStatusRow: View {
    let plant: Plant

    var body: some View {
        HStack {
            Image(systemName: plant.type.icon)
                .foregroundColor(plant.harvestReady ? .chopSuccess : .chopSecondaryText)

            Text(plant.type.displayName)
                .font(.subheadline)
                .foregroundColor(.chopText)

            Spacer()

            if plant.harvestReady {
                Text("Ready!")
                    .font(.caption)
                    .foregroundColor(.chopSuccess)
            } else if let remaining = plant.timeUntilHarvest {
                Text(remaining.formatted)
                    .font(.caption)
                    .foregroundColor(.chopSecondaryText)
            } else {
                Text("Growing...")
                    .font(.caption)
                    .foregroundColor(.chopSecondaryText)
            }
        }
        .padding()
        .background(Color.white.opacity(0.5))
        .cornerRadius(8)
    }
}

// MARK: - Gathering Activity View

struct GatheringActivityView: View {
    let activity: GatheringActivity
    @Binding var isPresented: Bool
    @EnvironmentObject var gameState: GameStateManager

    var body: some View {
        NavigationView {
            ZStack {
                Color.chopBackground
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    switch activity {
                    case .fishing:
                        FishingMiniGame()
                    case .berries:
                        BerryPickingMiniGame()
                    case .nuts:
                        NutShakingMiniGame()
                    case .herbs:
                        HerbGatheringMiniGame()
                    }
                }
                .padding()
            }
            .navigationTitle(activity.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

// MARK: - Mini Games (Placeholders)

struct FishingMiniGame: View {
    @State private var isCasting = false
    @State private var hasFish = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Water
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 200, height: 200)

                if hasFish {
                    Image(systemName: "fish.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.blue)
                }

                Image(systemName: "water.waves")
                    .font(.system(size: 64))
                    .foregroundColor(.blue.opacity(0.5))
            }

            Text(isCasting ? "Wait for a bite..." : "Tap to cast")
                .font(.headline)
                .foregroundColor(.chopText)

            Spacer()

            Button {
                if !isCasting {
                    cast()
                }
            } label: {
                Text(isCasting ? "Waiting..." : "CAST")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isCasting ? Color.gray : Color.blue)
                    .cornerRadius(12)
            }
            .disabled(isCasting)
        }
    }

    private func cast() {
        isCasting = true
        // Simulate fishing
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 2...5)) {
            hasFish = true
            isCasting = false
        }
    }
}

struct BerryPickingMiniGame: View {
    @State private var berriesCollected = 0

    var body: some View {
        VStack(spacing: 24) {
            Text("Berries: \(berriesCollected)")
                .font(.title)
                .foregroundColor(.chopText)

            Text("Swipe across berries to collect")
                .font(.caption)
                .foregroundColor(.chopSecondaryText)

            // Berry grid placeholder
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                ForEach(0..<12, id: \.self) { _ in
                    Circle()
                        .fill(Color.pink)
                        .frame(width: 40, height: 40)
                        .onTapGesture {
                            berriesCollected += 1
                        }
                }
            }
            .padding()
        }
    }
}

struct NutShakingMiniGame: View {
    @State private var nutsCollected = 0
    @State private var isShaking = false

    var body: some View {
        VStack(spacing: 24) {
            Text("Nuts: \(nutsCollected)")
                .font(.title)
                .foregroundColor(.chopText)

            // Tree
            Image(systemName: "tree.fill")
                .font(.system(size: 100))
                .foregroundColor(.forestGreen)
                .rotationEffect(.degrees(isShaking ? -5 : 5))
                .animation(isShaking ? .easeInOut(duration: 0.1).repeatForever() : .default, value: isShaking)

            Text("Tap tree to shake")
                .font(.caption)
                .foregroundColor(.chopSecondaryText)

            Button {
                shake()
            } label: {
                Text("SHAKE")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "8B4513"))
                    .cornerRadius(12)
            }
        }
    }

    private func shake() {
        isShaking = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isShaking = false
            nutsCollected += Int.random(in: 1...3)
        }
    }
}

struct HerbGatheringMiniGame: View {
    @State private var herbsCollected = 0

    var body: some View {
        VStack(spacing: 24) {
            Text("Herbs: \(herbsCollected)")
                .font(.title)
                .foregroundColor(.chopText)

            Text("Gently swipe herbs to gather")
                .font(.caption)
                .foregroundColor(.chopSecondaryText)

            // Herb grid placeholder
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                ForEach(0..<9, id: \.self) { _ in
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.forestGreen)
                        .onTapGesture {
                            herbsCollected += 1
                        }
                }
            }
            .padding()
        }
    }
}

#Preview {
    GatheringHubView(currentScreen: .constant(.gathering))
        .environmentObject(GameStateManager())
}

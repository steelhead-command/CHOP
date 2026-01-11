import SwiftUI

struct FurnaceDetailView: View {
    @EnvironmentObject var gameState: GameStateManager
    @Binding var isPresented: Bool

    @State private var selectedRecipe: Recipe?
    @State private var selectedSlot: Int?

    var body: some View {
        NavigationView {
            ZStack {
                Color.chopBackground
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    // Furnace visual
                    FurnaceVisual()
                        .padding(.top)

                    // Temperature display
                    TemperatureDisplay()

                    // Processing slots
                    ProcessingSlotsView(selectedSlot: $selectedSlot)

                    // Recipe selection
                    if selectedSlot != nil {
                        RecipeSelectionView(selectedRecipe: $selectedRecipe, onSelect: startProcessing)
                    }

                    // Wood fuel section
                    WoodFuelSection()

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Furnace")
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

    private func startProcessing(_ recipe: Recipe) {
        guard let slot = selectedSlot else { return }
        // Start processing in the selected slot
        gameState.startProcessing(recipe: recipe, inSlot: slot)
        selectedSlot = nil
        selectedRecipe = nil
    }
}

// MARK: - Furnace Visual

struct FurnaceVisual: View {
    @EnvironmentObject var gameState: GameStateManager

    var body: some View {
        let temperatureColor = gameState.furnaceState.temperatureState.uiColor

        ZStack {
            if gameState.furnaceState.isBurning {
                Circle()
                    .fill(temperatureColor.opacity(0.3))
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
            }

            Image(systemName: "flame.fill")
                .font(.system(size: 64))
                .foregroundColor(temperatureColor)
        }
    }
}

// MARK: - Temperature Display

struct TemperatureDisplay: View {
    @EnvironmentObject var gameState: GameStateManager

    var body: some View {
        let temperatureColor = gameState.furnaceState.temperatureState.uiColor

        VStack(spacing: 8) {
            Text("\(gameState.furnaceState.currentTemperature)°")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(temperatureColor)

            Text(gameState.furnaceState.temperatureState.description)
                .font(.caption)
                .foregroundColor(.chopSecondaryText)

            if gameState.furnaceState.isBurning {
                Text("Burning: \(gameState.furnaceState.currentFuel?.displayName ?? "Unknown")")
                    .font(.caption)
                    .foregroundColor(.chopText)
            }
        }
    }
}

// MARK: - Processing Slots

struct ProcessingSlotsView: View {
    @EnvironmentObject var gameState: GameStateManager
    @Binding var selectedSlot: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("PROCESSING")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.chopSecondaryText)

            HStack(spacing: 12) {
                ForEach(0..<gameState.furnaceState.tier.maxSlots, id: \.self) { index in
                    ProcessingSlotView(
                        slot: index < gameState.furnaceState.processingSlots.count ? gameState.furnaceState.processingSlots[index] : nil,
                        isSelected: selectedSlot == index
                    ) {
                        let slot = index < gameState.furnaceState.processingSlots.count ? gameState.furnaceState.processingSlots[index] : nil
                        if slot?.isEmpty ?? true {
                            selectedSlot = selectedSlot == index ? nil : index
                        }
                    }
                }
            }
        }
    }
}

struct ProcessingSlotView: View {
    let slot: FurnaceSlot?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                if let slot = slot, let recipe = slot.recipe {
                    // Active slot
                    Image(systemName: recipe.icon)
                        .font(.title2)
                        .foregroundColor(.chopOrange)

                    Text(recipe.displayName)
                        .font(.caption2)
                        .foregroundColor(.chopText)
                        .lineLimit(1)

                    // Progress
                    if let progress = slot.progress {
                        ProgressView(value: progress)
                            .tint(.chopOrange)
                    }
                } else {
                    // Empty slot
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(.chopSecondaryText)

                    Text("Empty")
                        .font(.caption2)
                        .foregroundColor(.chopSecondaryText)
                }
            }
            .frame(width: 80, height: 80)
            .background(isSelected ? Color.chopOrange.opacity(0.2) : Color.white.opacity(0.5))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.chopOrange : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Recipe Selection

struct RecipeSelectionView: View {
    @EnvironmentObject var gameState: GameStateManager
    @Binding var selectedRecipe: Recipe?
    let onSelect: (Recipe) -> Void

    var availableRecipes: [Recipe] {
        Recipe.all.filter { recipe in
            gameState.furnaceState.currentTemperature >= recipe.minimumTemperature
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("SELECT RECIPE")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.chopSecondaryText)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(availableRecipes) { recipe in
                        RecipeCard(recipe: recipe, isSelected: selectedRecipe?.id == recipe.id) {
                            selectedRecipe = recipe
                            onSelect(recipe)
                        }
                    }
                }
            }
        }
    }
}

struct RecipeCard: View {
    let recipe: Recipe
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: recipe.icon)
                    .font(.title2)
                    .foregroundColor(.chopOrange)

                Text(recipe.displayName)
                    .font(.caption)
                    .foregroundColor(.chopText)
                    .lineLimit(1)

                Text("\(recipe.sellPrice) coins")
                    .font(.caption2)
                    .foregroundColor(.chopSuccess)
            }
            .frame(width: 80, height: 80)
            .background(isSelected ? Color.chopOrange.opacity(0.2) : Color.white.opacity(0.5))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Wood Fuel Section

struct WoodFuelSection: View {
    @EnvironmentObject var gameState: GameStateManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ADD FUEL")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.chopSecondaryText)

            HStack(spacing: 12) {
                ForEach(WoodType.allCases, id: \.self) { woodType in
                    WoodFuelButton(woodType: woodType) {
                        gameState.addFuel(woodType)
                    }
                }
            }
        }
    }
}

struct WoodFuelButton: View {
    @EnvironmentObject var gameState: GameStateManager
    let woodType: WoodType
    let action: () -> Void

    var count: Int {
        gameState.inventory.wood[woodType] ?? 0
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: "square.stack.fill")
                    .font(.title2)
                    .foregroundColor(woodType.color)

                Text("×\(count)")
                    .font(.caption)
                    .foregroundColor(.chopText)

                Text("+\(woodType.burnTimeMinutes)min")
                    .font(.caption2)
                    .foregroundColor(.chopSecondaryText)
            }
            .frame(width: 80, height: 80)
            .background(Color.white.opacity(0.5))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .disabled(count == 0)
        .opacity(count == 0 ? 0.5 : 1)
    }
}

// MARK: - Array Safe Subscript

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    FurnaceDetailView(isPresented: .constant(true))
        .environmentObject(GameStateManager())
}

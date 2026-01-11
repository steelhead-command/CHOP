import SwiftUI

struct AxeSelectionView: View {
    @EnvironmentObject var gameState: GameStateManager
    @Binding var isPresented: Bool

    @State private var selectedAxe: OwnedAxe?

    var body: some View {
        NavigationView {
            ZStack {
                Color.chopBackground
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    // Currently equipped
                    if let equipped = gameState.equippedAxe {
                        CurrentAxeDisplay(axe: equipped)
                    } else {
                        NoAxeEquippedView()
                    }

                    Divider()
                        .padding(.horizontal)

                    // Owned axes
                    Text("YOUR AXES")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.chopSecondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                    if gameState.gameSave.ownedAxes.isEmpty {
                        EmptyAxeRackView()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(gameState.gameSave.ownedAxes) { axe in
                                    AxeListItem(
                                        axe: axe,
                                        isEquipped: axe.isEquipped,
                                        onEquip: { equipAxe(axe) },
                                        onRepair: { repairAxe(axe) }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    Spacer()

                    // Go to store button
                    Button {
                        isPresented = false
                        // Navigate to store (handled by parent)
                    } label: {
                        HStack {
                            Image(systemName: "cart.fill")
                            Text("Visit Hardware Store")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.chopOrange)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .navigationTitle("Axe Rack")
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

    private func equipAxe(_ axe: OwnedAxe) {
        gameState.equipAxe(axe)
    }

    private func repairAxe(_ axe: OwnedAxe) {
        // Show repair options
        _ = gameState.repairAxe(axe, withAmber: false)
    }
}

// MARK: - Current Axe Display

struct CurrentAxeDisplay: View {
    let axe: OwnedAxe

    var body: some View {
        VStack(spacing: 12) {
            Text("EQUIPPED")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.chopSecondaryText)

            HStack(spacing: 16) {
                Image(systemName: "hammer.fill")
                    .font(.system(size: 40))
                    .foregroundColor(axe.isDiamond ? .amberGold : .chopText)

                VStack(alignment: .leading, spacing: 4) {
                    Text(axe.displayName)
                        .font(.headline)
                        .foregroundColor(.chopText)

                    if !axe.isDiamond {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.3))

                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.durabilityColor(for: axe.durabilityPercent))
                                    .frame(width: geometry.size.width * axe.durabilityPercent)
                            }
                        }
                        .frame(height: 8)

                        Text("\(axe.currentDurability)/\(axe.maxDurability) durability")
                            .font(.caption)
                            .foregroundColor(.chopSecondaryText)
                    } else {
                        Text("Indestructible")
                            .font(.caption)
                            .foregroundColor(.amberGold)
                    }
                }
            }
            .padding()
            .background(Color.white.opacity(0.5))
            .cornerRadius(12)
        }
        .padding(.horizontal)
        .padding(.top)
    }
}

// MARK: - No Axe Equipped

struct NoAxeEquippedView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.chopWarning)

            Text("No Axe Equipped")
                .font(.headline)
                .foregroundColor(.chopText)

            Text("Select an axe below or visit the store")
                .font(.caption)
                .foregroundColor(.chopSecondaryText)
        }
        .padding()
    }
}

// MARK: - Empty Axe Rack

struct EmptyAxeRackView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundColor(.chopSecondaryText)

            Text("No axes owned")
                .font(.headline)
                .foregroundColor(.chopText)

            Text("Visit the Hardware Store to buy your first axe!")
                .font(.caption)
                .foregroundColor(.chopSecondaryText)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.3))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Axe List Item

struct AxeListItem: View {
    let axe: OwnedAxe
    let isEquipped: Bool
    let onEquip: () -> Void
    let onRepair: () -> Void

    var needsRepair: Bool {
        !axe.isDiamond && axe.currentDurability < axe.maxDurability
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "hammer.fill")
                .font(.title2)
                .foregroundColor(axe.isDiamond ? .amberGold : .chopText)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(axe.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.chopText)

                    if isEquipped {
                        Text("EQUIPPED")
                            .font(.caption2)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.chopSuccess)
                            .cornerRadius(4)
                    }
                }

                if !axe.isDiamond {
                    HStack(spacing: 4) {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.gray.opacity(0.3))

                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.durabilityColor(for: axe.durabilityPercent))
                                    .frame(width: geometry.size.width * axe.durabilityPercent)
                            }
                        }
                        .frame(width: 60, height: 6)

                        Text("\(Int(axe.durabilityPercent * 100))%")
                            .font(.caption2)
                            .foregroundColor(.chopSecondaryText)
                    }
                } else {
                    Text("Indestructible")
                        .font(.caption)
                        .foregroundColor(.amberGold)
                }
            }

            Spacer()

            HStack(spacing: 8) {
                if needsRepair {
                    Button(action: onRepair) {
                        Image(systemName: "wrench.fill")
                            .font(.caption)
                            .foregroundColor(.chopWarning)
                            .padding(8)
                            .background(Color.chopWarning.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }

                if !isEquipped {
                    Button(action: onEquip) {
                        Text("EQUIP")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.chopOrange)
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
        .background(isEquipped ? Color.chopSuccess.opacity(0.1) : Color.white.opacity(0.5))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isEquipped ? Color.chopSuccess.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}

#Preview {
    AxeSelectionView(isPresented: .constant(true))
        .environmentObject(GameStateManager())
}

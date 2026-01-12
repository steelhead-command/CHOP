import SwiftUI

/// Interactive test harness for previewing chopping scene animations
struct ChoppingSceneTestHarness: View {
    @StateObject private var sceneState = ChoppingSceneState()

    // Test configuration
    @State private var selectedAxeState: AxeStateOption = .idle
    @State private var selectedLogState: LogStateOption = .whole
    @State private var selectedWoodType: WoodType = .medium
    @State private var hasKnot = false
    @State private var showParticles = false

    var body: some View {
        VStack(spacing: 0) {
            // Scene preview
            ZStack {
                ForestSceneBackground()

                VStack {
                    Spacer()

                    ZStack {
                        ChoppingBlockView(showImpactMark: selectedAxeState == .impact)

                        LogView(
                            woodType: selectedWoodType,
                            hasKnot: hasKnot,
                            animationState: selectedLogState.state
                        )
                        .offset(y: -70)

                        if showParticles {
                            WoodSplitParticles(woodType: selectedWoodType)
                                .offset(y: -70)
                        }

                        AxeView(
                            state: selectedAxeState.state,
                            axeTier: .mid,
                            axeType: .balanced
                        )
                        .offset(x: 80, y: -150)
                    }
                    .padding(.bottom, 100)
                }
            }
            .frame(height: 400)

            // Control panel
            ScrollView {
                VStack(spacing: 20) {
                    // Axe state controls
                    ControlSection(title: "AXE STATE") {
                        ForEach(AxeStateOption.allCases, id: \.self) { option in
                            StateButton(
                                title: option.title,
                                isSelected: selectedAxeState == option
                            ) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedAxeState = option
                                }
                            }
                        }
                    }

                    // Log state controls
                    ControlSection(title: "LOG STATE") {
                        ForEach(LogStateOption.allCases, id: \.self) { option in
                            StateButton(
                                title: option.title,
                                isSelected: selectedLogState == option
                            ) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedLogState = option
                                }
                            }
                        }
                    }

                    // Wood type controls
                    ControlSection(title: "WOOD TYPE") {
                        ForEach(WoodType.allCases, id: \.self) { woodType in
                            StateButton(
                                title: woodType.displayName,
                                isSelected: selectedWoodType == woodType,
                                color: woodType.color
                            ) {
                                selectedWoodType = woodType
                            }
                        }
                    }

                    // Toggles
                    HStack(spacing: 16) {
                        Toggle(isOn: $hasKnot) {
                            Text("Knot")
                                .font(.caption)
                        }

                        Toggle(isOn: $showParticles) {
                            Text("Particles")
                                .font(.caption)
                        }
                    }
                    .padding(.horizontal)

                    // Animation test button
                    Button {
                        runFullAnimation()
                    } label: {
                        Text("Run Full Chop Animation")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.chopOrange)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .background(Color.chopBackground)
        }
    }

    // MARK: - Animation Sequence

    private func runFullAnimation() {
        // Reset to start
        selectedAxeState = .idle
        selectedLogState = .whole
        showParticles = false

        // Tracking
        withAnimation(.easeIn(duration: 0.1)) {
            selectedAxeState = .tracking
        }

        // Swing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.easeIn(duration: 0.08)) {
                selectedAxeState = .swinging
            }
        }

        // Impact
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.23) {
            selectedAxeState = .impact
            selectedLogState = .cracking
            HapticManager.shared.heavyTap()
        }

        // Split
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
            withAnimation(.easeOut(duration: 0.3)) {
                selectedLogState = .splitting
            }
            showParticles = true
        }

        // Return axe
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                selectedAxeState = .returning
            }
        }

        // Reset
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            selectedAxeState = .idle
            selectedLogState = .whole
            showParticles = false
        }
    }
}

// MARK: - State Options

enum AxeStateOption: CaseIterable {
    case idle, tracking, swinging, impact, returning

    var title: String {
        switch self {
        case .idle: return "Idle"
        case .tracking: return "Tracking"
        case .swinging: return "Swinging"
        case .impact: return "Impact"
        case .returning: return "Returning"
        }
    }

    var state: AxeAnimationState {
        switch self {
        case .idle: return .idle
        case .tracking: return .tracking(progress: 0.7)
        case .swinging: return .swinging(progress: 1.0)
        case .impact: return .impact
        case .returning: return .returning
        }
    }
}

enum LogStateOption: CaseIterable {
    case whole, shaking, cracking, splitting, removed

    var title: String {
        switch self {
        case .whole: return "Whole"
        case .shaking: return "Shaking"
        case .cracking: return "Cracking"
        case .splitting: return "Splitting"
        case .removed: return "Removed"
        }
    }

    var state: LogAnimationState {
        switch self {
        case .whole: return .whole
        case .shaking: return .shaking(intensity: 1.0)
        case .cracking: return .cracking
        case .splitting: return .splitting(progress: 1.0)
        case .removed: return .removed
        }
    }
}

// MARK: - Helper Views

struct ControlSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.chopSecondaryText)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    content()
                }
            }
        }
    }
}

struct StateButton: View {
    let title: String
    let isSelected: Bool
    var color: Color = .chopOrange
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .chopText)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? color : Color.white.opacity(0.5))
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews

#Preview("Chopping Scene Test Harness") {
    ChoppingSceneTestHarness()
}

#Preview("Axe States Gallery") {
    VStack(spacing: 30) {
        ForEach(AxeStateOption.allCases, id: \.self) { option in
            VStack {
                AxeView(state: option.state, axeTier: .mid, axeType: .balanced)
                    .frame(height: 150)
                Text(option.title)
                    .font(.caption)
            }
        }
    }
    .padding()
    .background(Color.chopBackground)
}

#Preview("Log States Gallery") {
    VStack(spacing: 20) {
        ForEach(LogStateOption.allCases, id: \.self) { option in
            VStack {
                LogView(woodType: .medium, hasKnot: false, animationState: option.state)
                    .frame(height: 100)
                Text(option.title)
                    .font(.caption)
            }
        }
    }
    .padding()
    .background(Color.chopBackground)
}

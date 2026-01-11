import SwiftUI

struct ContentView: View {
    @EnvironmentObject var gameState: GameStateManager
    @State private var currentScreen: AppScreen = .homestead

    var body: some View {
        ZStack {
            // Background color
            Color.creamWhite
                .ignoresSafeArea()

            // Main content with navigation
            NavigationStack {
                switch currentScreen {
                case .homestead:
                    HomesteadView(currentScreen: $currentScreen)
                case .forest:
                    ForestView(currentScreen: $currentScreen)
                case .store:
                    HardwareStoreView(currentScreen: $currentScreen)
                case .gathering:
                    GatheringHubView(currentScreen: $currentScreen)
                case .results(let runResult):
                    ResultsView(result: runResult, currentScreen: $currentScreen)
                }
            }
        }
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    handleSwipe(gesture)
                }
        )
    }

    private func handleSwipe(_ gesture: DragGesture.Value) {
        let horizontalDistance = gesture.translation.width
        let verticalDistance = gesture.translation.height

        // Only handle swipes on homestead
        guard currentScreen == .homestead else { return }

        if abs(horizontalDistance) > abs(verticalDistance) {
            // Horizontal swipe
            if horizontalDistance > 50 {
                // Swipe right -> Gathering
                withAnimation(.spring(response: 0.3)) {
                    currentScreen = .gathering
                }
            } else if horizontalDistance < -50 {
                // Swipe left -> Store
                withAnimation(.spring(response: 0.3)) {
                    currentScreen = .store
                }
            }
        } else if verticalDistance < -50 {
            // Swipe up -> Forest
            withAnimation(.spring(response: 0.3)) {
                currentScreen = .forest
            }
        }
    }
}

enum AppScreen: Equatable {
    case homestead
    case forest
    case store
    case gathering
    case results(RunResult)

    static func == (lhs: AppScreen, rhs: AppScreen) -> Bool {
        switch (lhs, rhs) {
        case (.homestead, .homestead),
             (.forest, .forest),
             (.store, .store),
             (.gathering, .gathering):
            return true
        case (.results, .results):
            return true
        default:
            return false
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(GameStateManager())
        .environmentObject(AudioManager())
}

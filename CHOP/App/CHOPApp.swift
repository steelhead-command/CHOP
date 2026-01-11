import SwiftUI

@main
struct CHOPApp: App {
    @StateObject private var gameState = GameStateManager()
    @StateObject private var audioManager = AudioManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameState)
                .environmentObject(audioManager)
                .preferredColorScheme(.light)
        }
    }
}

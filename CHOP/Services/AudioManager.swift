import AVFoundation
import SwiftUI

@MainActor
class AudioManager: ObservableObject {
    // MARK: - Published State

    @Published var isSoundEnabled: Bool = true
    @Published var isMusicEnabled: Bool = true
    @Published var volume: Float = 0.8

    // MARK: - Audio Players

    private var musicPlayer: AVAudioPlayer?
    private var soundEffects: [String: AVAudioPlayer] = [:]

    // MARK: - Sound Effect Names

    enum SoundEffect: String {
        // Chopping
        case chopSoft = "chop_soft"
        case chopMedium = "chop_medium"
        case chopHard = "chop_hard"
        case knotStrike = "knot_strike"
        case knotCreak = "knot_creak"
        case knotBreak = "knot_break"
        case chopMiss = "chop_miss"
        case axeBreak = "axe_break"

        // UI
        case buttonTap = "button_tap"
        case coinEarned = "coin_earned"
        case amberFound = "amber_found"
        case purchase = "purchase"
        case productReady = "product_ready"
        case strikeEarned = "strike_earned"

        // Activities
        case fishCaught = "fish_caught"
        case berryPick = "berry_pick"
        case nutShake = "nut_shake"
        case herbSwipe = "herb_swipe"
    }

    // MARK: - Initialization

    init() {
        setupAudioSession()
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }

    // MARK: - Sound Effects

    func playSound(_ effect: SoundEffect) {
        guard isSoundEnabled else { return }

        // In a real implementation, load from bundle
        // For now, this is a placeholder
        print("Playing sound: \(effect.rawValue)")
    }

    func playChopSound(for woodType: WoodType) {
        switch woodType {
        case .soft:
            playSound(.chopSoft)
        case .medium:
            playSound(.chopMedium)
        case .hard:
            playSound(.chopHard)
        }
    }

    // MARK: - Music

    func playMusic(_ track: String, loop: Bool = true) {
        guard isMusicEnabled else { return }

        // Placeholder for music playback
        print("Playing music: \(track), loop: \(loop)")
    }

    func stopMusic() {
        musicPlayer?.stop()
        musicPlayer = nil
    }

    func pauseMusic() {
        musicPlayer?.pause()
    }

    func resumeMusic() {
        guard isMusicEnabled else { return }
        musicPlayer?.play()
    }

    // MARK: - Settings

    func toggleSound() {
        isSoundEnabled.toggle()
    }

    func toggleMusic() {
        isMusicEnabled.toggle()
        if !isMusicEnabled {
            stopMusic()
        }
    }

    func setVolume(_ newVolume: Float) {
        volume = max(0, min(1, newVolume))
        musicPlayer?.volume = volume
    }
}

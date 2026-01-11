import UIKit
import CoreHaptics

@MainActor
class HapticManager: ObservableObject {
    static let shared = HapticManager()

    private var engine: CHHapticEngine?
    @Published var isEnabled: Bool = true

    // MARK: - Initialization

    private init() {
        setupEngine()
    }

    private func setupEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            engine = try CHHapticEngine()
            try engine?.start()

            engine?.resetHandler = { [weak self] in
                do {
                    try self?.engine?.start()
                } catch {
                    print("Failed to restart haptic engine: \(error)")
                }
            }
        } catch {
            print("Failed to create haptic engine: \(error)")
        }
    }

    // MARK: - Simple Haptics (UIKit Feedback)

    func lightTap() {
        guard isEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    func mediumTap() {
        guard isEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    func heavyTap() {
        guard isEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }

    func rigidTap() {
        guard isEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.impactOccurred()
    }

    func softTap() {
        guard isEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
    }

    func success() {
        guard isEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    func warning() {
        guard isEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }

    func error() {
        guard isEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    func selectionChanged() {
        guard isEnabled else { return }
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    // MARK: - CHOP-Specific Haptics

    func chopSoftWood() {
        guard isEnabled else { return }
        lightTap()
    }

    func chopMediumWood() {
        guard isEnabled else { return }
        mediumTap()
    }

    func chopHardWood() {
        guard isEnabled else { return }
        heavyTap()
    }

    func knotStrike() {
        guard isEnabled else { return }
        playKnotStrikePattern()
    }

    func knotBreakSuccess() {
        guard isEnabled else { return }
        playKnotBreakPattern()
    }

    func knotFailed() {
        guard isEnabled else { return }
        softTap()
    }

    func strikeEarned() {
        guard isEnabled else { return }
        playStrikePattern()
    }

    func axeBreak() {
        guard isEnabled else { return }
        rigidTap()
    }

    func amberFound() {
        guard isEnabled else { return }
        playAmberPattern()
    }

    func multiplierUp() {
        guard isEnabled else { return }
        selectionChanged()
    }

    // MARK: - Core Haptics Patterns

    private func playKnotStrikePattern() {
        guard let engine = engine else {
            heavyTap()
            return
        }

        do {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.85)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)

            let event = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [intensity, sharpness],
                relativeTime: 0,
                duration: 0.08
            )

            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            heavyTap()
        }
    }

    private func playKnotBreakPattern() {
        guard let engine = engine else {
            success()
            return
        }

        do {
            var events: [CHHapticEvent] = []

            // Heavy impact
            let heavyIntensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.9)
            let heavySharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
            events.append(CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [heavyIntensity, heavySharpness],
                relativeTime: 0,
                duration: 0.05
            ))

            // Triple celebration taps
            for i in 1...3 {
                let tapIntensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5)
                let tapSharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
                events.append(CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [tapIntensity, tapSharpness],
                    relativeTime: 0.05 + Double(i) * 0.05,
                    duration: 0.02
                ))
            }

            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            success()
        }
    }

    private func playStrikePattern() {
        guard let engine = engine else {
            error()
            return
        }

        do {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.1)

            let event = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [intensity, sharpness],
                relativeTime: 0,
                duration: 0.1
            )

            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            self.error()
        }
    }

    private func playAmberPattern() {
        guard let engine = engine else {
            success()
            return
        }

        do {
            var events: [CHHapticEvent] = []

            // Ascending shimmer taps
            for i in 0..<5 {
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.2 + Float(i) * 0.1)
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
                events.append(CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [intensity, sharpness],
                    relativeTime: Double(i) * 0.04,
                    duration: 0.02
                ))
            }

            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            success()
        }
    }
}

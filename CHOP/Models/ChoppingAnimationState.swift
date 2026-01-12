import SwiftUI
import Combine

// MARK: - Axe Animation State

enum AxeAnimationState: Equatable {
    case idle
    case tracking(progress: CGFloat)  // 0.0 to 1.0 based on swipe progress
    case swinging(progress: CGFloat)  // 0.0 to 1.0 during swing animation
    case impact
    case returning

    var rotation: Double {
        switch self {
        case .idle:
            return -45
        case .tracking(let progress):
            return -45 + Double(progress) * 30  // Rotate toward vertical as user swipes
        case .swinging(let progress):
            return -15 + Double(progress) * 60  // Swing down to 45 degrees
        case .impact:
            return 45
        case .returning:
            return -45
        }
    }

    var offsetY: CGFloat {
        switch self {
        case .idle:
            return 0
        case .tracking(let progress):
            return progress * 20
        case .swinging(let progress):
            return 20 + progress * 80  // Move down during swing
        case .impact:
            return 100
        case .returning:
            return 0
        }
    }

    var scale: CGFloat {
        switch self {
        case .impact:
            return 1.1  // Slight enlarge on impact
        default:
            return 1.0
        }
    }
}

// MARK: - Log Animation State

enum LogAnimationState: Equatable {
    case whole
    case shaking(intensity: CGFloat)  // For partial chops
    case cracking
    case splitting(progress: CGFloat)  // 0.0 to 1.0
    case removed

    var shakeOffset: CGFloat {
        switch self {
        case .shaking(let intensity):
            return intensity * 5
        default:
            return 0
        }
    }

    var splitOffset: CGFloat {
        switch self {
        case .splitting(let progress):
            return progress * 40  // How far apart the halves move
        default:
            return 0
        }
    }

    var opacity: Double {
        switch self {
        case .removed:
            return 0
        default:
            return 1
        }
    }
}

// MARK: - Chopping Scene State

@MainActor
class ChoppingSceneState: ObservableObject {
    // Animation states
    @Published var axeState: AxeAnimationState = .idle
    @Published var logState: LogAnimationState = .whole
    @Published var showSplitParticles = false
    @Published var showInstruction = true

    // Debug properties
    @Published var isDebugMode = false
    @Published var animationSpeed: Double = 1.0
    @Published var hapticsEnabled = true
    @Published var frameCount = 0

    // Timing constants (can be adjusted with animationSpeed)
    var swingDuration: Double { 0.08 / animationSpeed }
    var impactHoldDuration: Double { 0.05 / animationSpeed }
    var returnDuration: Double { 0.35 / animationSpeed }
    var splitDuration: Double { 0.3 / animationSpeed }
    var shakeDuration: Double { 0.15 / animationSpeed }
    var particleDuration: Double { 0.8 / animationSpeed }

    // Current swipe tracking
    private var swipeStartY: CGFloat = 0
    private var isSwipeActive = false

    // MARK: - Swipe Handling

    func handleSwipeStart(at position: CGPoint) {
        swipeStartY = position.y
        isSwipeActive = true
        showInstruction = false
    }

    func handleSwipeChange(translation: CGSize) {
        guard isSwipeActive else { return }

        // Only track downward swipes with minimal horizontal movement
        let verticalDistance = translation.height
        let horizontalDistance = abs(translation.width)

        if verticalDistance > 0 && horizontalDistance < verticalDistance {
            let progress = min(verticalDistance / 50.0, 1.0)
            axeState = .tracking(progress: progress)
        }
    }

    func handleSwipeEnd(translation: CGSize, onChop: @escaping () -> Bool) {
        guard isSwipeActive else { return }
        isSwipeActive = false

        let verticalDistance = translation.height
        let horizontalDistance = abs(translation.width)

        // Valid chop: >50pt vertical, mostly downward
        if verticalDistance > 50 && horizontalDistance < verticalDistance {
            executeChop(didSplit: onChop())
        } else {
            // Cancelled swipe - return to idle
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                axeState = .idle
            }
        }
    }

    // MARK: - Chop Animation

    func executeChop(didSplit: Bool) {
        // Phase 1: Swing down
        withAnimation(.easeIn(duration: swingDuration)) {
            axeState = .swinging(progress: 1.0)
        }

        // Phase 2: Impact
        DispatchQueue.main.asyncAfter(deadline: .now() + swingDuration) { [weak self] in
            guard let self else { return }

            withAnimation(.none) {
                self.axeState = .impact
            }

            // Trigger haptic at impact
            if self.hapticsEnabled {
                HapticManager.shared.heavyTap()
            }

            if didSplit {
                self.animateSplit()
            } else {
                self.animatePartialChop()
            }

            // Phase 3: Return axe
            DispatchQueue.main.asyncAfter(deadline: .now() + self.impactHoldDuration) { [weak self] in
                guard let self else { return }
                withAnimation(.spring(response: self.returnDuration, dampingFraction: 0.6)) {
                    self.axeState = .returning
                }

                // Reset to idle
                DispatchQueue.main.asyncAfter(deadline: .now() + self.returnDuration) { [weak self] in
                    self?.axeState = .idle
                }
            }
        }
    }

    private func animateSplit() {
        // Crack effect
        withAnimation(.easeOut(duration: 0.05)) {
            logState = .cracking
        }

        // Split apart
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            guard let self else { return }

            withAnimation(.easeOut(duration: self.splitDuration)) {
                self.logState = .splitting(progress: 1.0)
            }

            // Show particles
            self.showSplitParticles = true

            // Hide log and particles
            DispatchQueue.main.asyncAfter(deadline: .now() + self.splitDuration) { [weak self] in
                guard let self else { return }
                self.logState = .removed

                DispatchQueue.main.asyncAfter(deadline: .now() + self.particleDuration) { [weak self] in
                    self?.showSplitParticles = false
                }
            }
        }
    }

    private func animatePartialChop() {
        // Quick shake
        withAnimation(.easeInOut(duration: shakeDuration / 3).repeatCount(3, autoreverses: true)) {
            logState = .shaking(intensity: 1.0)
        }

        // Return to whole
        DispatchQueue.main.asyncAfter(deadline: .now() + shakeDuration) { [weak self] in
            withAnimation(.easeOut(duration: 0.1)) {
                self?.logState = .whole
            }
        }
    }

    // MARK: - New Log

    func prepareNewLog() {
        logState = .whole
        showSplitParticles = false
    }

    // MARK: - Debug

    func incrementFrameCount() {
        frameCount += 1
    }

    func resetForDebug() {
        axeState = .idle
        logState = .whole
        showSplitParticles = false
        showInstruction = true
    }
}

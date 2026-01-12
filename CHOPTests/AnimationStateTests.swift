import XCTest
@testable import CHOP

final class AnimationStateTests: XCTestCase {

    // MARK: - Axe Animation State Tests

    func testAxeIdleState() {
        let state = AxeAnimationState.idle
        XCTAssertEqual(state.rotation, -45, "Idle rotation should be -45 degrees")
        XCTAssertEqual(state.offsetY, 0, "Idle offset should be 0")
        XCTAssertEqual(state.scale, 1.0, "Idle scale should be 1.0")
    }

    func testAxeTrackingState() {
        let state = AxeAnimationState.tracking(progress: 0.5)
        XCTAssertEqual(state.rotation, -30, "Tracking at 0.5 should be -30 degrees")
        XCTAssertEqual(state.offsetY, 10, "Tracking offset should be proportional")
        XCTAssertEqual(state.scale, 1.0, "Tracking scale should be 1.0")
    }

    func testAxeSwingingState() {
        let startState = AxeAnimationState.swinging(progress: 0.0)
        let endState = AxeAnimationState.swinging(progress: 1.0)

        XCTAssertEqual(startState.rotation, -15, "Swing start rotation")
        XCTAssertEqual(endState.rotation, 45, "Swing end rotation")
        XCTAssertGreaterThan(endState.offsetY, startState.offsetY, "Axe should move down during swing")
    }

    func testAxeImpactState() {
        let state = AxeAnimationState.impact
        XCTAssertEqual(state.rotation, 45, "Impact rotation should be 45 degrees")
        XCTAssertEqual(state.offsetY, 100, "Impact offset should be at full swing")
        XCTAssertEqual(state.scale, 1.1, "Impact should have slight scale for emphasis")
    }

    func testAxeReturningState() {
        let state = AxeAnimationState.returning
        XCTAssertEqual(state.rotation, -45, "Returning rotation should match idle")
        XCTAssertEqual(state.offsetY, 0, "Returning offset should return to start")
    }

    // MARK: - Log Animation State Tests

    func testLogWholeState() {
        let state = LogAnimationState.whole
        XCTAssertEqual(state.shakeOffset, 0, "Whole log shouldn't shake")
        XCTAssertEqual(state.splitOffset, 0, "Whole log shouldn't split")
        XCTAssertEqual(state.opacity, 1.0, "Whole log should be visible")
    }

    func testLogShakingState() {
        let state = LogAnimationState.shaking(intensity: 1.0)
        XCTAssertEqual(state.shakeOffset, 5, "Shaking should have offset")
        XCTAssertEqual(state.opacity, 1.0, "Shaking log should be visible")
    }

    func testLogSplittingState() {
        let halfSplit = LogAnimationState.splitting(progress: 0.5)
        let fullSplit = LogAnimationState.splitting(progress: 1.0)

        XCTAssertEqual(halfSplit.splitOffset, 20, "Half split offset")
        XCTAssertEqual(fullSplit.splitOffset, 40, "Full split offset")
        XCTAssertEqual(fullSplit.opacity, 1.0, "Splitting log should be visible")
    }

    func testLogRemovedState() {
        let state = LogAnimationState.removed
        XCTAssertEqual(state.opacity, 0, "Removed log should be invisible")
    }

    // MARK: - State Equality Tests

    func testAxeStateEquality() {
        XCTAssertEqual(AxeAnimationState.idle, AxeAnimationState.idle)
        XCTAssertEqual(
            AxeAnimationState.tracking(progress: 0.5),
            AxeAnimationState.tracking(progress: 0.5)
        )
        XCTAssertNotEqual(
            AxeAnimationState.tracking(progress: 0.5),
            AxeAnimationState.tracking(progress: 0.7)
        )
        XCTAssertNotEqual(AxeAnimationState.idle, AxeAnimationState.impact)
    }

    func testLogStateEquality() {
        XCTAssertEqual(LogAnimationState.whole, LogAnimationState.whole)
        XCTAssertEqual(
            LogAnimationState.splitting(progress: 0.5),
            LogAnimationState.splitting(progress: 0.5)
        )
        XCTAssertNotEqual(LogAnimationState.whole, LogAnimationState.cracking)
    }

    // MARK: - Animation Timing Tests

    @MainActor
    func testChoppingSceneStateDefaultValues() async {
        let sceneState = ChoppingSceneState()

        XCTAssertEqual(sceneState.axeState, .idle, "Initial axe state should be idle")
        XCTAssertEqual(sceneState.logState, .whole, "Initial log state should be whole")
        XCTAssertFalse(sceneState.showSplitParticles, "Particles should not show initially")
        XCTAssertTrue(sceneState.showInstruction, "Instruction should show initially")
        XCTAssertEqual(sceneState.animationSpeed, 1.0, "Default animation speed should be 1.0")
    }

    @MainActor
    func testChoppingSceneStateAnimationSpeedAffectsTiming() async {
        let sceneState = ChoppingSceneState()

        sceneState.animationSpeed = 2.0
        XCTAssertEqual(sceneState.swingDuration, 0.04, accuracy: 0.001, "Double speed should halve duration")

        sceneState.animationSpeed = 0.5
        XCTAssertEqual(sceneState.swingDuration, 0.16, accuracy: 0.001, "Half speed should double duration")
    }

    @MainActor
    func testPrepareNewLogResetsState() async {
        let sceneState = ChoppingSceneState()

        // Simulate some state changes
        sceneState.logState = .splitting(progress: 1.0)
        sceneState.showSplitParticles = true

        // Reset
        sceneState.prepareNewLog()

        XCTAssertEqual(sceneState.logState, .whole, "Log state should reset to whole")
        XCTAssertFalse(sceneState.showSplitParticles, "Particles should be hidden")
    }
}

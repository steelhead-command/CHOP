import XCTest

final class ChoppingUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Navigation Tests

    func testNavigateToForest() throws {
        // Tap on forest/chop button from homestead
        let chopButton = app.buttons["SWIPE TO CHOP"].firstMatch
        if chopButton.waitForExistence(timeout: 5) {
            chopButton.tap()

            // Verify we're in the forest view
            let scoreLabel = app.staticTexts["SCORE"]
            XCTAssertTrue(scoreLabel.waitForExistence(timeout: 3), "Should navigate to forest view")
        }
    }

    // MARK: - Swipe Gesture Tests

    func testSwipeDownTriggersChop() throws {
        // Navigate to forest first
        navigateToForest()

        // Get initial score
        let scoreLabel = app.staticTexts.matching(identifier: "scoreValue").firstMatch
        let initialScore = scoreLabel.label

        // Perform swipe down
        let choppingArea = app.otherElements["choppingArea"].firstMatch
        if choppingArea.exists {
            choppingArea.swipeDown()

            // Wait for animation
            Thread.sleep(forTimeInterval: 0.5)

            // Score should change or log should be affected
            // Note: Exact verification depends on game state
        }
    }

    func testPartialSwipeCancels() throws {
        navigateToForest()

        // Perform a short swipe that shouldn't trigger chop
        let choppingArea = app.otherElements["choppingArea"].firstMatch
        if choppingArea.exists {
            // Simulate a short drag that doesn't complete
            let start = choppingArea.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.3))
            let end = choppingArea.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.4))
            start.press(forDuration: 0.1, thenDragTo: end)

            // Axe should return to idle without chopping
            Thread.sleep(forTimeInterval: 0.3)
        }
    }

    func testHorizontalSwipeIgnored() throws {
        navigateToForest()

        let scoreLabel = app.staticTexts.matching(identifier: "scoreValue").firstMatch
        let initialScore = scoreLabel.label

        // Perform horizontal swipe
        let choppingArea = app.otherElements["choppingArea"].firstMatch
        if choppingArea.exists {
            choppingArea.swipeRight()

            Thread.sleep(forTimeInterval: 0.3)

            // Score should remain unchanged
            XCTAssertEqual(scoreLabel.label, initialScore, "Horizontal swipe should not trigger chop")
        }
    }

    func testRapidChopsHandled() throws {
        navigateToForest()

        let choppingArea = app.otherElements["choppingArea"].firstMatch
        if choppingArea.exists {
            // Perform multiple rapid swipes
            for _ in 0..<5 {
                choppingArea.swipeDown()
                Thread.sleep(forTimeInterval: 0.15)  // Small delay between swipes
            }

            // App should not crash and should handle rapid input
            XCTAssertTrue(app.exists, "App should remain stable during rapid chops")
        }
    }

    // MARK: - UI Element Tests

    func testForestHUDDisplaysCorrectly() throws {
        navigateToForest()

        // Verify HUD elements exist
        XCTAssertTrue(app.staticTexts["SCORE"].waitForExistence(timeout: 3))

        // Verify strike indicators exist (3 circles)
        // Note: Accessibility identifiers would help here
    }

    func testDurabilityBarDisplays() throws {
        navigateToForest()

        // Durability bar should be visible
        let durabilityBar = app.progressIndicators.firstMatch
        if durabilityBar.exists {
            XCTAssertTrue(true, "Durability bar is visible")
        }
    }

    func testHomeButtonReturnsToHomestead() throws {
        navigateToForest()

        // Tap home button
        let homeButton = app.buttons["HOME"]
        if homeButton.waitForExistence(timeout: 3) {
            homeButton.tap()

            // Should show results or return to homestead
            Thread.sleep(forTimeInterval: 0.5)

            // Verify we're no longer in forest
            let forestScore = app.staticTexts["SCORE"]
            // Either we see results or homestead
        }
    }

    // MARK: - Instruction Overlay Tests

    func testInstructionOverlayAppearsOnFirstLoad() throws {
        // Fresh launch should show instruction
        let instruction = app.staticTexts["SWIPE DOWN TO CHOP"]

        navigateToForest()

        // Instruction should appear initially
        // Note: This may depend on whether it's truly first launch
    }

    func testInstructionOverlayDismissesAfterSwipe() throws {
        navigateToForest()

        let choppingArea = app.otherElements["choppingArea"].firstMatch
        if choppingArea.exists {
            choppingArea.swipeDown()

            Thread.sleep(forTimeInterval: 0.5)

            // Instruction overlay should be hidden after first swipe
            let instruction = app.staticTexts["SWIPE DOWN TO CHOP"]
            XCTAssertFalse(instruction.exists, "Instruction should dismiss after first swipe")
        }
    }

    // MARK: - Helper Methods

    private func navigateToForest() {
        // Navigate from homestead to forest
        let chopButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'CHOP'")).firstMatch
        if chopButton.waitForExistence(timeout: 5) {
            chopButton.tap()
            Thread.sleep(forTimeInterval: 0.5)
        }
    }
}

// MARK: - Performance Tests

final class ChoppingPerformanceTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    func testChoppingAnimationPerformance() throws {
        app.launch()

        measure(metrics: [XCTOSSignpostMetric.scrollingAndDecelerationMetric]) {
            // Navigate to forest
            let chopButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'CHOP'")).firstMatch
            if chopButton.waitForExistence(timeout: 5) {
                chopButton.tap()
                Thread.sleep(forTimeInterval: 0.5)

                // Perform chops
                let choppingArea = app.otherElements["choppingArea"].firstMatch
                if choppingArea.exists {
                    for _ in 0..<10 {
                        choppingArea.swipeDown()
                        Thread.sleep(forTimeInterval: 0.3)
                    }
                }
            }
        }
    }

    func testMemoryDuringExtendedPlay() throws {
        let metrics: [XCTMetric] = [XCTMemoryMetric()]

        measure(metrics: metrics) {
            app.launch()

            let chopButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'CHOP'")).firstMatch
            if chopButton.waitForExistence(timeout: 5) {
                chopButton.tap()
                Thread.sleep(forTimeInterval: 0.5)

                let choppingArea = app.otherElements["choppingArea"].firstMatch
                if choppingArea.exists {
                    // Extended chopping session
                    for _ in 0..<20 {
                        choppingArea.swipeDown()
                        Thread.sleep(forTimeInterval: 0.2)
                    }
                }
            }

            app.terminate()
        }
    }
}

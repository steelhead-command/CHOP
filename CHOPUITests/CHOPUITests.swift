import XCTest

final class CHOPUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testAppLaunches() throws {
        let app = XCUIApplication()
        app.launch()

        // Verify the main screen appears
        XCTAssertTrue(app.staticTexts["TAP TO CHOP"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testNavigateToForest() throws {
        let app = XCUIApplication()
        app.launch()

        // Tap the forest button
        let forestButton = app.buttons["TAP TO CHOP"]
        if forestButton.waitForExistence(timeout: 5) {
            forestButton.tap()
        }
    }
}

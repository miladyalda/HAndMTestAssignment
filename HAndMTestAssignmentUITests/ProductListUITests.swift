//
//  ProductListUITests.swift
//  HAndMTestAssignment
//
//  Created by milad yalda on 2026-03-03.
//

import XCTest

final class ProductListUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
    }

    private func launch(scenario: String) {
        app.launchArguments = ["-UITest", "-Scenario_\(scenario)"]
        app.launch()
    }

    // MARK: - Product Grid Loads

    func testProductGridDisplaysItems() {
        launch(scenario: "success")

        let grid = app.scrollViews[AccessibilityID.productGrid]
        XCTAssertTrue(grid.waitForExistence(timeout: 5))

        let firstCard = app.buttons[AccessibilityID.productCard("product_0")]
        XCTAssertTrue(firstCard.waitForExistence(timeout: 5))

        XCTAssertTrue(app.staticTexts["Test Jeans 0"].exists)
        XCTAssertTrue(app.staticTexts["H&M"].exists)
        XCTAssertTrue(app.staticTexts["299,00 kr."].exists)
    }

    // MARK: - Pagination

    func testPaginationLoadsMoreProducts() {
        launch(scenario: "pagination")

        let grid = element(withIdentifier: AccessibilityID.productGrid)
        XCTAssertTrue(grid.exists)

        let firstCard = element(withIdentifier: AccessibilityID.productCard("product_0"))
        XCTAssertTrue(firstCard.exists)

        // Scroll enough to reach the bottom and trigger pagination
        for _ in 0..<5 {
            grid.swipeUp()
        }

        let page2Card = element(withIdentifier: AccessibilityID.productCard("product_10"), timeout: 10)
        XCTAssertTrue(page2Card.exists)
    }

    // MARK: - Error State

    func testErrorStateShowsRetryButton() {
        launch(scenario: "error")

        let retryButton = element(withIdentifier: AccessibilityID.retryButton)
        XCTAssertTrue(retryButton.exists)

        XCTAssertTrue(app.staticTexts["No internet connection. Please check your network."].exists)
    }

    // MARK: - Empty State

    func testEmptyStateShowsMessage() {
        launch(scenario: "empty")

        XCTAssertTrue(app.staticTexts[ProductStrings.emptyMessage].waitForExistence(timeout: 5))
    }

    // MARK: - Favorite Toggle

    func testFavoriteToggle() {
        launch(scenario: "success")

        let firstCard = element(withIdentifier: AccessibilityID.productCard("product_0"))
        XCTAssertTrue(firstCard.exists)

        let favoriteButton = element(withIdentifier: AccessibilityID.favoriteButton("product_0"))
        XCTAssertTrue(favoriteButton.exists)

        favoriteButton.tap()
        XCTAssertTrue(favoriteButton.label.contains("Remove"))

        favoriteButton.tap()
        XCTAssertTrue(favoriteButton.label.contains("Add"))
    }

    // MARK: - Image Placeholder

    func testImagePlaceholderShowsForNilURLs() {
        launch(scenario: "success")

        let firstCard = element(withIdentifier: AccessibilityID.productCard("product_0"))
        XCTAssertTrue(firstCard.exists)

        let placeholder = app.images[ProductIcons.imagePlaceholder]
        XCTAssertTrue(placeholder.exists)
    }

    // MARK: - Helper method

    private func element(withIdentifier id: String, timeout: TimeInterval = 5) -> XCUIElement {
        let element = app.descendants(matching: .any)[id].firstMatch
        _ = element.waitForExistence(timeout: timeout)
        return element
    }
}

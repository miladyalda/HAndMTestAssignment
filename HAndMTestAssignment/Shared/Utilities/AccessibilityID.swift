//
//  AccessibilityID.swift
//  HAndMTestAssignment
//
//  Created by milad yalda on 2026-03-03.
//

/// Accessibility identifiers for UI testing.
/// Shared between views and XCUITests to prevent string mismatches.
enum AccessibilityID {
    static let productGrid = "productGrid"
    static let loadingView = "loadingView"
    static let errorView = "errorView"
    static let emptyView = "emptyView"
    static let retryButton = "retryButton"
    static let paginationSpinner = "paginationSpinner"

    static func productCard(_ id: String) -> String { "productCard_\(id)" }
    static func favoriteButton(_ id: String) -> String { "favoriteButton_\(id)" }
}

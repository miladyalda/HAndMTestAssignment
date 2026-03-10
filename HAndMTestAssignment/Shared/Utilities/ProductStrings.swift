//
//  ProductStrings.swift
//  HAndMTestAssignment
//
//  Created by milad yalda on 2026-03-03.
//

/// User-facing strings for the product list feature.
/// Centralizes text for consistency and future localization.
enum ProductStrings {
    static let navigationTitle = "Jeans"
    static let loadingMessage = "Loading products..."
    static let emptyMessage = "No products found"
    static let retryButton = "Try Again"

    static func navigationTitleWithCount(_ count: Int) -> String {
        "\(navigationTitle) (\(count))"
    }

    static func addFavorite(_ name: String) -> String {
        "Add \(name) to favorites"
    }

    static func removeFavorite(_ name: String) -> String {
        "Remove \(name) from favorites"
    }

    // MARK: - Accessibility

    static let onSalePrefix = ", on sale for "
    static let availableInPrefix = ", available in "
    static let favorited = ", favorited"

    static func productAccessibilityLabel(
        brand: String,
        name: String,
        originalPrice: String,
        salePrice: String?,
        colorNames: [String],
        isFavorite: Bool
    ) -> String {
        var description = "\(brand), \(name), \(originalPrice)"
        if let salePrice {
            description += "\(onSalePrefix)\(salePrice)"
        }
        if !colorNames.isEmpty {
            description += "\(availableInPrefix)\(colorNames.joined(separator: ", "))"
        }
        if isFavorite {
            description += favorited
        }
        return description
    }
}

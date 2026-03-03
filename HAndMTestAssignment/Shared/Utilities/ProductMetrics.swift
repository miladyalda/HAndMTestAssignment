//
//  Layout.swift
//  HAndMTestAssignment
//
//  Created by milad yalda on 2026-03-03.
//

import Foundation
import SwiftUI

/// Shared design constants for the product grid and card layout.
/// Centralizes all spacing, sizing, and threshold values for consistency.
enum ProductMetrics {

    // MARK: - Grid Layout

    /// Horizontal spacing between the two columns
    static let columnSpacing: CGFloat = 8
    /// Vertical spacing between grid rows
    static let rowSpacing: CGFloat = 16
    /// Leading and trailing padding of the grid
    static let horizontalPadding: CGFloat = 8

    // MARK: - Card Layout

    /// Vertical spacing between image, info, and swatches
    static let cardContentSpacing: CGFloat = 4
    /// Spacing between brand, name, and price labels
    static let cardInfoSpacing: CGFloat = 2
    /// Image aspect ratio (width / height)
    static let imageAspectRatio: CGFloat = 2 / 3

    // MARK: - Price

    /// Spacing between sale price and original price
    static let priceSpacing: CGFloat = 4

    // MARK: - Swatches

    static let swatchSpacing: CGFloat = 4
    static let swatchSize: CGFloat = 12
    static let swatchCornerRadius: CGFloat = 2
    static let swatchBorderWidth: CGFloat = 0.5
    static let swatchOverflowFontSize: CGFloat = 10
    static let maxVisibleSwatches = 4

    // MARK: - Favorite Button

    static let favoriteIconSize: CGFloat = 16
    static let favoritePadding: CGFloat = 8
}

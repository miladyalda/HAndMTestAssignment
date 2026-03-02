//
//  Constants.swift
//  HAndMTestAssignment
//
//  Created by milad yalda on 2026-03-01.
//

import Foundation

/// Centralized constants used throughout the app.
/// Marked as Sendable since all values are immutable.
enum Constants {

    enum API {
        static let defaultQuery = "jeans"
        static let touchPoint = "ios"
    }

    enum Pricing {
        static let whitePrice = "whitePrice"
        static let yellowPrice = "yellowPrice"
    }
}

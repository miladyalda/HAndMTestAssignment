//
//  Product.swift
//  HAndMTestAssignment
//
//  Created by milad yalda on 2026-03-01.
//

import Foundation

/// Represents a product displayed in the product list.
struct Product: Identifiable {
    let id: String
    let name: String
    let brand: String
    let imageURL: URL?
    let originalPrice: String
    let salePrice: String?
    let swatches: [ColorSwatch]
}

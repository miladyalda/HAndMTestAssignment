//
//  Product.swift
//  HAndMTestAssignment
//
//  Created by milad yalda on 2026-03-01.
//

import Foundation

struct Product: Identifiable {
    let id: String
    let name: String
    let brand: String
    let imageURL: URL?
    let originalPrice: String
    let salePrice: String?
    let swatches: [ColorSwatch]
}

struct ColorSwatch: Identifiable {
    let id: String
    let colorCode: String
    let colorName: String

    var color: String { colorCode }
}

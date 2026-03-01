//
//  ColorSwatch.swift
//  HAndMTestAssignment
//
//  Created by milad yalda on 2026-03-01.
//

import Foundation


/// Represents a color variant of a product.
struct ColorSwatch: Identifiable {
    let id: String
    let colorCode: String
    let colorName: String

    var color: String { colorCode }
}

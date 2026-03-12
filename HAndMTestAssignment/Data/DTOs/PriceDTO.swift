//
//  PriceDTO.swift
//  HAndMTestAssignment
//
//  Created by milad yalda on 2026-03-01.
//

import Foundation

struct PriceDTO: Codable {
    let priceType: PriceType
    let price: Double
    let formattedPrice: String
}

enum PriceType: String, Codable {
    case whitePrice
    case yellowPrice
    case redPrice    // ← Add this
}

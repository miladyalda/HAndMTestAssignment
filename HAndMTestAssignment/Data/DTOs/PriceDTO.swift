//
//  PriceDTO.swift
//  HAndMTestAssignment
//
//  Created by milad yalda on 2026-03-01.
//

import Foundation

struct PriceDTO: Codable {
    let priceType: String
    let price: Double
    let formattedPrice: String
}

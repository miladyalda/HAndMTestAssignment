//
//  ProductDTO.swift
//  HAndMTestAssignment
//
//  Created by milad yalda on 2026-03-01.
//

import Foundation

struct ProductDTO: Codable {
    let id: String
    let productName: String
    let brandName: String
    let prices: [PriceDTO]
    let modelImage: String?
    let productImage: String
    let swatches: [SwatchDTO]
}

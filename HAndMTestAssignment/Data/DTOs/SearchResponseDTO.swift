//
//  SearchResponseDTO.swift
//  HAndMTestAssignment
//
//  Created by milad yalda on 2026-03-01.
//

import Foundation

struct SearchResponseDTO: Codable {
    let searchHits: SearchHitsDTO
    let pagination: PaginationDTO
}

struct SearchHitsDTO: Codable {
    let productList: [ProductDTO]
}

struct PaginationDTO: Codable {
    let currentPage: Int
    let nextPageNum: Int?
    let totalPages: Int
}

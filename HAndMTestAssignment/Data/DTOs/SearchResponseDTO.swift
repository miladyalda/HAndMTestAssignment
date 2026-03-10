//
//  SearchResponseDTO.swift
//  HAndMTestAssignment
//
//  Created by milad yalda on 2026-03-01.
//

import Foundation

nonisolated struct SearchResponseDTO: Codable, Sendable {
    let searchHits: SearchHitsDTO
    let pagination: PaginationDTO
}

nonisolated struct SearchHitsDTO: Codable, Sendable {
    let productList: [ProductDTO]
}

nonisolated struct PaginationDTO: Codable, Sendable {
    let currentPage: Int
    let nextPageNum: Int?
    let totalPages: Int
}

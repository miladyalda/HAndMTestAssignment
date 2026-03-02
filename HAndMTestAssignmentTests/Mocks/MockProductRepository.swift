//
//  MockProductRepository.swift
//  HAndMTestAssignment
//
//  Created by milad yalda on 2026-03-02.
//

import Foundation
@testable import HAndMTestAssignment

final class MockProductRepository: ProductRepositoryProtocol {
    var result: Result<(products: [Product], pagination: PaginationInfo), Error> = .success(([], PaginationInfo(currentPage: 1, nextPage: nil, totalPages: 1)))

    private(set) var fetchCallCount = 0
    private(set) var lastQuery: String?
    private(set) var lastPage: Int?

    func fetchProducts(query: String, page: Int) async throws -> (products: [Product], pagination: PaginationInfo) {
        fetchCallCount += 1
        lastQuery = query
        lastPage = page
        return try result.get()
    }
}

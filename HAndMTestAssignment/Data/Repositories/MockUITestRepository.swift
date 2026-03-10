//
//  MockUITestRepository.swift
//  HAndMTestAssignment
//
//  Created by milad yalda on 2026-03-03.
//

import Foundation

/// Repository that returns mock data for UI testing.
/// Activated via launch arguments.
final class MockUITestRepository: ProductRepositoryProtocol {

    private let scenario: Scenario

    enum Scenario: String {
        case success
        case empty
        case error
        case pagination
    }

    init(scenario: Scenario) {
        self.scenario = scenario
    }

    func fetchProducts(query: String, page: Int) async throws -> (products: [Product], pagination: PaginationInfo) {
        // Simulate network delay
        try await Task.sleep(for: .milliseconds(100))

        switch scenario {
        case .success:
            return (
                products: Self.makeProducts(count: 10, page: page),
                pagination: PaginationInfo(currentPage: page, nextPage: nil, totalPages: 1)
            )
        case .empty:
            return (
                products: [],
                pagination: PaginationInfo(currentPage: 1, nextPage: nil, totalPages: 1)
            )
        case .error:
            throw APIError.networkError(URLError(.notConnectedToInternet))
        case .pagination:
            let hasMore = page < 3
            return (
                products: Self.makeProducts(count: 10, page: page),
                pagination: PaginationInfo(currentPage: page, nextPage: hasMore ? page + 1 : nil, totalPages: 3)
            )
        }
    }

    private static func makeProducts(count: Int, page: Int) -> [Product] {
        (0..<count).map { i in
            let index = (page - 1) * count + i
            return Product(
                id: "product_\(index)",
                name: "Test Jeans \(index)",
                brand: "H&M",
                imageURL: nil,
                originalPrice: "\(299 + index),00 kr.",
                salePrice: i % 3 == 0 ? "\(199 + index),00 kr." : nil,
                swatches: [
                    ColorSwatch(id: "swatch_\(index)", colorCode: "000000", colorName: "Black")
                ]
            )
        }
    }
}

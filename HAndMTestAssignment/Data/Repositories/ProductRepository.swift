//
//  ProductRepository.swift
//  HAndMTestAssignment
//
//  Created by milad yalda on 2026-03-01.
//

import Foundation

/// Protocol defining the data access layer for products.
/// Abstracts the data source from the ViewModel, enabling testability.
protocol ProductRepositoryProtocol {
    /// Fetches products and pagination info for a given search query and page.
    func fetchProducts(query: String, page: Int) async throws -> (products: [Product], pagination: PaginationInfo)
}

/// Concrete implementation that fetches products from the H&M API.
/// Maps DTOs to domain models before returning to the caller.
final class ProductRepository: ProductRepositoryProtocol {
    private let apiClient: APIClientProtocol

    /// - Parameter apiClient: The API client used for network requests. Defaults to `APIClient()`.
    init(apiClient: APIClientProtocol = APIClient()) {
        self.apiClient = apiClient
    }

    func fetchProducts(query: String, page: Int) async throws -> (products: [Product], pagination: PaginationInfo) {
        // Fetch raw DTO from API
        let response: SearchResponseDTO = try await apiClient.fetch(.searchProducts(query: query, page: page))

        // Map DTOs to domain models
        let products = DTOMapper.mapToProducts(from: response)
        let pagination = DTOMapper.mapToPagination(from: response)

        return (products, pagination)
    }
}

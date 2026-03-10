//
//  ProductListViewModel.swift
//  HAndMTestAssignment
//
//  Created by milad yalda on 2026-03-01.
//

import Foundation

/// Manages the state and business logic for the product list screen.
/// Handles pagination, loading states, and error handling.
@MainActor
@Observable
final class ProductListViewModel {
    
    // MARK: - Properties
    
    private(set) var products: [Product] = []
    private(set) var state: ViewState = .idle
    
    // MARK: - Private Properties
    
    private let repository: ProductRepositoryProtocol
    private var pagination: PaginationInfo?
    private var currentPage = 1
    private let query: String
    
    // MARK: - Init
    
    init(repository: ProductRepositoryProtocol, query: String = "jeans") {
        self.repository = repository
        self.query = query
    }
    
    // MARK: - Public Methods
    
    /// Loads the first page of products. Resets any existing data.
    func loadInitialProducts() async {
        guard state == .idle else { return }
        state = .loading
        currentPage = 1
        products = []
        await fetchProducts(page: currentPage)
    }
    
    /// Triggers pagination when the given product becomes visible.
    func onProductAppeared(_ product: Product) async {
        guard shouldLoadMore(for: product) else { return }
        currentPage += 1
        state = .loadingMore
        await fetchProducts(page: currentPage)
    }
    
    /// Retries loading after an error.
    func retry() async {
        state = .idle
        await loadInitialProducts()
    }
    
    /// Refreshes the product list from page 1 (pull-to-refresh).
    func refresh() async {
        currentPage = 1
        pagination = nil
        products = []
        state = .loading
        await fetchProducts(page: currentPage)
    }
    
    // MARK: - Private Methods
    
    /// Determines if more products should be loaded based on the visible product's position.
    private func shouldLoadMore(for product: Product) -> Bool {
        guard let pagination, pagination.hasMorePages else { return false }
        guard state == .loaded else { return false }
        
        // Trigger when 30% from the bottom — gives network time to respond
        let thresholdIndex = Int(Double(products.count) * 0.7)
        guard let productIndex = products.firstIndex(where: { $0.id == product.id }) else { return false }
        
        return productIndex >= thresholdIndex
    }
    
    private func fetchProducts(page: Int) async {
        
        do {
            let result = try await repository.fetchProducts(query: query, page: page)
            pagination = result.pagination
            
            // Filter out products that already exist to prevent duplicate IDs
            let existingIDs = Set(products.map { $0.id })
            let newProducts = result.products.filter { !existingIDs.contains($0.id) }
            products.append(contentsOf: newProducts)
            
            state = products.isEmpty ? .empty : .loaded
            
            // 👉 NEW: Trigger background prefetch for the images we just discovered
            //          prefetchImages(for: newProducts)
            
        } catch {
            if page == 1 {
                state = .error(error.localizedDescription)
            } else {
                currentPage -= 1
                state = .loaded
            }
        }
    }
}

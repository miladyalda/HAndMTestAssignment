//
//  HAndMTestAssignmentTests.swift
//  HAndMTestAssignmentTests
//
//  Created by milad yalda on 2026-03-01.
//

import Testing
@testable import HAndMTestAssignment

@MainActor
struct ProductListViewModelTests {

    // MARK: - Initial Load

    @Test func initialLoadSetsLoadedState() async {
        let mock = MockProductRepository()
        mock.result = .success((
            products: TestData.makeProducts(count: 10),
            pagination: TestData.makePagination()
        ))
        let viewModel = ProductListViewModel(repository: mock)

        await viewModel.loadInitialProducts()

        #expect(viewModel.state == .loaded)
        #expect(viewModel.products.count == 10)
        #expect(mock.fetchCallCount == 1)
    }

    @Test func initialLoadWithEmptyResultSetsEmptyState() async {
        let mock = MockProductRepository()
        mock.result = .success((
            products: [],
            pagination: TestData.makePagination(nextPage: nil, totalPages: 0)
        ))
        let viewModel = ProductListViewModel(repository: mock)

        await viewModel.loadInitialProducts()

        #expect(viewModel.state == .empty)
        #expect(viewModel.products.isEmpty)
    }

    @Test func initialLoadErrorSetsErrorState() async {
        let mock = MockProductRepository()
        mock.result = .failure(APIError.invalidResponse)
        let viewModel = ProductListViewModel(repository: mock)

        await viewModel.loadInitialProducts()

        #expect(viewModel.state == .error("Invalid response from server"))
        #expect(viewModel.products.isEmpty)
    }

    @Test func initialLoadOnlyCalledOnce() async {
        let mock = MockProductRepository()
        mock.result = .success((
            products: TestData.makeProducts(count: 5),
            pagination: TestData.makePagination()
        ))
        let viewModel = ProductListViewModel(repository: mock)

        await viewModel.loadInitialProducts()
        await viewModel.loadInitialProducts()

        #expect(mock.fetchCallCount == 1)
    }

    // MARK: - Pagination

    @Test func paginationLoadsNextPage() async {
        let mock = MockProductRepository()
        mock.result = .success((
            products: TestData.makeProducts(count: 10),
            pagination: TestData.makePagination(currentPage: 1, nextPage: 2)
        ))
        let viewModel = ProductListViewModel(repository: mock)

        await viewModel.loadInitialProducts()

        // Simulate appearing on last product
        let lastProduct = viewModel.products.last!
        await viewModel.onProductAppeared(lastProduct)

        #expect(mock.fetchCallCount == 2)
        #expect(mock.lastPage == 2)
    }

    @Test func paginationStopsAtLastPage() async {
        let mock = MockProductRepository()
        mock.result = .success((
            products: TestData.makeProducts(count: 10),
            pagination: TestData.makePagination(currentPage: 5, nextPage: nil, totalPages: 5)
        ))
        let viewModel = ProductListViewModel(repository: mock)

        await viewModel.loadInitialProducts()

        let lastProduct = viewModel.products.last!
        await viewModel.onProductAppeared(lastProduct)

        #expect(mock.fetchCallCount == 1)
    }

    @Test func paginationErrorPreservesExistingProducts() async {
        let mock = MockProductRepository()
        mock.result = .success((
            products: TestData.makeProducts(count: 10),
            pagination: TestData.makePagination(currentPage: 1, nextPage: 2)
        ))
        let viewModel = ProductListViewModel(repository: mock)

        await viewModel.loadInitialProducts()
        #expect(viewModel.products.count == 10)

        // Next page fails
        mock.result = .failure(APIError.invalidResponse)
        let lastProduct = viewModel.products.last!
        await viewModel.onProductAppeared(lastProduct)

        #expect(viewModel.state == .loaded)
        #expect(viewModel.products.count == 10)
    }

    // MARK: - Retry

    @Test func retryReloadsProducts() async {
        let mock = MockProductRepository()
        mock.result = .failure(APIError.invalidResponse)
        let viewModel = ProductListViewModel(repository: mock)

        await viewModel.loadInitialProducts()
        #expect(viewModel.state == .error("Invalid response from server"))

        mock.result = .success((
            products: TestData.makeProducts(count: 10),
            pagination: TestData.makePagination()
        ))

        await viewModel.retry()

        #expect(viewModel.state == .loaded)
        #expect(viewModel.products.count == 10)
    }

    // MARK: - Duplicate Filtering

    @Test func duplicateProductsAreFiltered() async {
        let mock = MockProductRepository()
        let products = TestData.makeProducts(count: 5)
        mock.result = .success((
            products: products,
            pagination: TestData.makePagination(currentPage: 1, nextPage: 2)
        ))
        let viewModel = ProductListViewModel(repository: mock)

        await viewModel.loadInitialProducts()

        // Second page returns same products
        mock.result = .success((
            products: products,
            pagination: TestData.makePagination(currentPage: 2, nextPage: nil, totalPages: 2)
        ))

        let lastProduct = viewModel.products.last!
        await viewModel.onProductAppeared(lastProduct)

        #expect(viewModel.products.count == 5)
    }
}

//
//  ProductListView.swift
//  HAndMTestAssignment
//
//  Created by milad yalda on 2026-03-02.
//

import SwiftUI

/// Main view displaying a paginated grid of products.
struct ProductListView: View {
    @State private var viewModel = ProductListViewModel(repository: ProductRepository())
    
    /*
    init() {
        let repository: ProductRepositoryProtocol

        if ProcessInfo.processInfo.arguments.contains("-UITest"),
           let scenarioArg = ProcessInfo.processInfo.arguments.dropFirst().first(where: { $0.hasPrefix("-Scenario_") }),
           let scenario = MockUITestRepository.Scenario(rawValue: scenarioArg.replacingOccurrences(of: "-Scenario_", with: "")) {
            repository = MockUITestRepository(scenario: scenario)
        } else {
            repository = ProductRepository()
        }

        _viewModel = State(initialValue: ProductListViewModel(repository: repository))
    }
    */

    private let columns = [
        GridItem(.flexible(), spacing: ProductMetrics.columnSpacing),
        GridItem(.flexible(), spacing: ProductMetrics.columnSpacing)
    ]

    // MARK: - Body

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(ProductStrings.navigationTitle)
                .navigationBarTitleDisplayMode(.inline)
                .task { await viewModel.loadInitialProducts() }
        }
    }

    // MARK: - Content Router

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            loadingView
        case .loaded, .loadingMore:
            productGrid
        case .error(let message):
            StatusView(
                icon: ProductIcons.error,
                message: message,
                actionTitle: ProductStrings.retryButton
            ) {
                Task { await viewModel.retry() }
            }
        case .empty:
            StatusView(icon: ProductIcons.emptySearch, message: ProductStrings.emptyMessage)
        }
    }

    // MARK: - Subviews

    private var loadingView: some View {
        ProgressView(ProductStrings.loadingMessage)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityIdentifier(AccessibilityID.loadingView)

    }

    private var productGrid: some View {
        ScrollView {
            VStack(spacing: 0) {
                productColumns
                paginationSpinner
            }
        }
        .refreshable { await viewModel.refresh() }
        .accessibilityIdentifier(AccessibilityID.productGrid)

    }

    private var productColumns: some View {
        LazyVGrid(columns: columns, spacing: ProductMetrics.rowSpacing) {
            ForEach(viewModel.products) { product in
                ProductCardView(product: product)
                    .onAppear { Task { await viewModel.onProductAppeared(product) } }
            }
        }
        .padding(.horizontal, ProductMetrics.horizontalPadding)
    }

    @ViewBuilder
    private var paginationSpinner: some View {
        if viewModel.state == .loadingMore {
            ProgressView()
                .padding()
                .accessibilityIdentifier(AccessibilityID.paginationSpinner)

        }
    }
}

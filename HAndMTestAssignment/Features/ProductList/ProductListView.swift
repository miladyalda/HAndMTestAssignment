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

    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]

    // MARK: - Body

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Jeans")
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
            StatusView(icon: "exclamationmark.triangle", message: message, actionTitle: "Try Again", action: viewModel.retry)
        case .empty:
            StatusView(icon: "magnifyingglass", message: "No products found")
        }
    }

    // MARK: - Subviews

    private var loadingView: some View {
        ProgressView("Loading products...")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var productGrid: some View {
        ScrollView {
            VStack(spacing: 0) {
                productColumns
                paginationSpinner
            }
        }
    }

    private var productColumns: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(viewModel.products) { product in
                ProductCardView(product: product)
                    .onAppear { Task { await viewModel.onProductAppeared(product) } }
            }
        }
        .padding(.horizontal, 8)
    }

    @ViewBuilder
    private var paginationSpinner: some View {
        if viewModel.state == .loadingMore {
            ProgressView()
                .padding()
        }
    }
}

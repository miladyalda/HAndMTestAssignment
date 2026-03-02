//
//  ContentView.swift
//  HAndMTestAssignment
//
//  Created by milad yalda on 2026-03-01.
//

import SwiftUI

struct ContentView: View {
    
    @State private var viewModel = ProductListViewModel(repository: ProductRepository())
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                Text("State: \(String(describing: viewModel.state))")
                    .font(.headline)
                Text("Products: \(viewModel.products.count)")
                    .font(.subheadline)

                Divider()

                ForEach(viewModel.products) { product in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("🏷 \(product.brand)")
                        Text("👖 \(product.name)")
                        Text("💰 \(product.originalPrice)")
                        if let sale = product.salePrice {
                            Text("🔴 Sale: \(sale)")
                        }
                        Text("🎨 Colors: \(product.swatches.count)")
                        Divider()
                    }
                    .onAppear {
                        Task {
                            await viewModel.onProductAppeared(product)
                        }
                    }
                }

                if viewModel.state == .loadingMore {
                    ProgressView("Loading more...")
                }
            }
            .padding()
        }
        .task {
            await viewModel.loadInitialProducts()
        }
    }
}

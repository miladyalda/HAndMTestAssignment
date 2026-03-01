//
//  ContentView.swift
//  HAndMTestAssignment
//
//  Created by milad yalda on 2026-03-01.
//

import SwiftUI

struct ContentView: View {
    @State private var result: String = "Loading..."

    var body: some View {
        ScrollView {
            Text(result)
                .padding()
        }
        .task {
            await testAPI()
        }
    }

    private func testAPI() async {
        let repository = ProductRepository()
        do {
            let (products, pagination) = try await repository.fetchProducts(query: "jeans", page: 1)

            var output = "✅ Page \(pagination.currentPage) of \(pagination.totalPages)\n"
            output += "Next page: \(pagination.nextPage?.description ?? "none")\n"
            output += "Products: \(products.count)\n\n"

            for product in products {
                output += "---\n"
                output += "🏷 \(product.brand)\n"
                output += "👖 \(product.name)\n"
                output += "💰 \(product.originalPrice)\n"
                if let sale = product.salePrice {
                    output += "🔴 Sale: \(sale)\n"
                }
                output += "🎨 Colors: \(product.swatches.count)\n"
                output += "🖼 Image: \(product.imageURL?.absoluteString ?? "none")\n\n"
            }

            result = output
        } catch {
            result = "❌ Error: \(error.localizedDescription)\n\nDetails: \(error)"
        }
    }
}

//
//  ProductCardView.swift
//  HAndMTestAssignment
//
//  Created by milad yalda on 2026-03-02.
//

import SwiftUI

/// Displays a single product card matching the H&M design.
struct ProductCardView: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            imageSection
            infoSection
            swatchSection
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
    }

    // MARK: - Accessibility

    private var accessibilityDescription: String {
        var description = "\(product.brand), \(product.name), \(product.originalPrice)"
        if let salePrice = product.salePrice {
            description += ", on sale for \(salePrice)"
        }
        if !product.swatches.isEmpty {
            let colorNames = product.swatches.map { $0.colorName }.joined(separator: ", ")
            description += ", available in \(colorNames)"
        }
        return description
    }

    // MARK: - Image Section

    private var imageSection: some View {
        ZStack(alignment: .topTrailing) {
            GeometryReader { geometry in
                CachedAsyncImage(url: product.imageURL)
                    .frame(width: geometry.size.width, height: geometry.size.width * 1.5)
            }
            .aspectRatio(2/3, contentMode: .fit)
            .clipped()

            Button(action: {}) {
                Image(systemName: "heart")
                    .font(.system(size: 16))
                    .foregroundStyle(.primary)
                    .padding(8)
            }
            .accessibilityLabel("Add \(product.name) to favorites")
        }
    }

    // MARK: - Info Section

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(product.brand)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            Text(product.name)
                .font(.caption)
                .fontWeight(.semibold)
                .lineLimit(1)

            priceView
        }
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }

    private var priceView: some View {
        HStack(spacing: 4) {
            if let salePrice = product.salePrice {
                Text(salePrice)
                    .font(.caption)
                    .foregroundStyle(.red)
                Text(product.originalPrice)
                    .font(.caption)
                    .strikethrough()
                    .foregroundStyle(.secondary)
            } else {
                Text(product.originalPrice)
                    .font(.caption)
            }
        }
    }

    // MARK: - Swatch Section

    private var swatchSection: some View {
        HStack(spacing: 4) {
            let visibleSwatches = Array(product.swatches.prefix(4))
            let remaining = product.swatches.count - visibleSwatches.count

            ForEach(visibleSwatches) { swatch in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(hex: swatch.colorCode))
                    .frame(width: 12, height: 12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                    )
            }

            if remaining > 0 {
                Text("+\(remaining)")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityHidden(true)
    }
}

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

    @State private var isFavorite = false

    var body: some View {
        VStack(alignment: .leading, spacing: ProductMetrics.cardContentSpacing) {
            imageSection
            infoSection
            swatchSection
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
    }

    // MARK: - Accessibility

    private var accessibilityDescription: String {
        ProductStrings.productAccessibilityLabel(
            brand: product.brand,
            name: product.name,
            originalPrice: product.originalPrice,
            salePrice: product.salePrice,
            colorNames: product.swatches.map { $0.colorName },
            isFavorite: isFavorite
        )
    }

    // MARK: - Image Section

    private var imageSection: some View {
        ZStack(alignment: .topTrailing) {
            CachedAsyncImage(url: product.imageURL)
                .aspectRatio(ProductMetrics.imageAspectRatio, contentMode: .fill)
                .clipped()

            Button {
                isFavorite.toggle()
            } label: {
                Image(systemName: isFavorite ? ProductIcons.favoriteFilled : ProductIcons.favorite)
                    .font(.system(size: ProductMetrics.favoriteIconSize))
                    .foregroundStyle(isFavorite ? .red : .primary)
                    .padding(ProductMetrics.favoritePadding)
            }
            .accessibilityLabel(isFavorite ? ProductStrings.removeFavorite(product.name) : ProductStrings.addFavorite(product.name))
        }
    }

    // MARK: - Info Section

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: ProductMetrics.cardInfoSpacing) {
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
        HStack(spacing: ProductMetrics.priceSpacing) {
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
        HStack(spacing: ProductMetrics.swatchSpacing) {
            let visibleSwatches = Array(product.swatches.prefix(ProductMetrics.maxVisibleSwatches))
            let remaining = product.swatches.count - visibleSwatches.count

            ForEach(visibleSwatches) { swatch in
                RoundedRectangle(cornerRadius: ProductMetrics.swatchCornerRadius)
                    .fill(Color(hex: swatch.colorCode))
                    .frame(width: ProductMetrics.swatchSize, height: ProductMetrics.swatchSize)
                    .overlay(
                        RoundedRectangle(cornerRadius: ProductMetrics.swatchCornerRadius)
                            .stroke(Color.gray.opacity(0.3), lineWidth: ProductMetrics.swatchBorderWidth)
                    )
            }

            if remaining > 0 {
                Text("+\(remaining)")
                    .font(.system(size: ProductMetrics.swatchOverflowFontSize))
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityHidden(true)
    }
}

//
//  DTOMapper.swift
//  HAndMTestAssignment
//
//  Created by milad yalda on 2026-03-01.
//

import Foundation

/// Maps Data Transfer Objects (DTOs) to Domain models.
/// Keeps the mapping logic centralized and separate from both layers.
enum DTOMapper {

    // MARK: - Product Mapping

    /// Maps a full search response DTO to an array of domain products.
    static func mapToProducts(from dto: SearchResponseDTO) -> [Product] {
        dto.searchHits.productList.map { mapToProduct(from: $0) }
    }

    /// Maps a single product DTO to a domain product.
    /// - Uses `modelImage` as primary image, falls back to `productImage`.
    /// - Extracts original price (whitePrice) and sale price (yellowPrice) if available.
    /// - Limits swatches to first 6 to match the design.
    static func mapToProduct(from dto: ProductDTO) -> Product {
        let imageURLString = dto.modelImage ?? dto.productImage
        let imageURL = URL(string: imageURLString)

        let originalPrice = dto.prices
            .first { $0.priceType == Constants.Pricing.whitePrice }?
            .formattedPrice ?? ""

        let salePrice = dto.prices
            .first { $0.priceType == Constants.Pricing.yellowPrice }?
            .formattedPrice

        let swatches = dto.swatches.prefix(6).map { swatch in
            ColorSwatch(
                id: swatch.colorCode + swatch.colorName,
                colorCode: swatch.colorCode,
                colorName: swatch.colorName
            )
        }

        return Product(
            id: dto.id,
            name: dto.productName,
            brand: dto.brandName,
            imageURL: imageURL,
            originalPrice: originalPrice,
            salePrice: salePrice,
            swatches: swatches
        )
    }

    // MARK: - Pagination Mapping

    /// Maps the search response DTO to domain pagination info.
    static func mapToPagination(from dto: SearchResponseDTO) -> PaginationInfo {
        PaginationInfo(
            currentPage: dto.pagination.currentPage,
            nextPage: dto.pagination.nextPageNum,
            totalPages: dto.pagination.totalPages
        )
    }
}

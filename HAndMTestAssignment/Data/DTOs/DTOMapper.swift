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
     nonisolated static func mapToProducts(from dto: SearchResponseDTO) -> [Product] {
        
        ///If the H&M backend team accidentally sends a single malformed product in a list of 100 items (e.g., a missing required field), your JSONDecoder will currently throw an error and the entire list will fail to load.
        ///
        ///Use a for-in loop with a try? inside it. This way, if one product fails to map, you can skip it and still return the other 99 valid products to the user.
        dto.searchHits.productList.map { mapToProduct(from: $0) }
    }

    /// Maps a single product DTO to a domain product.
    /// - Uses `modelImage` as primary image, falls back to `productImage`.
    /// - Extracts original price (whitePrice) and sale price (yellowPrice) if available.
    /// - Limits swatches to first 6 to match the design.
    nonisolated static func mapToProduct(from dto: ProductDTO) -> Product {
        let imageURLString = dto.modelImage ?? dto.productImage
        
        ///If imageURLString contains a space or a character that isn't URL-legal, URL(string:) will return nil. In your Product model, imageURL is likely an optional URL?.
        ///
        ///
        ///While string concatenation is fast to write, using URLComponents is the "Senior" way because it handles the logic of whether to use a ? or an & for the query parameter and ensures the string is properly percent-encoded.
        let imageURL = URL(string: imageURLString + "?imwidth=\(Constants.Image.thumbnailWidth)")

        let originalPrice = dto.prices
            .first { $0.priceType == .whitePrice }?
            .formattedPrice ?? ""

        let salePrice = dto.prices
            .first { $0.priceType == .yellowPrice }?
            .formattedPrice

        let swatches = dto.swatches.enumerated().map { index, swatch in
            ColorSwatch(
                id: "\(dto.id)_\(swatch.colorCode)_\(index)",
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
    nonisolated static func mapToPagination(from dto: SearchResponseDTO) -> PaginationInfo {
        PaginationInfo(
            currentPage: dto.pagination.currentPage,
            nextPage: dto.pagination.nextPageNum,
            totalPages: dto.pagination.totalPages
        )
    }
}

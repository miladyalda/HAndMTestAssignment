//
//  DTOMapper.swift
//  HAndMTestAssignment
//
//  Created by milad yalda on 2026-03-01.
//

import Foundation

enum DTOMapper {

    static func mapToProducts(from dto: SearchResponseDTO) -> [Product] {
        dto.searchHits.productList.map { mapToProduct(from: $0) }
    }

    static func mapToProduct(from dto: ProductDTO) -> Product {
        let imageURLString = dto.modelImage ?? dto.productImage
        let imageURL = URL(string: imageURLString)

        let originalPrice = dto.prices
            .first { $0.priceType == "whitePrice" }?
            .formattedPrice ?? ""

        let salePrice = dto.prices
            .first { $0.priceType == "yellowPrice" }?
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

    static func mapToPagination(from dto: SearchResponseDTO) -> PaginationInfo {
        PaginationInfo(
            currentPage: dto.pagination.currentPage,
            nextPage: dto.pagination.nextPageNum,
            totalPages: dto.pagination.totalPages
        )
    }
}

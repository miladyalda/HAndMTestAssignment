//
//  DTOMapperTests.swift
//  HAndMTestAssignment
//
//  Created by milad yalda on 2026-03-02.
//

import Foundation
import Testing
@testable import HAndMTestAssignment

struct DTOMapperTests {

    // MARK: - Product Mapping

    @Test func mapsProductDTOToProduct() {
        let dto = ProductDTO(
            id: "123",
            productName: "Wide Jeans",
            brandName: "H&M",
            prices: [
                PriceDTO(priceType: "whitePrice", price: 299.0, formattedPrice: "299,00 kr.")
            ],
            modelImage: "https://example.com/model.jpg",
            productImage: "https://example.com/product.jpg",
            swatches: [
                SwatchDTO(colorCode: "000000", colorName: "Black", productImage: "https://example.com/black.jpg")
            ]
        )

        let product = DTOMapper.mapToProduct(from: dto)

        #expect(product.id == "123")
        #expect(product.name == "Wide Jeans")
        #expect(product.brand == "H&M")
        #expect(product.originalPrice == "299,00 kr.")
        #expect(product.salePrice == nil)
        #expect(product.imageURL?.absoluteString == "https://example.com/model.jpg")
        #expect(product.swatches.count == 1)
    }

    @Test func usesProductImageWhenModelImageIsNil() {
        let dto = ProductDTO(
            id: "123",
            productName: "Jeans",
            brandName: "H&M",
            prices: [],
            modelImage: nil,
            productImage: "https://example.com/product.jpg",
            swatches: []
        )

        let product = DTOMapper.mapToProduct(from: dto)

        #expect(product.imageURL?.absoluteString == "https://example.com/product.jpg")
    }

    @Test func mapsSalePriceCorrectly() {
        let dto = ProductDTO(
            id: "123",
            productName: "Jeans",
            brandName: "H&M",
            prices: [
                PriceDTO(priceType: "whitePrice", price: 399.0, formattedPrice: "399,00 kr."),
                PriceDTO(priceType: "yellowPrice", price: 299.0, formattedPrice: "299,00 kr.")
            ],
            modelImage: nil,
            productImage: "https://example.com/product.jpg",
            swatches: []
        )

        let product = DTOMapper.mapToProduct(from: dto)

        #expect(product.originalPrice == "399,00 kr.")
        #expect(product.salePrice == "299,00 kr.")
    }

    // MARK: - Pagination Mapping

    @Test func mapsPaginationCorrectly() {
        let dto = SearchResponseDTO(
            searchHits: SearchHitsDTO(productList: []),
            pagination: PaginationDTO(currentPage: 3, nextPageNum: 4, totalPages: 10)
        )

        let pagination = DTOMapper.mapToPagination(from: dto)

        #expect(pagination.currentPage == 3)
        #expect(pagination.nextPage == 4)
        #expect(pagination.totalPages == 10)
        #expect(pagination.hasMorePages == true)
    }

    @Test func lastPageHasNoMorePages() {
        let dto = SearchResponseDTO(
            searchHits: SearchHitsDTO(productList: []),
            pagination: PaginationDTO(currentPage: 10, nextPageNum: nil, totalPages: 10)
        )

        let pagination = DTOMapper.mapToPagination(from: dto)

        #expect(pagination.hasMorePages == false)
    }
}

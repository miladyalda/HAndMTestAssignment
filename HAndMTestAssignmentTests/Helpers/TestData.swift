//
//  TestData.swift
//  HAndMTestAssignment
//
//  Created by milad yalda on 2026-03-02.
//

import Foundation
@testable import HAndMTestAssignment

enum TestData {

    static func makeProduct(
        id: String = "123",
        name: String = "Test Jeans",
        brand: String = "H&M",
        originalPrice: String = "299,00 kr.",
        salePrice: String? = nil,
        swatchCount: Int = 2
    ) -> Product {
        Product(
            id: id,
            name: name,
            brand: brand,
            imageURL: URL(string: "https://example.com/image.jpg"),
            originalPrice: originalPrice,
            salePrice: salePrice,
            swatches: (0..<swatchCount).map { i in
                ColorSwatch(id: "\(id)_color_\(i)", colorCode: "000000", colorName: "Black")
            }
        )
    }

    static func makePagination(
        currentPage: Int = 1,
        nextPage: Int? = 2,
        totalPages: Int = 5
    ) -> PaginationInfo {
        PaginationInfo(currentPage: currentPage, nextPage: nextPage, totalPages: totalPages)
    }

    static func makeProducts(count: Int) -> [Product] {
        (0..<count).map { i in
            makeProduct(id: "product_\(i)", name: "Jeans \(i)")
        }
    }
}

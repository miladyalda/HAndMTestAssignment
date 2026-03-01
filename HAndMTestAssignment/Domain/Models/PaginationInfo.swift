//
//  PaginationInfo.swift
//  HAndMTestAssignment
//
//  Created by milad yalda on 2026-03-01.
//

import Foundation

struct PaginationInfo {
    let currentPage: Int
    let nextPage: Int?
    let totalPages: Int

    var hasMorePages: Bool {
        nextPage != nil
    }
}

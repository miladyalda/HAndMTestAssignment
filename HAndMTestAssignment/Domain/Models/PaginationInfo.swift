//
//  PaginationInfo.swift
//  HAndMTestAssignment
//
//  Created by milad yalda on 2026-03-01.
//

import Foundation

/// Represents the pagination state for the current search results.
struct PaginationInfo {
    let currentPage: Int
    let nextPage: Int?
    let totalPages: Int

    var hasMorePages: Bool {
        nextPage != nil
    }
}

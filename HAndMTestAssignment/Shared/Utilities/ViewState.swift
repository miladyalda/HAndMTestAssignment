//
//  ViewState.swift
//  HAndMTestAssignment
//
//  Created by milad yalda on 2026-03-01.
//

/// Represents the possible states of the product list.
enum ViewState: Equatable {
    case idle
    case loading
    case loaded
    case loadingMore
    case error(String)
    case empty
}

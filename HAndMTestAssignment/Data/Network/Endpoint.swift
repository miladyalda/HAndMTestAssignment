//
//  Endpoint.swift
//  HAndMTestAssignment
//
//  Created by milad yalda on 2026-03-01.
//

import Foundation

/// Defines all available API endpoints with fully configurable URL components.
/// Each part of the URL is separated for easy configuration and maintenance.
enum Endpoint {

    // MARK: - URL Configuration

    private static let scheme = "https"
    private static let subdomain = "api"
    private static let domain = "hm.com"
    private static let service = "search-services"
    private static let version = "v1"
    private static let locale = "sv_se"

    // MARK: - Endpoints

    /// Fetches a paginated list of products matching the search query.
    case searchProducts(query: String, page: Int)

    // MARK: - Path

    /// The endpoint-specific path appended after the base URL.
    var path: String {
        switch self {
        case .searchProducts:
            return "/search/resultpage"
        }
    }

    // MARK: - Query Parameters

    /// The query parameters specific to each endpoint.
    var queryItems: [URLQueryItem] {
        switch self {
        case .searchProducts(let query, let page):
            return [
                URLQueryItem(name: "touchPoint", value: Constants.API.touchPoint),
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "page", value: String(page))
            ]
        }
    }

    // MARK: - URL Builder

    /// Constructs the full URL from all components.
    /// Example: https://api.hm.com/search-services/v1/sv_se/search/resultpage?touchPoint=ios&query=jeans&page=1
    var url: URL? {
        var components = URLComponents()
        components.scheme = Self.scheme
        components.host = "\(Self.subdomain).\(Self.domain)"
        components.path = "/\(Self.service)/\(Self.version)/\(Self.locale)\(path)"
        components.queryItems = queryItems
        return components.url
    }
}

//
//  APIError.swift
//  HAndMTestAssignment
//
//  Created by milad yalda on 2026-03-01.
//

import Foundation

/// Represents all possible errors that can occur during API communication.
/// Conforms to `LocalizedError` to provide user-friendly error messages.
enum APIError: LocalizedError {
    /// The constructed URL is invalid.
    case invalidURL
    /// The server returned a non-HTTP response.
    case invalidResponse
    /// The server returned an HTTP error with the given status code.
    case httpError(statusCode: Int)
    /// The response data could not be decoded into the expected model.
    case decodingError(Error)
    /// An unexpected error occurred.
    case unknown(Error)
    /// A network-level error occurred (no internet, timeout, DNS failure, etc.)
    case networkError(URLError)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode):
            return "Server error with status code: \(statusCode)"
        case .decodingError:
            return "Failed to process server response"
        case .unknown(let error):
            return error.localizedDescription
        case .networkError(let error):
            switch error.code {
            case .notConnectedToInternet:
                return "No internet connection. Please check your network."
            case .timedOut:
                return "Request timed out. Please try again."
            default:
                return "Network error. Please try again."
            }
        }
    }
}

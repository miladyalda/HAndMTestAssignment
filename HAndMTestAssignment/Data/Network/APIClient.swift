//
//  APIClient.swift
//  HAndMTestAssignment
//
//  Created by milad yalda on 2026-03-01.
//

import Foundation

/// Protocol defining the API client interface.
/// Enables dependency injection and mock testing.
/// `nonisolated` keeps network off main thread. `Sendable` allows safe use across actors.
nonisolated protocol APIClientProtocol: Sendable {
    /// Fetches and decodes a response from the given endpoint.
    func fetch<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

/// Concrete implementation of the API client using URLSession.
final class APIClient: APIClientProtocol {
    private let session: URLSession

    /// - Parameter session: The URLSession to use for requests. Defaults to `.shared`.
    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetch<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        guard let url = endpoint.url else {
            throw APIError.invalidURL
        }

        // Perform the network request
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(from: url)
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as URLError where error.code == .cancelled {
            throw CancellationError()
        } catch let error as URLError {
            throw APIError.networkError(error)
        } catch {
            throw APIError.unknown(error)
        }
        
        // Validate HTTP response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        // 🔍 DEBUG: Print raw JSON
        print("=== API Response ===")
        print("URL: \(url)")
        print("Status: \(httpResponse.statusCode)")
        if let jsonString = String(data: data, encoding: .utf8) {
            print("JSON: \(jsonString)")
        }
        print("====================")
        
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            print("Top-level keys: \(json.keys)")
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            // Try to decode error response from API
         //   if let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
         //       throw APIError.serverError(message: apiError.errorMessage)
         //   }
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }
        
        // 2. Check data is not empty
        guard !data.isEmpty else {
            throw APIError.emptyResponse
        }

        // 🔍 DEBUG: Print decoding error details
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch let decodingError as DecodingError {
            print("=== Decoding Error ===")
            switch decodingError {
            case .keyNotFound(let key, let context):
                print("Key '\(key.stringValue)' not found: \(context.debugDescription)")
                print("Path: \(context.codingPath.map { $0.stringValue })")
            case .typeMismatch(let type, let context):
                print("Type mismatch for \(type): \(context.debugDescription)")
                print("Path: \(context.codingPath.map { $0.stringValue })")
            case .valueNotFound(let type, let context):
                print("Value not found for \(type): \(context.debugDescription)")
                print("Path: \(context.codingPath.map { $0.stringValue })")
            case .dataCorrupted(let context):
                print("Data corrupted: \(context.debugDescription)")
            @unknown default:
                print("Unknown decoding error: \(decodingError)")
            }
            print("======================")
            throw APIError.decodingError(decodingError)
        } catch {
            throw APIError.decodingError(error)
        }
    }
}

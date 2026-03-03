//
//  APIClient.swift
//  HAndMTestAssignment
//
//  Created by milad yalda on 2026-03-01.
//

import Foundation

/// Protocol defining the API client interface.
/// Enables dependency injection and mock testing.
protocol APIClientProtocol {
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

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        // Decode the response into the expected type
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
}

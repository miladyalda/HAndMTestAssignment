//
//  MockAPIClient.swift
//  HAndMTestAssignment
//
//  Created by milad yalda on 2026-03-02.
//

import Foundation
@testable import HAndMTestAssignment

final class MockAPIClient: APIClientProtocol {
    var data: Any?
    var error: Error?

    func fetch<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        if let error { throw error }
        guard let data = data as? T else {
            throw APIError.decodingError(NSError(domain: "Mock", code: 0))
        }
        return data
    }
}

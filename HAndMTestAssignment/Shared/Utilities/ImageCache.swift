//
//  ImageCache.swift
//  HAndMTestAssignment
//
//  Created by milad yalda on 2026-03-02.
//

import SwiftUI

/// In-memory image cache using NSCache.
/// Automatically evicts images under memory pressure.
final class ImageCache: @unchecked Sendable {
    static let shared = ImageCache()

    private let cache = NSCache<NSString, UIImage>()
    let session: URLSession

    private init() {
        cache.countLimit = 50
        cache.totalCostLimit = 30 * 1024 * 1024

        let config = URLSessionConfiguration.default
        config.httpMaximumConnectionsPerHost = 4
        config.urlCache = URLCache(
            memoryCapacity: 10 * 1024 * 1024,
            diskCapacity: 50 * 1024 * 1024
        )
        session = URLSession(configuration: config)

        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak cache] _ in
            cache?.removeAllObjects()
        }
    }

    func image(for url: URL) -> UIImage? {
        cache.object(forKey: url.absoluteString as NSString)
    }

    func store(_ image: UIImage, for url: URL) {
        let cost = Int(image.size.width * image.size.height * 4)
        cache.setObject(image, forKey: url.absoluteString as NSString, cost: cost)
    }
}

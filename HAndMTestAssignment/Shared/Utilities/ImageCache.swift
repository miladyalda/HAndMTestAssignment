//
//  ImageCache.swift
//  HAndMTestAssignment
//
//  Created by milad yalda on 2026-03-02.
//

import SwiftUI

/// Thread-safe in-memory image cache using actor isolation.
/// Supports task deduplication and automatic eviction under memory pressure.
actor ImageCache {
    static let shared = ImageCache()

    private let cache = NSCache<NSString, UIImage>()
    private var activeTasks: [URL: Task<UIImage?, Never>] = [:]
    let session: URLSession

    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024

        let config = URLSessionConfiguration.default
        config.httpMaximumConnectionsPerHost = 6
        config.urlCache = URLCache(
            memoryCapacity: 20 * 1024 * 1024,
            diskCapacity: 100 * 1024 * 1024
        )
        session = URLSession(configuration: config)

        Task { [weak self] in
            for await _ in NotificationCenter.default.notifications(
                named: UIApplication.didReceiveMemoryWarningNotification
            ) {
                await self?.clearCache()
            }
        }
    }

    // MARK: - Clear Cache

    private func clearCache() {
        cache.removeAllObjects()
        activeTasks.values.forEach { $0.cancel() }
        activeTasks.removeAll()
    }

    // MARK: - Cache Access

    func image(for url: URL) -> UIImage? {
        cache.object(forKey: url.absoluteString as NSString)
    }

    func store(_ image: UIImage, for url: URL) {
        let cost = imageCost(image)
        cache.setObject(image, forKey: url.absoluteString as NSString, cost: cost)
    }

    // MARK: - Loading with Deduplication

    /// Loads an image from cache or network.
    /// Deduplicates in-flight requests for the same URL.
    func loadImage(from url: URL) async -> UIImage? {
        if let cached = image(for: url) {
            return cached
        }

        if let existingTask = activeTasks[url] {
            return await existingTask.value
        }

        let task = Task<UIImage?, Never> {
            do {
                let (data, response) = try await session.data(from: url)
                try Task.checkCancellation()

                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else { return nil }

                guard let image = UIImage(data: data) else { return nil }

                store(image, for: url)
                return image
            } catch is CancellationError {
                return nil
            } catch {
                return nil
            }
        }

        activeTasks[url] = task
        let result = await task.value
        activeTasks.removeValue(forKey: url)

        return result
    }

    // MARK: - Helpers

    private func imageCost(_ image: UIImage) -> Int {
        guard let cgImage = image.cgImage else {
            return Int(image.size.width * image.size.height * 4)
        }
        return cgImage.bytesPerRow * cgImage.height
    }
}

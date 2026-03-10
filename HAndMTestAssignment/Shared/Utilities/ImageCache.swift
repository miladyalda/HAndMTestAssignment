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

    /// Loads an image from cache or network with request deduplication.
    /// - Parameter url: The URL of the image to load.
    /// - Returns: The loaded image, or nil if loading fails.
    /// - Note: Multiple requests for the same URL share a single network call.
    ///         Uses `defer` to ensure cleanup even if task is cancelled.
    func loadImage(from url: URL) async -> UIImage? {
        // 1. Return cached image if available
        if let cached = image(for: url) {
            return cached
        }

        // 2. If already downloading, wait for existing task
        if let existingTask = activeTasks[url] {
            return await existingTask.value
        }

        // 3. Create new download task
        let task = Task<UIImage?, Never> {
            do {
                let (data, response) = try await session.data(from: url)
                try Task.checkCancellation()

                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else { return nil }

                guard let image = UIImage(data: data) else { return nil }

                store(image, for: url)
                return image
            } catch is CancellationError {
                return nil
            } catch {
                return nil
            }
        }

        // 4. Register task for deduplication
        activeTasks[url] = task
        
        // 5. Ensure cleanup runs even if cancelled
        defer { activeTasks.removeValue(forKey: url) }

        // 6. Wait for result and return
        return await task.value
    }

    // MARK: - Helpers

    private func imageCost(_ image: UIImage) -> Int {
        guard let cgImage = image.cgImage else {
            return Int(image.size.width * image.size.height * 4)
        }
        return cgImage.bytesPerRow * cgImage.height
    }
}

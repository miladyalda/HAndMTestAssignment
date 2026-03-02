//
//  CachedAsyncImage.swift
//  HAndMTestAssignment
//
//  Created by milad yalda on 2026-03-02.
//

import SwiftUI

/// A custom async image view with in-memory caching.
/// Loads optimized thumbnails from H&M's CDN and caches them in memory.
struct CachedAsyncImage: View {

    let url: URL?

    @State private var uiImage: UIImage?
    @State private var isLoading = false
    @State private var hasFailed = false
    @State private var attemptID = UUID()

    // MARK: - Body

    var body: some View {
        imageContent
            .animation(.easeIn(duration: 0.15), value: uiImage != nil)
            .task(id: attemptID) { await loadImage() }
            .onAppear {
                loadFromCacheSync()
                retryIfNeeded()
            }
    }

    // MARK: - Views

    @ViewBuilder
    private var imageContent: some View {
        if let uiImage {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.1))
            .overlay {
                if isLoading {
                    ProgressView()
                } else {
                    Image(systemName: "photo")
                        .foregroundStyle(.gray.opacity(0.3))
                        .font(.title2)
                }
            }
    }

    // MARK: - Image Loading

    /// Instantly loads from cache without async overhead.
    /// Prevents placeholder flash when scrolling back to cached images.
    private func loadFromCacheSync() {
        guard uiImage == nil, let url else { return }
        if let cached = ImageCache.shared.image(for: url) {
            uiImage = cached
        }
    }

    /// Retries loading if the previous attempt failed and the cell reappears.
    private func retryIfNeeded() {
        if hasFailed && uiImage == nil {
            hasFailed = false
            attemptID = UUID()
        }
    }

    /// Downloads and caches the image. Server returns pre-sized thumbnails via imwidth parameter.
    private func loadImage() async {
        guard let url, uiImage == nil, !isLoading else { return }

        if let cached = ImageCache.shared.image(for: url) {
            self.uiImage = cached
            return
        }

        isLoading = true

        do {
            let (data, _) = try await ImageCache.shared.session.data(from: url)
            guard !Task.isCancelled else { return }

            if let image = UIImage(data: data) {
                ImageCache.shared.store(image, for: url)
                self.uiImage = image
            }
        } catch {
            hasFailed = true
        }

        isLoading = false
    }
}

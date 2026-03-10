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
    @State private var attemptID = UUID()

    // MARK: - Body

    var body: some View {
        imageContent
            .animation(.easeIn(duration: 0.15), value: uiImage != nil)
            .task(id: attemptID) { await loadImage() }
            .onAppear {
                if uiImage == nil && !isLoading {
                    attemptID = UUID()
                }
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
                    Image(systemName: ProductIcons.imagePlaceholder)
                        .foregroundStyle(.gray.opacity(0.3))
                        .font(.title2)
                }
            }
    }
    
    // MARK: - Image Loading

    /// Loads from cache or downloads via the actor's deduplicating loader.
    private func loadImage() async {
        guard let url, uiImage == nil, !isLoading else { return }

        if let cached = await ImageCache.shared.image(for: url) {
            self.uiImage = cached
            return
        }

        isLoading = true

        if let image = await ImageCache.shared.loadImage(from: url) {
            guard !Task.isCancelled else {
                isLoading = false
                return
            }
            self.uiImage = image
        }

        isLoading = false
    }
}

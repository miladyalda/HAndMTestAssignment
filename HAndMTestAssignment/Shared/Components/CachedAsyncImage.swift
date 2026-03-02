//
//  CachedAsyncImage.swift
//  HAndMTestAssignment
//
//  Created by milad yalda on 2026-03-02.
//

import SwiftUI

/// A custom async image view with in-memory caching and downscaling.
struct CachedAsyncImage: View {

    @Environment(\.displayScale) private var displayScale

    let url: URL?
    var targetWidth: CGFloat = 200

    @State private var uiImage: UIImage?
    @State private var isLoading = false

    // MARK: - Body

    var body: some View {
        imageContent
            .animation(.easeIn(duration: 0.2), value: uiImage != nil)
            .task(id: url) { await loadImage() }
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

    private func loadImage() async {
        guard let url, uiImage == nil else { return }

        if let cached = ImageCache.shared.image(for: url) {
            self.uiImage = cached
            return
        }

        isLoading = true

        do {
            let (data, _) = try await ImageCache.shared.session.data(from: url)
            guard !Task.isCancelled else { return }

            if let image = downsample(data: data, targetWidth: targetWidth, scale: displayScale) {
                ImageCache.shared.store(image, for: url)
                self.uiImage = image
            }
        } catch {
            // Silently fail — placeholder stays visible
        }

        isLoading = false
    }

    // MARK: - Downsampling

    /// Downscales image data to the target width using ImageIO.
    /// Much more memory efficient than decoding the full image first.
    private func downsample(data: Data, targetWidth: CGFloat, scale: CGFloat) -> UIImage? {
        let maxPixelSize = targetWidth * scale

        let options: [CFString: Any] = [
            kCGImageSourceShouldCache: false
        ]

        guard let source = CGImageSourceCreateWithData(data as CFData, options as CFDictionary) else {
            return nil
        }

        let downsampleOptions: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true
        ]

        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, downsampleOptions as CFDictionary) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
}

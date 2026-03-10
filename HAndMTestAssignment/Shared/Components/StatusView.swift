//
//  StatusView.swift
//  HAndMTestAssignment
//
//  Created by milad yalda on 2026-03-02.
//

import SwiftUI

/// Reusable view for displaying status messages with an icon and optional action.
struct StatusView: View {
    let icon: String
    let message: String
    var actionTitle: String?
    var action: (() async -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundStyle(.secondary)

            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if let actionTitle, let action {
                Button(actionTitle) {
                    Task { await action() }
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier(AccessibilityID.retryButton)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

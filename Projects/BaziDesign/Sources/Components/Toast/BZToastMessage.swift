// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

/// 화면 하단 등에 잠깐 띄우는 토스트 메시지. (Figma: Overlay - Toast Message)
public struct BZToastMessage: View {

    // MARK: - Properties

    private let message: String

    // MARK: - Init

    public init(_ message: String) {
        self.message = message
    }

    // MARK: - Body

    public var body: some View {
        HStack(spacing: 8) {
            Image.bazi(.checkIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 16)
            Text(message)
                .baziFont(.small14SB)
                .foregroundStyle(Color.gray800)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(Color.blue200)
        .baziRadius(.medium)
    }
}

// MARK: - Auto-dismiss

extension View {
    /// `isPresented`가 `true`가 되면 `edge` 쪽에 토스트를 띄우고, 2초 뒤 자동으로 내린다.
    public func baziToast(isPresented: Binding<Bool>, message: String, edge: VerticalEdge = .bottom) -> some View {
        overlay(alignment: edge == .top ? .top : .bottom) {
            if isPresented.wrappedValue {
                BZToastMessage(message)
                    .padding(.horizontal, 20)
                    .padding(edge == .top ? .top : .bottom, 20)
                    .allowsHitTesting(false)
                    .zIndex(999)
                    .transition(.opacity.animation(.easeInOut(duration: 0.3)))
                    .task {
                        try? await Task.sleep(for: .seconds(2.0))
                        isPresented.wrappedValue = false
                    }
            }
        }
    }
}

// MARK: - Preview

private struct BZToastMessagePreview: View {
    @State private var isPresented = false

    var body: some View {
        Button("토스트 띄우기") {
            isPresented = true
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .baziToast(isPresented: $isPresented, message: "텍스트")
    }
}

#Preview {
    BZToastMessagePreview()
}

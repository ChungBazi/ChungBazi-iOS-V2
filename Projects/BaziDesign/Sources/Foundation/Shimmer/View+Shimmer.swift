// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

public extension View {
    /// 콘텐츠 모양을 따라 밝은 그라디언트가 흐르는 shimmer(로딩) 효과.
    func baziShimmer() -> some View {
        modifier(BaziShimmerModifier())
    }
}

private struct BaziShimmerModifier: ViewModifier {
    @State private var isAnimating = false

    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { geo in
                    let width = geo.size.width
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0),
                            .init(color: Color.grayWhite.opacity(0.75), location: 0.5),
                            .init(color: .clear, location: 1),
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: width)
                    .offset(x: isAnimating ? width : -width)
                }
            }
            .mask(content)
            .onAppear {
                withAnimation(.linear(duration: 1.3).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
    }
}

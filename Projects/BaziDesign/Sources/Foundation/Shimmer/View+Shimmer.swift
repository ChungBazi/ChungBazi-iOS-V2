// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

public extension View {
    /// 콘텐츠 모양을 따라 밝은 그라디언트가 흐르는 shimmer(로딩) 효과.
    func baziShimmer() -> some View {
        modifier(BaziShimmerModifier())
    }
}

private struct BaziShimmerModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isAnimating = false

    func body(content: Content) -> some View {
        content
            .overlay {
                // 동작 줄이기 설정 시 흐르는 하이라이트를 없애고 정적 스켈레톤만 보여준다.
                if !reduceMotion {
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
            }
            .mask(content)
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.linear(duration: 1.3).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
    }
}

// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

/// Brand/Primary → Blue/50 앵귤러 그라디언트가 회전하는 링 스피너. 전역 로딩 표시에 사용한다.
public struct BZLoadingView: View {

    // MARK: - Properties

    private let size: CGFloat
    private let lineWidth: CGFloat

    @State private var isAnimating = false

    // MARK: - Init

    public init(size: CGFloat = 40, lineWidth: CGFloat = 8) {
        self.size = size
        self.lineWidth = lineWidth
    }

    // MARK: - Body

    public var body: some View {
        Circle()
            // 닫힌 원이 아니라 살짝 잘린 호여야 양 끝이 둥근 캡슐로 보인다.
            .trim(from: 0, to: 0.9)
            .stroke(
                // 그라디언트를 "그려지는 호 구간(0°~324°)"에만 한정해 wrap 이음새를 없앤다.
                AngularGradient(
                    gradient: Gradient(colors: [Color.blue50, Color.bazi(.primary)]),
                    center: .center,
                    startAngle: .degrees(0),
                    endAngle: .degrees(324)
                ),
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
            )
            .frame(width: size, height: size)
            .rotationEffect(.degrees(isAnimating ? 0 : 360))
            .onAppear {
                withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
            .accessibilityLabel("로딩 중")
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.bazi(.bgWhite)
        BZLoadingView()
    }
}

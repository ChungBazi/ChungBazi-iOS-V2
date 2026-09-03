// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import BaziDesign

/// OnboardingStart/OnboardingComplete가 공유하는 "배경 이미지 위 타이틀 + 하단 콘텐츠" 레이아웃.
/// 화면 높이 대비 비율로 상/하단 여백을 잡아서 기기 크기가 달라져도 같은 비율을 유지한다.
struct OnboardingBackgroundLayout<BottomContent: View>: View {

    private static var topInsetRatio: CGFloat { 0.1293 }
    private static var bottomInsetRatio: CGFloat { 0.0443 }

    private let background: BaziImage
    private let title: String
    private let bottomContent: BottomContent

    init(background: BaziImage, title: String, @ViewBuilder bottomContent: () -> BottomContent) {
        self.background = background
        self.title = title
        self.bottomContent = bottomContent()
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.bazi(.primary)
                Image.bazi(background)
                    .resizable()
                    .scaledToFit()
                    .accessibilityHidden(true)
                VStack(spacing: 0) {
                    Text(title)
                        .baziFont(.head24B)
                        .foregroundStyle(Color.grayWhite)
                        .multilineTextAlignment(.center)
                        .padding(.top, proxy.size.height * Self.topInsetRatio)

                    Spacer()

                    bottomContent
                        .padding(.horizontal, 20)
                        .padding(.bottom, proxy.size.height * Self.bottomInsetRatio)
                }
            }
        }
        .ignoresSafeArea()
    }
}

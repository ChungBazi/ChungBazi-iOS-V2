// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import BaziDesign

/// 원본 비율보다 짧은 화면에서는 배경을 위쪽 기준으로 채우고 넘치는 영역을 자른다.
/// 화면 크기와 safe area 처리는 호출하는 레이아웃에서 결정한다.
struct ResponsiveBackground: View {

    private let background: BaziImage
    private let size: CGSize
    private let heightToWidthRatio: CGFloat
    private let shortScreenOffset: CGFloat

    /// 기본 비율은 로그인·온보딩 배경 에셋의 원본 크기(375 × 812pt)를 기준으로 한다.
    /// shortScreenOffset은 짧은 화면에만 적용되며 음수이면 배경이 위로 이동한다.
    init(
        _ background: BaziImage,
        size: CGSize,
        heightToWidthRatio: CGFloat = 812.0 / 375.0,
        shortScreenOffset: CGFloat = 0
    ) {
        self.background = background
        self.size = size
        self.heightToWidthRatio = heightToWidthRatio
        self.shortScreenOffset = shortScreenOffset
    }

    var body: some View {
        let image = Image.bazi(background)
            .resizable()
            .accessibilityHidden(true)

        if size.height < size.width * heightToWidthRatio {
            image
                .scaledToFill()
                .frame(width: size.width, height: size.height, alignment: .top)
                .offset(y: shortScreenOffset)
                .clipped()
        } else {
            image
                .scaledToFit()
        }
    }
}

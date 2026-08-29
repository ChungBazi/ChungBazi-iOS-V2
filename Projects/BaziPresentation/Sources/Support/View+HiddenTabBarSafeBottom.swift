// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI
import UIKit

public extension View {
    /// 탭바 숨김 화면의 ScrollView에 직접 적용. 탭바가 사라져 하단 safe area가 0이 되면 마지막 콘텐츠가
    /// 홈 인디케이터에 가리므로, 부족한 만큼만 하단 패딩을 줘 스크롤 끝을 홈 인디케이터 위에서 멈춘다.
    func hiddenTabBarSafeBottom() -> some View {
        modifier(HiddenTabBarSafeBottom())
    }
}

private struct HiddenTabBarSafeBottom: ViewModifier {
    /// 이 ScrollView가 실제로 받은 하단 safe area(0이면 collapse된 상태).
    @State private var ownBottomInset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            // 배경(안쪽)에서 원본 ScrollView의 하단 inset을 읽는다. 아래 padding은 바깥이라 이 값에 영향 없음.
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .onAppear { ownBottomInset = proxy.safeAreaInsets.bottom }
                        .onChange(of: proxy.safeAreaInsets.bottom) { _, newValue in
                            ownBottomInset = newValue
                        }
                }
            }
            .padding(.bottom, max(0, UIApplication.bz_bottomSafeInset - ownBottomInset))
    }
}

private extension UIApplication {
    /// 홈 인디케이터 높이(=윈도우 하단 safe area). 탭바 유무와 무관한 기기 고정값.
    /// 전환 중 isKeyWindow 판별이 흔들릴 수 있어 모든 윈도우의 최댓값을 쓴다.
    static var bz_bottomSafeInset: CGFloat {
        shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .map(\.safeAreaInsets.bottom)
            .max() ?? 0
    }
}

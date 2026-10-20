// Copyright © 2026 ChungBazi. All rights reserved.

import UIKit

/// 커스텀 네비게이션 바(시스템 back 숨김)를 쓰면 기본 엣지 스와이프 뒤로가기 제스처가 비활성화된다.
/// `interactivePopGestureRecognizer`의 delegate를 되잡아, 커스텀 바 화면에서도 스와이프 뒤로가기를 복구한다.
/// 앱 내 모든 `UINavigationController`(SwiftUI `NavigationStack` 포함)에 전역 적용된다.
extension UINavigationController: @retroactive UIGestureRecognizerDelegate {

    open override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    /// 루트가 아닐 때(스택에 2개 이상)만 스와이프 뒤로가기를 허용한다.
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1
    }
}

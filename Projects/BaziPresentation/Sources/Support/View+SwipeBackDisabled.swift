// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI
import UIKit

public extension View {
    /// NavigationStack의 스와이프 뒤로가기(interactive pop)를 비활성화한다.
    /// 저장되지 않은 변경이 있는 화면(예: 메모)에서 커스텀 뒤로가기 버튼으로만 나가게 해 데이터 유실을 막을 때 쓴다.
    func swipeBackDisabled(_ disabled: Bool = true) -> some View {
        background { SwipeBackGestureController(disabled: disabled) }
    }
}

/// SwiftUI NavigationStack을 떠받치는 UINavigationController의 interactivePopGestureRecognizer를 제어한다.
/// 화면이 사라질 때는 다시 켜서 다른 화면의 스와이프 백을 막지 않는다.
private struct SwipeBackGestureController: UIViewControllerRepresentable {
    let disabled: Bool

    func makeUIViewController(context: Context) -> Controller {
        Controller()
    }

    func updateUIViewController(_ controller: Controller, context: Context) {
        controller.disabled = disabled
        controller.applyState()
    }

    final class Controller: UIViewController {
        var disabled = true

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            applyState()
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        }

        func applyState() {
            navigationController?.interactivePopGestureRecognizer?.isEnabled = !disabled
        }
    }
}

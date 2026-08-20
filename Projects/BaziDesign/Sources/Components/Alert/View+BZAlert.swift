// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

/// `baziAlert`의 확인 버튼 색. 왼쪽 취소 버튼은 항상 `.normal`로 고정되므로,
/// 확인 버튼은 일반 동작(primary)과 파괴적 동작(accent) 둘 중 하나만 고르게 한다.
public enum BZAlertConfirmType {
    case primary
    case accent

    var buttonType: BZButtonType {
        switch self {
        case .primary: return .cta
        case .accent: return .accent
        }
    }
}

public extension View {

    /// 화면 중앙에 `BZAlert`를 딤 처리와 함께 띄우는 커스텀 수정자.
    /// SwiftUI 기본 `.alert()`와 동일한 사용 패턴(`isPresented` 바인딩)을 따른다.
    func baziAlert(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        cancelTitle: String = "취소",
        confirmTitle: String = "확인",
        confirmType: BZAlertConfirmType = .primary,
        onConfirm: @escaping () -> Void
    ) -> some View {
        modifier(
            BZAlertModifier(
                isPresented: isPresented,
                title: title,
                message: message,
                cancelTitle: cancelTitle,
                confirmTitle: confirmTitle,
                confirmType: confirmType,
                onConfirm: onConfirm
            )
        )
    }
}

private struct BZAlertModifier: ViewModifier {

    // MARK: - Properties

    @Binding var isPresented: Bool
    let title: String
    let message: String
    let cancelTitle: String
    let confirmTitle: String
    let confirmType: BZAlertConfirmType
    let onConfirm: () -> Void

    // MARK: - Body

    func body(content: Content) -> some View {
        content.overlay {
            if isPresented {
                ZStack {
                    BZDimOverlay(level: .dim1)
                    BZAlert(
                        title: title,
                        message: message,
                        cancelTitle: cancelTitle,
                        confirmTitle: confirmTitle,
                        confirmType: confirmType.buttonType,
                        onCancel: { isPresented = false },
                        onConfirm: {
                            onConfirm()
                            isPresented = false
                        },
                        onClose: { isPresented = false }
                    )
                    .padding(.horizontal, 40)
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isPresented)
    }
}

// MARK: - Preview

private struct BZAlertModifierPreview: View {
    @State private var isPresented = true

    var body: some View {
        VStack {
            Text("배경 화면")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .baziBackground(.bgGray)
        .baziAlert(
            isPresented: $isPresented,
            title: "모든 알림을 삭제할까요?",
            message: "삭제된 알림은 다시 복구할 수 없어요",
            confirmTitle: "삭제하기",
            confirmType: .accent,
            onConfirm: {}
        )
    }
}

#Preview {
    BZAlertModifierPreview()
}

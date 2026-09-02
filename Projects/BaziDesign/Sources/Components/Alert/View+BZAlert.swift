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
        // 시스템 네비바/툴바는 콘텐츠 위에 그려지므로, 콘텐츠 오버레이 딤으로는 네비바를 덮지 못한다.
        // fullScreenCover + 투명 배경으로 present해 네비바·탭바를 포함한 화면 전체를 딤 처리한다.
        content.fullScreenCover(isPresented: $isPresented) {
            BZAlertPresentation(
                title: title,
                message: message,
                cancelTitle: cancelTitle,
                confirmTitle: confirmTitle,
                confirmType: confirmType,
                onCancel: { isPresented = false },
                onConfirm: {
                    onConfirm()
                    isPresented = false
                }
            )
            .presentationBackground(.clear)
        }
        // 커버 기본 슬라이드를 끄고, 내부(BZAlertPresentation)에서 딤/알럿을 페이드인한다.
        .transaction { $0.disablesAnimations = true }
    }
}

// MARK: - Presentation

/// fullScreenCover로 띄우는 딤 + 알럿. 커버 슬라이드를 끈 대신 여기서 페이드인한다.
private struct BZAlertPresentation: View {

    let title: String
    let message: String
    let cancelTitle: String
    let confirmTitle: String
    let confirmType: BZAlertConfirmType
    let onCancel: () -> Void
    let onConfirm: () -> Void

    @State private var visible = false

    var body: some View {
        ZStack {
            BZDimOverlay(level: .dim1)
            BZAlert(
                title: title,
                message: message,
                cancelTitle: cancelTitle,
                confirmTitle: confirmTitle,
                confirmType: confirmType.buttonType,
                onCancel: onCancel,
                onConfirm: onConfirm,
                onClose: onCancel
            )
            .padding(.horizontal, 40)
        }
        .opacity(visible ? 1 : 0)
        .onAppear { withAnimation(.easeInOut(duration: 0.2)) { visible = true } }
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

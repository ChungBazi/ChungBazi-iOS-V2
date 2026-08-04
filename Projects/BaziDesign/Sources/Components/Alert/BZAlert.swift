// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

/// 중앙 정렬 알림 다이얼로그. (Figma: Overlay - Alert)
/// 확인 버튼의 색은 `confirmType`으로 선택한다 (`.cta` = primary, `.accent` = red400).
public struct BZAlert: View {

    // MARK: - Properties

    private let title: String
    private let message: String
    private let cancelTitle: String
    private let confirmTitle: String
    private let confirmType: BZButtonType
    private let onCancel: () -> Void
    private let onConfirm: () -> Void
    private let onClose: () -> Void

    // MARK: - Init

    public init(
        title: String,
        message: String,
        cancelTitle: String = "취소",
        confirmTitle: String = "확인",
        confirmType: BZButtonType = .cta,
        onCancel: @escaping () -> Void = {},
        onConfirm: @escaping () -> Void,
        onClose: @escaping () -> Void = {}
    ) {
        self.title = title
        self.message = message
        self.cancelTitle = cancelTitle
        self.confirmTitle = confirmTitle
        self.confirmType = confirmType
        self.onCancel = onCancel
        self.onConfirm = onConfirm
        self.onClose = onClose
    }

    // MARK: - Body

    public var body: some View {
        VStack(alignment: .trailing, spacing: 6) {
            closeButton
            VStack(spacing: 18) {
                texts
                buttons
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 20)
        .baziBackground(.bgWhite)
        .baziRadius(.medium)
    }
}

// MARK: - Subviews

extension BZAlert {

    private var closeButton: some View {
        Button(action: onClose) {
            Image(systemName: "xmark")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(Color.gray500)
        }
    }

    private var texts: some View {
        VStack(spacing: 8) {
            Text(title)
                .baziFont(.head18B)
                .foregroundStyle(Color.gray900)
                .multilineTextAlignment(.center)
            Text(message)
                .baziFont(.small14R)
                .foregroundStyle(Color.gray500)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private var buttons: some View {
        HStack(spacing: 12) {
            BZButton(cancelTitle, type: .normal, size: .small, action: onCancel)
            BZButton(confirmTitle, type: confirmType, size: .small, action: onConfirm)
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        BZDimOverlay(level: .dim1)
        VStack(spacing: 20) {
            BZAlert(
                title: "텍스트",
                message: "텍스트",
                onConfirm: {}
            )
            BZAlert(
                title: "정책을 삭제할까요?",
                message: "삭제하면 되돌릴 수 없어요",
                confirmTitle: "삭제",
                confirmType: .accent,
                onConfirm: {}
            )
        }
        .padding(.horizontal, 50)
    }
}

// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

/// 중앙 정렬 알림 다이얼로그. (Figma: Overlay - Alert)
/// 확인 버튼의 색은 `confirmType`으로 선택한다 (`.cta` = primary, `.accent` = red400).
public struct BZAlert: View {

    // MARK: - Properties

    private let title: String
    private let message: String
    private let cancelTitle: String?
    private let confirmTitle: String
    private let confirmType: BZButtonType
    private let showsCloseButton: Bool
    private let onCancel: () -> Void
    private let onConfirm: () -> Void
    private let onClose: () -> Void

    // MARK: - Init

    public init(
        title: String,
        message: String,
        cancelTitle: String? = "취소",
        confirmTitle: String = "확인",
        confirmType: BZButtonType = .cta,
        onCancel: @escaping () -> Void = {},
        onConfirm: @escaping () -> Void,
        onClose: @escaping () -> Void = {},
        showsCloseButton: Bool = true
    ) {
        self.title = title
        self.message = message
        self.cancelTitle = cancelTitle
        self.confirmTitle = confirmTitle
        self.confirmType = confirmType
        self.showsCloseButton = showsCloseButton
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

    @ViewBuilder
    private var closeButton: some View {
        if showsCloseButton {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.gray500)
            }
            .accessibilityLabel("닫기")
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
            if let cancelTitle {
                BZButton(cancelTitle, type: .normal, size: .small, action: onCancel)
            }
            // 버튼이 하나(취소 없음)면 medium으로 키워 알럿 폭을 채운다.
            BZButton(confirmTitle, type: confirmType, size: cancelTitle == nil ? .medium : .small, action: onConfirm)
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
            BZAlert(
                title: "업데이트가 필요해요",
                message: "원활한 이용을 위해 최신 버전으로 업데이트해 주세요",
                cancelTitle: nil,
                confirmTitle: "업데이트하기",
                onConfirm: {},
                showsCloseButton: false
            )
        }
        .padding(.horizontal, 50)
    }
}

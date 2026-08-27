// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

/// 데이터 로드 실패 시 화면 중앙에 띄우는 재시도 뷰. 전역 실패/재시도 공통 UI로 사용한다.
public struct BZRetryView: View {

    // MARK: - Properties

    private let title: String
    private let message: String?
    private let retryTitle: String
    private let onRetry: () -> Void

    // MARK: - Init

    public init(
        title: String = "불러오지 못했어요",
        message: String? = "잠시 후 다시 시도해 주세요",
        retryTitle: String = "다시 시도",
        onRetry: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.retryTitle = retryTitle
        self.onRetry = onRetry
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text(title)
                    .baziFont(.head18B)
                    .foregroundStyle(Color.gray900)
                if let message {
                    Text(message)
                        .baziFont(.small14R)
                        .foregroundStyle(Color.gray500)
                }
            }
            .multilineTextAlignment(.center)

            BZButton(retryTitle, type: .normal, size: .small, action: onRetry)
        }
        .padding(.horizontal, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.bazi(.bgGray)
        BZRetryView(onRetry: {})
    }
}

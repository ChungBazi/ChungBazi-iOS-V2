// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

/// 데이터가 비어 있을 때 보여주는 공통 뷰. 바로(캐릭터) 일러스트 + 안내 메시지.
/// 배치는 호출부가 정한다: 전체화면이면 `.frame(maxHeight: .infinity)`로 감싸 중앙 정렬,
/// 스크롤/배너 아래에 인라인으로 둘 땐 그대로 쓴다.
public struct BZEmptyView: View {

    // MARK: - Properties

    private let message: String

    // MARK: - Init

    public init(message: String) {
        self.message = message
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 16) {
            Image.bazi(.emptyBaro)
                .resizable()
                .scaledToFit()
                .frame(width: 105)
            Text(message)
                .baziFont(.body16SB)
                .foregroundStyle(Color.gray400)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.bazi(.bgGray)
        BZEmptyView(message: "알림이 비어 있어요")
    }
}

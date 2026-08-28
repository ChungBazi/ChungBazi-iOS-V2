// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import BaziDesign

/// 프로필/설정 목록의 공통 행. 제목 + (옵션) chevron + 탭 동작.
/// 가로 패딩은 목록 컨테이너가 담당한다(행 자체는 세로 패딩만 가짐).
struct ProfileRow: View {

    private let title: String
    private let showsChevron: Bool
    private let action: () -> Void

    init(_ title: String, showsChevron: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.showsChevron = showsChevron
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .baziFont(.body16M)
                    .foregroundStyle(Color.gray700)
                Spacer()
                if showsChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.gray600)
                }
            }
            .padding(.vertical, 22)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

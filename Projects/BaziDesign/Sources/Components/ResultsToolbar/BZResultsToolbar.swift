// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

/// 목록 상단의 "N개 (+ 정렬)" 툴바. (검색 결과 화면 스타일 기준)
/// 정렬 버튼은 아이콘 + 라벨(마감순/최신순 등) 형태이며, 배경은 호출부가 필요 시 지정한다.
/// 정렬이 없는 목록(예: 상시모집)은 count-only 이니셜라이저로 갯수만 표시한다.
public struct BZResultsToolbar: View {

    // MARK: - Properties

    private let count: Int
    private let sortTitle: String?
    private let onTapSort: (() -> Void)?

    // MARK: - Init

    /// 갯수 + 정렬 버튼.
    public init(count: Int, sortTitle: String, onTapSort: @escaping () -> Void) {
        self.count = count
        self.sortTitle = sortTitle
        self.onTapSort = onTapSort
    }

    /// 갯수만(정렬 버튼 없음).
    public init(count: Int) {
        self.count = count
        self.sortTitle = nil
        self.onTapSort = nil
    }

    // MARK: - Body

    public var body: some View {
        HStack {
            Text("\(count)개")
            Spacer()
            if let sortTitle, let onTapSort {
                Button(action: onTapSort) {
                    HStack(spacing: 3) {
                        Image(systemName: "arrow.up.arrow.down")
                        Text(sortTitle)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .baziFont(.small14R)
        .foregroundStyle(Color.gray600)
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.bazi(.bgGray)
        BZResultsToolbar(count: 4, sortTitle: "마감순") {}
            .frame(maxHeight: .infinity, alignment: .top)
    }
}

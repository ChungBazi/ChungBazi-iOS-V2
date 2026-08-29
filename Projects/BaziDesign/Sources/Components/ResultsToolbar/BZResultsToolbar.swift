// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

/// 목록 상단의 "N개 + 정렬" 툴바. (검색 결과 화면 스타일 기준)
/// 정렬 버튼은 아이콘 + 라벨(마감순/최신순 등) 형태이며, 배경은 호출부가 필요 시 지정한다.
public struct BZResultsToolbar: View {

    // MARK: - Properties

    private let count: Int
    private let sortTitle: String
    private let onTapSort: () -> Void

    // MARK: - Init

    public init(count: Int, sortTitle: String, onTapSort: @escaping () -> Void) {
        self.count = count
        self.sortTitle = sortTitle
        self.onTapSort = onTapSort
    }

    // MARK: - Body

    public var body: some View {
        HStack {
            Text("\(count)개")
            Spacer()
            Button(action: onTapSort) {
                HStack(spacing: 3) {
                    Image(systemName: "arrow.up.arrow.down")
                    Text(sortTitle)
                }
            }
            .buttonStyle(.plain)
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

// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

/// 가로 스크롤 가능한 텍스트 세그먼트 컨트롤 + 선택된 항목에 대응하는 하단 콘텐츠.
/// 선택된 항목은 굵게+검정, 나머지는 회색으로 표시된다.
public struct BZSegmentControl<Content: View>: View {

    // MARK: - Properties

    private let options: [String]
    @Binding private var selection: String
    private let content: (String) -> Content

    // MARK: - Init

    public init(
        options: [String],
        selection: Binding<String>,
        @ViewBuilder content: @escaping (String) -> Content
    ) {
        self.options = options
        self._selection = selection
        self.content = content
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 0) {
            segmentRow
            content(selection)
        }
    }
}

// MARK: - Subviews

extension BZSegmentControl {

    @ViewBuilder
    private var segmentRow: some View {
        Group {
            if options.count == 5 {
                // 정확히 5개: 스크롤 없이 첫/마지막 라벨은 양옆 20에 붙이고 사이 간격만 균등하게 벌린다.
                HStack(spacing: 0) {
                    ForEach(Array(options.enumerated()), id: \.element) { index, option in
                        segmentItem(option)
                        if index < options.count - 1 {
                            Spacer(minLength: 0)
                        }
                    }
                }
                .padding(.horizontal, 20)
            } else if options.count < 5 {
                // 5개 미만: 스크롤 없이 spacing 19로 좌측 정렬한다.
                HStack(spacing: 19) {
                    ForEach(options, id: \.self) { option in
                        segmentItem(option)
                    }
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                // 6개 이상: 가로 스크롤 + spacing 19.
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 19) {
                        ForEach(options, id: \.self) { option in
                            segmentItem(option)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .frame(height: 52)
    }

    private func segmentItem(_ option: String) -> some View {
        let isSelected = selection == option
        return Button {
            selection = option
        } label: {
            Text(option)
                .baziFont(isSelected ? .small14SB : .small14R)
                .foregroundStyle(isSelected ? Color.grayBlack : Color.gray300)
                // 5개 이하 비스크롤 배치에서 큰 글자로 라벨이 "…" 잘리지 않도록 칸에 맞게 축소.
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(maxHeight: .infinity)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Preview

private struct BZSegmentControlPreview: View {
    private let options = ["전체", "취업·창업", "월세·주거", "공부·성장", "생활지원", "활동·경험"]
    @State private var selection = "전체"

    var body: some View {
        BZSegmentControl(options: options, selection: $selection) { selected in
            VStack {
                Text("\(selected) 콘텐츠")
                    .baziFont(.head22B)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 40)
        }
    }
}

#Preview {
    BZSegmentControlPreview()
}

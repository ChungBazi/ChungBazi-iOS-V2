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

    private var segmentRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 19) {
                ForEach(options, id: \.self) { option in
                    segmentItem(option)
                }
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 44)
        .baziBackground(.bgWhite)
    }

    private func segmentItem(_ option: String) -> some View {
        let isSelected = selection == option
        return Text(option)
            .baziFont(isSelected ? .small14SB : .small14R)
            .foregroundStyle(isSelected ? Color.grayBlack : Color.gray300)
            .onTapGesture { selection = option }
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

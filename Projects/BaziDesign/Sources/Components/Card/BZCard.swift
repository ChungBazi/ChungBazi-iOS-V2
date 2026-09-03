// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

public enum BZCardSize: Equatable {
    case small
    case medium
    case medium2
    case large

    /// `nil`이면 사용 가능한 너비를 꽉 채운다 (medium, medium2).
    var width: CGFloat? {
        switch self {
        case .small: return 234
        case .medium, .medium2: return nil
        case .large: return 293
        }
    }

    var height: CGFloat {
        switch self {
        case .large: return 275
        case .medium, .medium2: return 119
        case .small: return 141
        }
    }

    var titleFont: BaziFont {
        self == .large ? .body16SB : .body15SB
    }
}

/// `BZCard` 우측 상단 액세서리. 기본은 찜하기 별이고, `.memo`를 주면 같은 자리/크기에 메모 아이콘이 뜬다.
/// `.calendarAndMemo`는 마감일 캘린더 추가 아이콘을 메모 왼쪽에 나란히 둔다(캘린더 상세 시트 카드 전용).
public enum BZCardAccessory {
    case like
    case memo(action: () -> Void)
    case calendarAndMemo(onAddCalendar: () -> Void, onMemo: () -> Void)
}

public struct BZCard: View {

    // MARK: - Properties

    private let size: BZCardSize
    private let badgeNumber: Int?
    private let category: String
    private let dDay: String
    private let title: String
    private let viewCount: Int
    private let image: Image?
    private let accessory: BZCardAccessory
    /// 카드 탭(=상세 열기). VoiceOver 요약 요소의 활성화 액션이기도 하다. `nil`이면 열기 없음.
    private let onOpen: (() -> Void)?
    @Binding private var isLiked: Bool

    // MARK: - Init

    public init(
        size: BZCardSize,
        badgeNumber: Int? = nil,
        category: String,
        dDay: String,
        title: String,
        viewCount: Int,
        image: Image? = nil,
        isLiked: Binding<Bool>,
        onOpen: (() -> Void)? = nil,
        accessory: BZCardAccessory = .like
    ) {
        self.size = size
        self.badgeNumber = badgeNumber
        self.category = category
        self.dDay = dDay
        self.title = title
        self.viewCount = viewCount
        self.image = image
        self._isLiked = isLiked
        self.onOpen = onOpen
        self.accessory = accessory
    }

    // MARK: - Body

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                if size == .large {
                    thumbnail
                        .padding(.bottom, 4)
                }
                tagRow
                titleText
            }
            Spacer(minLength: 4)
            viewCountRow
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(width: size.width, height: size.height, alignment: .leading)
        .frame(maxWidth: size.width == nil ? .infinity : nil)
        .baziBackground(.bgWhite)
        .baziRadius(.medium)
        .contentShape(Rectangle())
        .onTapGesture { onOpen?() }
        // 카드 정보는 요약 요소 하나로 읽고(탭=열기), 액세서리 버튼은 개별 포커스로 남긴다.
        .background(cardAccessibilityElement)
        // 요약 요소와 액세서리 버튼이 병합되지 않게 묶는다(요약 먼저, 그다음 각 버튼).
        .accessibilityElement(children: .contain)
    }
}

// MARK: - Accessibility

extension BZCard {

    private var cardAccessibilityLabel: String {
        var parts: [String] = []
        if let badgeNumber { parts.append("\(badgeNumber)위") }
        parts.append(category)
        parts.append(dDay)
        parts.append(title)
        parts.append("조회수 \(viewCount.formatted())회")
        if case .like = accessory, isLiked { parts.append("찜함") }
        return parts.joined(separator: ", ")
    }

    /// 카드 프레임 전체를 덮는 투명 요약 요소. 정보 서브뷰는 숨기고 이 요소 하나로 읽는다.
    /// `onOpen`이 있으면 버튼(활성화 = 열기)으로, 없으면 읽기 전용 텍스트로 노출한다.
    @ViewBuilder
    private var cardAccessibilityElement: some View {
        if let onOpen {
            Color.clear
                .accessibilityElement()
                .accessibilityLabel(cardAccessibilityLabel)
                .accessibilityAddTraits(.isButton)
                .accessibilityAction { onOpen() }
                // 액세서리 버튼(sortPriority 0)보다 먼저 포커스되도록 우선순위를 높인다.
                .accessibilitySortPriority(1)
        } else {
            Color.clear
                .accessibilityElement()
                .accessibilityLabel(cardAccessibilityLabel)
                .accessibilitySortPriority(1)
        }
    }
}

// MARK: - Subviews

extension BZCard {

    private var thumbnail: some View {
        (image ?? Image.bazi(.imagePlaceholder))
            .resizable()
            .scaledToFill()
            .frame(height: 139)
            .frame(maxWidth: .infinity)
            .clipped()
            .baziRadius(.small)
            .accessibilityHidden(true)
    }

    private var tagRow: some View {
        HStack {
            HStack(spacing: 8) {
                if let badgeNumber {
                    BZTag("\(badgeNumber)", type: .green)
                }
                BZTag(category, type: .blue100)
                Text(dDay)
                    .baziFont(.small12SB)
                    .foregroundStyle(dDayColor)
            }
            // 태그·D-day는 카드 요약 요소(cardAccessibilityElement)로 대체해 읽는다.
            .accessibilityHidden(true)
            Spacer(minLength: 8)
            // 단일 버튼(찜/메모)도 요약 요소에 병합되지 않고 개별 포커스되도록 자체 컨테이너로 감싼다.
            accessoryView
                .accessibilityElement(children: .contain)
        }
    }

    private var dDayColor: Color {
        switch dDay {
        case "D-3", "D-2", "D-1", "D-Day":
            return Color.bazi(.accent)
        case "상시":
            return Color.blue800
        default:
            return Color.gray700
        }
    }

    @ViewBuilder
    private var accessoryView: some View {
        switch accessory {
        case .like:
            BZLikeButton(isLiked: $isLiked)

        case .memo(let action):
            iconButton(.memoIcon, label: "메모", action: action)

        case let .calendarAndMemo(onAddCalendar, onMemo):
            HStack(spacing: 20) {
                iconButton(.addCalendarIcon, label: "마감일 캘린더에 추가", action: onAddCalendar)
                iconButton(.memoIcon, label: "메모", action: onMemo)
            }
        }
    }

    private func iconButton(_ image: BaziImage, label: String, size: CGFloat = 24, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image.bazi(image)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    private var titleText: some View {
        // small만 2줄, 나머지는 1줄. 넘치면 말줄임(…)으로 잘린다(Text 기본 tail 트렁케이션).
        Text(title.byCharWrapping)
            .baziFont(size.titleFont)
            .foregroundStyle(Color.grayBlack)
            .lineLimit(size == .small ? 2 : 1)
            .truncationMode(.tail)
            .accessibilityHidden(true)
    }

    private var viewCountRow: some View {
        HStack(spacing: 4) {
            Image.bazi(.eyeIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 14)
            
            Text(viewCount, format: .number)
                .baziFont(.small12R)
        }
        .foregroundStyle(Color.gray400)
        .accessibilityHidden(true)
    }
}

// MARK: - Preview

private struct BZCardPreview: View {
    @State private var isLiked = true

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                BZCard(
                    size: .small,
                    category: "취업·창업",
                    dDay: "D-11",
                    title: "2026 지역특화산업 연계청년 디지털 직무역량 연계청",
                    viewCount: 15200,
                    isLiked: $isLiked
                )
                BZCard(
                    size: .medium,
                    category: "취업·창업",
                    dDay: "D-11",
                    title: "2026 지역특화산업 연계청년 디지털 직무역량 연계청 연계청년 디지털 직무역량 연계...",
                    viewCount: 15200,
                    isLiked: $isLiked
                )
                BZCard(
                    size: .medium2,
                    badgeNumber: 1,
                    category: "취업·창업",
                    dDay: "D-11",
                    title: "2026 지역특화산업 연계청년 디지털 직무역량 연계청 연계청년 디지털 직무역량 연계",
                    viewCount: 15200,
                    isLiked: $isLiked
                )
                BZCard(
                    size: .large,
                    category: "취업·창업",
                    dDay: "D-11",
                    title: "2026 지역특화산업 연계청년 디지털 직무역량 연계청 연계청년 디지털",
                    viewCount: 15200,
                    isLiked: $isLiked
                )
            }
            .padding()
        }
        .baziBackground(.bgGray)
    }
}

#Preview {
    BZCardPreview()
}

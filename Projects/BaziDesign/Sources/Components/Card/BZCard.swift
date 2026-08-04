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
        self == .large ? 297 : 141
    }

//    var contentSpacing: CGFloat {
//        self == .large ? 12 : 8
//    }

    var titleFont: BaziFont {
        self == .large ? .body16SB : .body15SB
    }
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
    @Binding private var isBookmarked: Bool

    // MARK: - Init

    public init(
        size: BZCardSize,
        badgeNumber: Int? = nil,
        category: String,
        dDay: String,
        title: String,
        viewCount: Int,
        image: Image? = nil,
        isBookmarked: Binding<Bool>
    ) {
        self.size = size
        self.badgeNumber = badgeNumber
        self.category = category
        self.dDay = dDay
        self.title = title
        self.viewCount = viewCount
        self.image = image
        self._isBookmarked = isBookmarked
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
            .clipShape(RoundedRectangle(cornerRadius: BaziRadius.small.rawValue, style: .continuous))
    }

    private var tagRow: some View {
        HStack(alignment: .top, spacing: 8) {
            HStack(spacing: 8) {
                if let badgeNumber {
                    BZTag("\(badgeNumber)", type: .green)
                }
                BZTag(category, type: .blue100)
                Text(dDay)
                    .baziFont(.small12SB)
                    .foregroundStyle(Color.gray700)
            }
            Spacer(minLength: 8)
            BZBookmarkButton(isBookmarked: $isBookmarked)
        }
    }

    private var titleText: some View {
        Text(title.byCharWrapping)
            .baziFont(size.titleFont)
            .foregroundStyle(Color.grayBlack)
            .lineLimit(2)
    }

    private var viewCountRow: some View {
        HStack(spacing: 4) {
            Image.bazi(.eyeIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 14)
            
            Text("\(viewCount)")
                .baziFont(.small12R)
        }
        .foregroundStyle(Color.gray400)
    }
}

// MARK: - Preview

private struct BZCardPreview: View {
    @State private var isBookmarked = true

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                BZCard(
                    size: .small,
                    category: "취업·창업",
                    dDay: "D-11",
                    title: "2026 지역특화산업 연계청년 디지털 직무역량 연계청",
                    viewCount: 15200,
                    isBookmarked: $isBookmarked
                )
                BZCard(
                    size: .medium,
                    category: "취업·창업",
                    dDay: "D-11",
                    title: "2026 지역특화산업 연계청년 디지털 직무역량 연계청 연계청년 디지털 직무역량 연계...",
                    viewCount: 15200,
                    isBookmarked: $isBookmarked
                )
                BZCard(
                    size: .medium2,
                    badgeNumber: 1,
                    category: "취업·창업",
                    dDay: "D-11",
                    title: "2026 지역특화산업 연계청년 디지털 직무역량 연계청 연계청년 디지털 직무역량 연계",
                    viewCount: 15200,
                    isBookmarked: $isBookmarked
                )
                BZCard(
                    size: .large,
                    category: "취업·창업",
                    dDay: "D-11",
                    title: "2026 지역특화산업 연계청년 디지털 직무역량 연계청 연계청년 디지털",
                    viewCount: 15200,
                    isBookmarked: $isBookmarked
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

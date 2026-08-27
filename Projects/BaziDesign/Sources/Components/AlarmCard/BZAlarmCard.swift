// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

public enum BZAlarmIconType {
    case bazi
    case policy

    var image: BaziImage {
        switch self {
        case .bazi: return .baziAlarmIcon
        case .policy: return .policyAlarmIcon
        }
    }
}

public struct BZAlarmCard: View {

    // MARK: - Properties

    private let icon: BZAlarmIconType
    private let title: String
    private let message: String
    private let timeAgo: String

    // MARK: - Init

    public init(icon: BZAlarmIconType = .policy, title: String, message: String, timeAgo: String) {
        self.icon = icon
        self.title = title
        self.message = message
        self.timeAgo = timeAgo
    }

    // MARK: - Body

    public var body: some View {
        HStack(alignment: .top, spacing: 12) {
            iconCircle
            texts
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .foregroundStyle(Color.gray600)
                .frame(width: 14)
                .frame(maxHeight: .infinity, alignment: .center)
        }
        .padding(16)
        .baziBackground(.bgWhite)
        .baziRadius(.medium)
    }
}

// MARK: - Subviews

extension BZAlarmCard {

    private var iconCircle: some View {
        Image.bazi(icon.image)
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
            .padding(6)
            .background(Color.blue50)
            .clipShape(Circle())
    }

    private var texts: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .baziFont(.body15SB)
                .foregroundStyle(Color.gray900)
            Text(message)
                .baziFont(.small14R)
                .foregroundStyle(Color.gray700)
            Text(timeAgo)
                .baziFont(.small14R)
                .foregroundStyle(Color.gray400)
        }
    }
}

// MARK: - Delete Swipe Action

extension View {
    /// `List` row 안에서 사용해 오른쪽으로 스와이프하면 삭제 버튼이 드러나게 한다.
    public func baziAlarmCardSwipeToDelete(onDelete: @escaping () -> Void) -> some View {
        swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive, action: onDelete) {
                VStack(spacing: 4) {
                    Image(systemName: "trash")
                    Text("삭제")
                        .baziFont(.small12M)
                }
            }
            .tint(Color.red400)
        }
    }
}

// MARK: - Preview

#Preview {
    List {
        BZAlarmCard(
            title: "찜한 정책 신청 마감이 하루 남았어요",
            message: "바지님이 찜한 정책인 '청년 월세 특별지원 사업' 신청이 내일 마감돼요!",
            timeAgo: "17분전"
        )
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .baziAlarmCardSwipeToDelete { }
    }
    .listStyle(.plain)
    .baziBackground(.bgGray)
}

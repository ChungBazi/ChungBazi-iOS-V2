// Copyright © 2026 ChungBazi. All rights reserved.

import BaziDesign
import BaziDomain

/// 알림 종류. `BZAlarmCard`의 아이콘과 "청바지"/"내 정책" 탭 필터를 결정한다.
public enum NotificationKind: Equatable, Sendable {
    /// 내 정책(찜 등) 관련 알림
    case myPolicy
    /// 청바지(맞춤 추천 등) 알림
    case chungbazi

    public var iconType: BZAlarmIconType {
        switch self {
        case .myPolicy: return .policy
        case .chungbazi: return .bazi
        }
    }

    public var tab: NotificationTab {
        switch self {
        case .myPolicy: return .myPolicy
        case .chungbazi: return .liked
        }
    }

    /// 서버 `category` 문자열 → UI 종류. 알 수 없는 값은 내 정책으로 처리한다.
    init(serverCategory: String) {
        switch serverCategory.uppercased() {
        case "CHUNGBAZI": self = .chungbazi
        case "MY_POLICY": self = .myPolicy
        default: self = .myPolicy
        }
    }
}

/// 알림 목록 화면 상단 필터 탭.
public enum NotificationTab: String, CaseIterable, Equatable, Sendable {
    case all = "전체"
    case liked = "청바지"
    case myPolicy = "내 정책"

    /// 서버 조회에 넘길 category 파라미터. "전체"는 필터 없음(nil).
    public var serverCategory: String? {
        switch self {
        case .all: return nil
        case .liked: return "CHUNGBAZI"
        case .myPolicy: return "MY_POLICY"
        }
    }
}

/// 알림 한 줄(Presentation VO). 서버 category를 UI 종류(`kind`)로 파생한다.
public struct NotificationItemVO: Equatable, Identifiable, Sendable {
    public let id: Int
    public let kind: NotificationKind
    public let title: String
    public let message: String
    public let policyId: Int
    public var isRead: Bool
    public let elapsedTime: String

    public init(
        id: Int,
        kind: NotificationKind,
        title: String,
        message: String,
        policyId: Int,
        isRead: Bool = false,
        elapsedTime: String
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.message = message
        self.policyId = policyId
        self.isRead = isRead
        self.elapsedTime = elapsedTime
    }

    public init(_ entity: NotificationItem) {
        self.init(
            id: entity.id,
            kind: NotificationKind(serverCategory: entity.category),
            title: entity.title,
            message: entity.message,
            policyId: entity.policyId,
            isRead: entity.isRead,
            elapsedTime: entity.elapsedTime
        )
    }
}

// MARK: - Mock

extension NotificationItemVO {

    public static let mockList: [NotificationItemVO] = [
        NotificationItemVO(
            id: 1,
            kind: .myPolicy,
            title: "찜한 정책 신청 마감이 하루 남았어요",
            message: "민재님이 찜한 정책인 '청년 월세 특별지원 사업' 신청이 내일 마감돼요!",
            policyId: 101,
            elapsedTime: "17분전"
        ),
        NotificationItemVO(
            id: 2,
            kind: .chungbazi,
            title: "추천 정책을 확인해보세요",
            message: "민재님 조건에 맞는 정책을 새롭게 가져왔어요!",
            policyId: 102,
            elapsedTime: "22시간전"
        ),
        NotificationItemVO(
            id: 3,
            kind: .myPolicy,
            title: "찜한 정책의 내용이 변경되었어요",
            message: "민재님이 찜한 정책인 '2026 8월 청년 창업 지원사업'의 신청 자격이 변경되었어요!",
            policyId: 103,
            elapsedTime: "어제"
        ),
        NotificationItemVO(
            id: 4,
            kind: .chungbazi,
            title: "새로운 청년 정책이 등록되었어요",
            message: "관심 분야와 관련된 신규 정책 3건이 추가되었어요!",
            policyId: 104,
            elapsedTime: "2일 전"
        ),
    ]
}

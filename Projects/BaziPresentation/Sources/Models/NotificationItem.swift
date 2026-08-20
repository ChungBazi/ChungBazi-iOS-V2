// Copyright © 2026 ChungBazi. All rights reserved.

import BaziDesign

/// 알림 종류. `BZAlarmCard`의 아이콘과 "청바지"/"내 정책" 탭 필터를 결정한다.
public enum NotificationKind: Equatable, Sendable {
    /// 내가 찜한 정책의 마감임박/변경 알림 — "청바지" 탭, 별 아이콘.
    case likedPolicyDeadline
    case likedPolicyChanged
    /// 추천/신규 정책 알림 — "내 정책" 탭, 종 아이콘.
    case recommendation
    case newPolicy

    public var iconType: BZAlarmIconType {
        switch self {
        case .likedPolicyDeadline, .likedPolicyChanged: return .policy
        case .recommendation, .newPolicy: return .bazi
        }
    }

    public var tab: NotificationTab {
        switch self {
        case .likedPolicyDeadline, .likedPolicyChanged: return .liked
        case .recommendation, .newPolicy: return .myPolicy
        }
    }
}

/// 알림 목록 화면(33번) 상단 필터 탭.
public enum NotificationTab: String, CaseIterable, Equatable, Sendable {
    case all = "전체"
    case liked = "청바지"
    case myPolicy = "내 정책"
}

/// 알림 한 줄. `NotificationItemDTO`와 필드를 맞췄다.
public struct NotificationItem: Equatable, Identifiable, Sendable {
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
}

// MARK: - Mock

extension NotificationItem {

    // TODO: BaziDomain의 알림 UseCase가 준비되면 실제 서버 데이터로 교체한다.
    public static let mockList: [NotificationItem] = [
        NotificationItem(
            id: 1,
            kind: .likedPolicyDeadline,
            title: "찜한 정책 신청 마감이 하루 남았어요",
            message: "민재님이 찜한 정책인 '청년 월세 특별지원 사업' 신청이 내일 마감돼요!",
            policyId: 101,
            elapsedTime: "17분전"
        ),
        NotificationItem(
            id: 2,
            kind: .recommendation,
            title: "추천 정책을 확인해보세요",
            message: "민재님 조건에 맞는 정책을 새롭게 가져왔어요!",
            policyId: 102,
            elapsedTime: "22시간전"
        ),
        NotificationItem(
            id: 3,
            kind: .likedPolicyChanged,
            title: "찜한 정책의 내용이 변경되었어요",
            message: "민재님이 찜한 정책인 '2026 8월 청년 창업 지원사업'의 신청 자격이 변경되었어요!",
            policyId: 103,
            elapsedTime: "어제"
        ),
        NotificationItem(
            id: 4,
            kind: .newPolicy,
            title: "새로운 청년 정책이 등록되었어요",
            message: "관심 분야와 관련된 신규 정책 3건이 추가되었어요!",
            policyId: 104,
            elapsedTime: "2일 전"
        ),
    ]
}

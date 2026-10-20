// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import ComposableArchitecture

/// 캘린더 화면(21) 전용 Client. 월별 마감일 + 특정 날짜의 마감 정책을 담당한다.
@DependencyClient
public struct CalendarClient: Sendable {
    /// 특정 달의 마감일들(캘린더 인디케이터용). 타임존 없는 달력 날짜(연·월·일)로 반환한다.
    public var fetchCalendar: @Sendable (_ targetMonth: String) async throws -> [DateComponents]
    /// 특정 마감일의 정책 목록(정렬·페이지네이션 없음, 총개수 포함).
    public var fetchDeadlineDate: @Sendable (_ targetDate: String) async throws -> PolicyPageVO
    /// 정책 마감일을 기기 캘린더(EventKit)에 종일 이벤트로 추가한다.
    /// `policyId`는 이벤트에 심을 정책 상세 딥링크 구성에 쓰인다.
    public var addDeadline: @Sendable (_ policyId: Int, _ title: String, _ date: Date) async throws -> Void
}

extension CalendarClient: TestDependencyKey {
    public static let testValue = CalendarClient()

    public static let previewValue = CalendarClient(
        fetchCalendar: { _ in [] },
        fetchDeadlineDate: { _ in
            let items = Array(PolicySummaryVO.mockList.prefix(3))
            return PolicyPageVO(
                policies: IdentifiedArray(uniqueElements: items),
                nextCursor: nil,
                hasNext: false,
                totalCount: items.count
            )
        },
        addDeadline: { _, _, _ in }
    )
}

extension DependencyValues {
    public var calendarClient: CalendarClient {
        get { self[CalendarClient.self] }
        set { self[CalendarClient.self] = newValue }
    }
}

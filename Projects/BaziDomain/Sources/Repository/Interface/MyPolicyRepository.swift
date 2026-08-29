// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 내 정책 플로우(메인·전체보기·캘린더·메모) 데이터 통신을 담당한다.
public protocol MyPolicyRepository: Sendable {
    /// 전체보기: 찜한 정책 목록(분야 필터 + 정렬 + 커서 페이지네이션).
    func fetchMyPolicies(category: PolicyCategory?, sort: String, cursor: String?, size: Int) async throws -> PolicyPage
    /// 상시모집 목록(정렬 없음, 커서 페이지네이션).
    func fetchOpenEndedPolicies(cursor: String?, size: Int) async throws -> PolicyPage
    /// 메인 상단 티저: 마감이 다가오는 찜한 정책.
    func fetchDeadlineTeaser() async throws -> [PolicySummary]
    /// 특정 마감일의 정책 목록(정렬 + 커서 페이지네이션).
    func fetchDeadlineDatePolicies(targetDate: String, sort: String, cursor: String?, size: Int) async throws -> PolicyPage
    /// 특정 달의 마감일들(캘린더 인디케이터용).
    func fetchCalendar(targetMonth: String) async throws -> [Date]
    /// 정책 메모 조회.
    func fetchMemo(policyId: Int) async throws -> PolicyMemo
    /// 정책 메모 작성/수정.
    func updateMemo(policyId: Int, memo: String) async throws
}

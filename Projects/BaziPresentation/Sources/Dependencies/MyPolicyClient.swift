// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

/// 내 정책 메인 화면(19) 전용 Client. 마감 티저 + 선택일 정책 + 상시모집을 담당한다.
@DependencyClient
public struct MyPolicyClient: Sendable {
    /// 상단 티저: 마감이 다가오는 찜한 정책.
    public var fetchDeadlineTeaser: @Sendable () async throws -> [PolicySummaryVO]
    /// 정책 탭: 선택한 날짜의 마감 정책(정렬 + 커서 페이지네이션).
    public var fetchDeadlineDate: @Sendable (_ targetDate: String, _ sort: String, _ cursor: String?, _ size: Int) async throws -> PolicyPageVO
    /// 상시모집 탭: 상시모집 정책(정렬 없음, 커서 페이지네이션).
    public var fetchOpenEnded: @Sendable (_ cursor: String?, _ size: Int) async throws -> PolicyPageVO
}

extension MyPolicyClient: TestDependencyKey {
    public static let testValue = MyPolicyClient()

    public static let previewValue = MyPolicyClient(
        fetchDeadlineTeaser: { Array(PolicySummaryVO.mockList.prefix(2)) },
        fetchDeadlineDate: { _, _, _, _ in
            let items = Array(PolicySummaryVO.mockList.prefix(3))
            return PolicyPageVO(
                policies: IdentifiedArray(uniqueElements: items),
                nextCursor: nil,
                hasNext: false,
                totalCount: items.count
            )
        },
        fetchOpenEnded: { _, _ in
            PolicyPageVO(
                policies: IdentifiedArray(uniqueElements: PolicySummaryVO.mockList),
                nextCursor: nil,
                hasNext: false,
                totalCount: PolicySummaryVO.mockList.count
            )
        }
    )
}

extension DependencyValues {
    public var myPolicyClient: MyPolicyClient {
        get { self[MyPolicyClient.self] }
        set { self[MyPolicyClient.self] = newValue }
    }
}

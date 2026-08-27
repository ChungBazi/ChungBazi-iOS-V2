// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

/// 맞춤정책 더보기(플립카드) 화면 전용 Client. 정책 카드뉴스 상세를 조회한다.
@DependencyClient
public struct CustomPolicyClient: Sendable {
    public var fetchCard: @Sendable (_ policyId: Int) async throws -> PolicyCardVO
    /// 맞춤정책 가이드 오버레이를 본 적 있는지(앱 삭제 전까지 유지).
    public var hasSeenGuide: @Sendable () -> Bool = { false }
    public var markGuideSeen: @Sendable () -> Void
    /// 현재 기기/OS에서 AI 요약이 가능한지(뒷면 로딩 표시 여부 판단용).
    public var isAISummaryAvailable: @Sendable () -> Bool = { false }
    /// 지원 내용을 온디바이스 AI로 요약. 불가/실패 시 nil(원문 fallback).
    public var summarize: @Sendable (_ supportContent: String) async -> String? = { _ in nil }
}

extension CustomPolicyClient: TestDependencyKey {
    public static let testValue = CustomPolicyClient()

    public static let previewValue = CustomPolicyClient(
        fetchCard: { _ in .mock },
        hasSeenGuide: { false },
        markGuideSeen: {},
        isAISummaryAvailable: { false },
        summarize: { _ in nil }
    )
}

extension DependencyValues {
    public var customPolicyClient: CustomPolicyClient {
        get { self[CustomPolicyClient.self] }
        set { self[CustomPolicyClient.self] = newValue }
    }
}

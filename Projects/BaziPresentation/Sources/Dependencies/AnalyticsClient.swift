// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

@DependencyClient
public struct AnalyticsClient: Sendable {
    public var track: @Sendable (AnalyticsEvent) -> Void = { _ in }
}

extension AnalyticsClient: TestDependencyKey {
    // 분석은 fire-and-forget 부수효과라 테스트/프리뷰에선 no-op으로 둔다.
    public static let testValue = AnalyticsClient(track: { _ in })
    public static let previewValue = AnalyticsClient(track: { _ in })
}

extension DependencyValues {
    public var analytics: AnalyticsClient {
        get { self[AnalyticsClient.self] }
        set { self[AnalyticsClient.self] = newValue }
    }
}

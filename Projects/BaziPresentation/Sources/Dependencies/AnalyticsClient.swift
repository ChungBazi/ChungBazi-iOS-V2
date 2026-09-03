// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

@DependencyClient
public struct AnalyticsClient: Sendable {
    public var track: @Sendable (AnalyticsEvent) -> Void = { _ in }
}

extension AnalyticsClient: TestDependencyKey {
    public static let testValue = AnalyticsClient()
    public static let previewValue = AnalyticsClient()
}

extension DependencyValues {
    public var analytics: AnalyticsClient {
        get { self[AnalyticsClient.self] }
        set { self[AnalyticsClient.self] = newValue }
    }
}

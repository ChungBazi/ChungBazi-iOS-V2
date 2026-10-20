// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziPresentation

extension AnalyticsClient: @retroactive DependencyKey {
    public static let liveValue = AnalyticsClient(
        track: { event in
            AppDependencies.amplitude.track(eventType: event.name, eventProperties: event.properties)
        }
    )
}

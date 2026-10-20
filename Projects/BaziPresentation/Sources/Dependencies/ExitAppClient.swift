// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import ComposableArchitecture

/// 앱 강제 종료(점검 알럿 확인 시). 테스트에서 spy로 대체 가능하도록 의존성으로 분리한다.
public enum ExitAppKey: DependencyKey {
    public static let liveValue: @Sendable () -> Void = { exit(0) }
    public static let testValue: @Sendable () -> Void = {}
}

extension DependencyValues {
    public var exitApp: @Sendable () -> Void {
        get { self[ExitAppKey.self] }
        set { self[ExitAppKey.self] = newValue }
    }
}

// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation
import FirebaseRemoteConfig

import BaziDomain

/// Firebase RemoteConfig 래핑. 인앱 기본값을 콘솔값과 동일하게 세팅해 최초 실행/오프라인에서도 안전하다.
/// `fetchAndActivate`는 `minimumFetchInterval` 스로틀을 따르고, `currentConfig`는 활성값을 로컬로 읽는다.
public final class RemoteConfigServiceImpl: RemoteConfigService, @unchecked Sendable {

    private let remoteConfig: RemoteConfig

    public init() {
        remoteConfig = RemoteConfig.remoteConfig()

        let settings = RemoteConfigSettings()
        #if DEBUG
        settings.minimumFetchInterval = 0
        #else
        settings.minimumFetchInterval = 600 // 10분: 점검/강제업데이트 전파 지연 최소화
        #endif
        remoteConfig.configSettings = settings

        remoteConfig.setDefaults([
            "is_server_check": false as NSObject,
            "latest_version": "2.0.0" as NSObject,
            "minimum_version": "2.0.0" as NSObject,
            "server_check_message": "안정적인 서비스 제공을 위해 시스템 점검 중입니다." as NSObject,
        ])
    }

    public func fetchAndActivate() async throws {
        _ = try await remoteConfig.fetchAndActivate()
    }

    public func currentConfig() -> AppConfig {
        AppConfig(
            isServerCheck: remoteConfig["is_server_check"].boolValue,
            minimumVersion: remoteConfig["minimum_version"].stringValue,
            latestVersion: remoteConfig["latest_version"].stringValue,
            serverCheckMessage: remoteConfig["server_check_message"].stringValue
        )
    }
}

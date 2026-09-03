// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import AmplitudeSwift
import ComposableArchitecture

import BaziCore
import BaziData
import BaziDomain
import BaziNetwork
import BaziPresentation
import BaziStorage

/// Composition Root(`ChungBazi`)에서 공유해야만 하는 인스턴스만 모아둔다.
///
/// - `networkProvider`: 내부 `TokenRefreshInterceptor`가 토큰 재발급 진행 상태를 락으로
///   추적한다. Repository마다 따로 만들면 동시에 401을 받았을 때 각자 독립적으로 재발급을
///   시도해 경합이 생기므로, 앱 전체에서 반드시 하나만 공유해야 한다.
/// - `pushTokenRepository`: `AppDelegate`(Composition Root 바깥의 소비자)가 FCM 토큰을
///   저장할 때 써야 하는데, `AppDelegate`가 `BaziData`/`BaziStorage`를 직접 import하게
///   만들지 않기 위해 여기서 미리 조립해 Domain 인터페이스로만 노출한다.
enum AppDependencies {
    static let networkProvider = NetworkProvider(tokenStorage: KeychainTokenStorage())
    static let pushTokenRepository: any PushTokenRepository = PushTokenRepositoryImpl(storage: UserDefaultsStorage())

    /// RemoteConfig(점검/버전) 공유 인스턴스. Splash·Profile이 같은 활성값을 읽도록 한 번만 조립한다.
    static let remoteConfigService: any RemoteConfigService = RemoteConfigServiceImpl()

    /// Amplitude 분석 SDK 공유 인스턴스. 초기화 시 세션 자동 수집을 시작한다.
    static let amplitude = Amplitude(configuration: Configuration(apiKey: Config.amplitudeAPIKey))

    /// 홈 aggregate 인메모리 캐시(5분 TTL)와 그것을 공유하는 HomeRepository.
    /// 홈 플로우의 여러 Client(홈/분야별/랭킹/맞춤)가 같은 Repository·캐시를 쓰도록 여기서 한 번만 조립한다.
    static let policyCache = PolicyCache()
    static let homeRepository: any HomeRepository = HomeRepositoryImpl(
        networkProvider: networkProvider,
        cache: policyCache
    )

    /// 로그아웃/탈퇴 시 사용자 범위 인메모리 캐시를 비운다(재로그인 시 이전 계정 데이터 노출 방지).
    static func clearUserScopedCaches() async {
        await policyCache.clear()
        @Shared(.likeOverrides) var likeOverrides = [Int: Bool]()
        $likeOverrides.withLock { $0.removeAll() }
    }
}

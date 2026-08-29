// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct WithdrawUseCaseImpl: WithdrawUseCase {

    private let userRepository: UserRepository
    private let kakaoAuthService: KakaoAuthService
    private let sessionStateRepository: SessionStateRepository

    public init(
        userRepository: UserRepository,
        kakaoAuthService: KakaoAuthService,
        sessionStateRepository: SessionStateRepository
    ) {
        self.userRepository = userRepository
        self.kakaoAuthService = kakaoAuthService
        self.sessionStateRepository = sessionStateRepository
    }

    public func execute(_ request: WithdrawRequest) async throws {
        // 서버 탈퇴가 성공해야 진행한다. (Apple revoke는 서버가 처리)
        try await userRepository.withdraw(request)
        // 카카오로 로그인한 계정만 앱↔카카오 연결 해제. 서버 탈퇴는 이미 완료됐으므로 실패해도 무시(best-effort).
        if sessionStateRepository.socialType == .kakao {
            try? await kakaoAuthService.unlink()
        }
    }
}

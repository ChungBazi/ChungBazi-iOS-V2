// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziDomain

@DependencyClient
public struct WithdrawClient: Sendable {
    /// 회원 탈퇴(카카오 계정이면 연결 해제). 서버 실패 시 throw.
    public var withdraw: @Sendable (_ request: WithdrawRequest) async throws -> Void
}

extension WithdrawClient: TestDependencyKey {
    public static let testValue = WithdrawClient()

    public static let previewValue = WithdrawClient(withdraw: { _ in })
}

extension DependencyValues {
    public var withdrawClient: WithdrawClient {
        get { self[WithdrawClient.self] }
        set { self[WithdrawClient.self] = newValue }
    }
}

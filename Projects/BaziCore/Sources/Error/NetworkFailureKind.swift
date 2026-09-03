// Copyright © 2026 ChungBazi. All rights reserved.

/// 네트워크 실패의 계층-중립 분류.
///
/// Network 계층(`NetworkError`)이 자기 에러를 이 값으로 노출하고, 상위(Domain의 `UseCaseError`)가
/// 이를 읽어 사용자 메시지로 변환한다. Network·Domain은 서로 import하지 않으므로(형제 레이어),
/// 둘이 공통으로 의존하는 Core에 분류 어휘를 둔다.
public enum NetworkFailureKind: Equatable, Sendable {
    /// 인터넷 연결 없음.
    case offline
    /// 요청 시간 초과.
    case timeout
    /// 인증 만료(401, 재발급까지 실패).
    case unauthorized
    /// 서버 비즈니스 에러. 서버가 내려준 code/message를 그대로 담는다.
    case server(code: String, message: String)
    /// 응답 디코딩 실패(주로 개발 단계 버그).
    case decoding
    /// 위로 분류되지 않는 그 외 실패.
    case other
}

/// 자신을 `NetworkFailureKind`로 분류할 수 있는 에러.
/// 상위 계층은 구체 에러 타입을 몰라도 이 프로토콜로 분류를 읽는다.
public protocol NetworkFailureClassifiable: Error {
    var failureKind: NetworkFailureKind { get }
}

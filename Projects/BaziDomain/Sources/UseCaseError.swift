// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziCore

/// 유즈케이스/서비스 실패의 도메인 표현.
/// 하위 계층(`NetworkError` 등)의 분류(`NetworkFailureKind`)를 사용자 의미의 케이스로 옮긴다.
public enum UseCaseError: Error, Equatable {
    /// 인터넷 연결 없음.
    case offline
    /// 요청 시간 초과.
    case timeout
    /// 인증 만료(재발급까지 실패) → 재로그인 유도.
    case unauthorized
    /// 서버 비즈니스 에러. 서버가 내려준 code/message를 담는다.
    case server(code: String, message: String)
    /// 사용자 취소(소셜 로그인 등). 보통 오류로 표시하지 않는다.
    case cancelled
    /// 앱이 직접 만든 사용자용 메시지(예: 카카오톡 미설치).
    case message(String)
    /// 그 외 분류되지 않는 실패.
    case unknown

    public static func map(_ error: Error) -> UseCaseError {
        if let error = error as? UseCaseError { return error }
        if error is CancellationError { return .cancelled }
        // Network 등 하위 계층 에러는 분류(NetworkFailureKind)만 읽어 도메인 케이스로 옮긴다.
        if let classifiable = error as? NetworkFailureClassifiable {
            switch classifiable.failureKind {
            case .offline:                       return .offline
            case .timeout:                       return .timeout
            case .unauthorized:                  return .unauthorized
            case .server(let code, let message): return .server(code: code, message: message)
            case .decoding, .other:              return .unknown
            }
        }
        return .unknown
    }
}

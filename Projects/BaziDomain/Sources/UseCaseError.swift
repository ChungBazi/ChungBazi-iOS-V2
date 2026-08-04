// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

// TODO: 지금은 모든 실패를 매핑하는 범용 에러다.
// 실제 에러 처리를 붙일 때 케이스별(네트워크 세부 사유, 소셜 로그인 실패, 유효성 실패 등)로 세분화할 것.
public enum UseCaseError: Error, Equatable {
    case cancelled
    case network
    case unknown(String)

    public static func map(_ error: Error) -> UseCaseError {
        if let error = error as? UseCaseError { return error }
        return .unknown(error.localizedDescription)
    }
}

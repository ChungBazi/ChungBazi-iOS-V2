// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// `/auth/reissue` 실패 응답을 확정적 인증 실패(401/404)와 그 외 일시적 실패로 분류한다.
/// 확정적 인증 실패만 강제 로그아웃 대상이고, 나머지(5xx·decode 실패 등)는 세션을 유지한 채 재시도 가능한 오류로 다룬다.
enum ReissueFailureClassifier {
    private static let decoder = JSONDecoder()

    static func classify(statusCode: Int, data: Data) -> NetworkError {
        switch statusCode {
        case 401, 404:
            return .unauthorized
        default:
            if let envelope = try? decoder.decode(ErrorEnvelope.self, from: data) {
                return .serverError(code: envelope.code, message: envelope.message)
            }
            return .unknown(NSError(domain: "TokenReissuer", code: statusCode))
        }
    }
}

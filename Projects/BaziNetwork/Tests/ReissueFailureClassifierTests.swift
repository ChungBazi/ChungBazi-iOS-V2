// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation
import Testing

@testable import BaziNetwork

struct ReissueFailureClassifierTests {

    @Test("401은 확정적 인증 실패로 분류된다")
    func classify_401_isUnauthorized() {
        let result = ReissueFailureClassifier.classify(statusCode: 401, data: Data())

        guard case .unauthorized = result else {
            Issue.record("Expected .unauthorized, got \(result)")
            return
        }
    }

    @Test("404(저장된 refresh token 불일치)는 확정적 인증 실패로 분류된다")
    func classify_404_isUnauthorized() {
        let result = ReissueFailureClassifier.classify(statusCode: 404, data: Data())

        guard case .unauthorized = result else {
            Issue.record("Expected .unauthorized, got \(result)")
            return
        }
    }

    @Test("5xx는 인증 실패가 아니라 서버 오류로 분류된다")
    func classify_5xx_isNotUnauthorized() {
        let result = ReissueFailureClassifier.classify(statusCode: 503, data: Data())

        if case .unauthorized = result {
            Issue.record("5xx should not classify as .unauthorized, got \(result)")
        }
    }

    @Test("5xx 응답 바디에 code/message가 있으면 serverError로 분류된다")
    func classify_5xx_withBody_isServerError() {
        let body = #"{"code":"COMMON500","message":"일시적인 서버 오류입니다."}"#.data(using: .utf8)!
        let result = ReissueFailureClassifier.classify(statusCode: 500, data: body)

        guard case let .serverError(code, message) = result else {
            Issue.record("Expected .serverError, got \(result)")
            return
        }
        #expect(code == "COMMON500")
        #expect(message == "일시적인 서버 오류입니다.")
    }
}

struct NetworkErrorForceLogoutTests {

    @Test("unauthorized는 강제 로그아웃 대상이다")
    func unauthorized_requiresForceLogout() {
        #expect(NetworkError.unauthorized.requiresForceLogout)
    }

    @Test("offline/timeout/serverError/unknown/decodingError는 강제 로그아웃 대상이 아니다")
    func nonUnauthorized_doesNotRequireForceLogout() {
        #expect(!NetworkError.offline.requiresForceLogout)
        #expect(!NetworkError.timeout.requiresForceLogout)
        #expect(!NetworkError.serverError(code: "X", message: "m").requiresForceLogout)
        #expect(!NetworkError.unknown(NSError(domain: "test", code: -1)).requiresForceLogout)
        #expect(!NetworkError.decodingError(NSError(domain: "test", code: -1)).requiresForceLogout)
    }
}

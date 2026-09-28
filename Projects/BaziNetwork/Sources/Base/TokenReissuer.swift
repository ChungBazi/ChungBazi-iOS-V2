// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziCore

/// refresh token으로 새 access/refresh token을 발급받는다. 테스트에서 성공·401·404·5xx·timeout·지연을 제어하기 위해 분리했다.
public protocol TokenReissuer: Sendable {
    func reissue(refreshToken: String) async throws -> ReissueResponseDTO
}

// MoyaProvider/Session을 거치지 않고 URLSession 직접 호출
// → 같은 interceptor를 통하면 401 → retry → 401 → retry 무한루프 발생
public struct URLSessionTokenReissuer: TokenReissuer {

    public init() {}

    public func reissue(refreshToken: String) async throws -> ReissueResponseDTO {
        let url = APIDomain.authURL.appendingPathComponent("reissue")
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // 서버 계약: refreshToken은 body로만 받는다. Authorization 헤더에 refreshToken을 실으면
        // 서버 인증 필터가 이를 access token으로 검증하려다 401을 내어 강제 로그아웃되므로 붙이지 않는다.
        urlRequest.httpBody = try JSONEncoder().encode(ReissueRequestDTO(refreshToken: refreshToken))

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: urlRequest)
        } catch {
            // 오프라인·타임아웃 등 네트워크 레벨 실패. 확정적 인증 실패가 아니므로 세션은 유지한다.
            throw NetworkError.from(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown(URLError(.badServerResponse))
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            let body = String(data: data, encoding: .utf8)?.prefix(300) ?? ""
            Log.error("토큰 재발급 실패: status=\(httpResponse.statusCode) body=\(body)", category: .auth)
            // 401/404는 확정적 인증 실패(강제 로그아웃), 5xx 등은 일시적 실패(세션 유지)로 분류한다.
            throw ReissueFailureClassifier.classify(statusCode: httpResponse.statusCode, data: data)
        }

        let decoded = try JSONDecoder().decode(CommonResponse<ReissueResponseDTO>.self, from: data)
        guard decoded.isSuccess else {
            throw NetworkError.serverError(code: decoded.code, message: decoded.message)
        }
        return decoded.result
    }
}

// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation
import Alamofire
import Moya

import BaziCore

public enum NetworkError: Error {
    case serverError(code: String, message: String)
    case decodingError(Error)
    case offline
    case timeout
    case unauthorized
    case unknown(Error)
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .serverError(let code, let message): return "[\(code)] \(message)"
        case .decodingError:                      return "데이터 디코딩에 실패했습니다."
        case .offline:                            return "인터넷 연결이 끊겼습니다."
        case .timeout:                            return "요청 시간이 초과되었습니다."
        case .unauthorized:                       return "인증이 만료되었습니다. 다시 로그인해주세요."
        case .unknown:                            return "알 수 없는 오류가 발생했습니다."
        }
    }
}

// 상위 계층(UseCaseError)이 구체 타입을 몰라도 분류를 읽을 수 있도록 노출한다.
extension NetworkError: NetworkFailureClassifiable {
    public var failureKind: NetworkFailureKind {
        switch self {
        case .serverError(let code, let message): return .server(code: code, message: message)
        case .decodingError:                      return .decoding
        case .offline:                            return .offline
        case .timeout:                            return .timeout
        case .unauthorized:                       return .unauthorized
        case .unknown:                            return .other
        }
    }
}

extension NetworkError {
    static func from(_ error: Error) -> NetworkError {
        // 1) 이미 NetworkError라면 그대로 반환 (예: TokenRefreshInterceptor가 던진 .unauthorized)
        if let networkError = error as? NetworkError {
            return networkError
        }

        // 2) MoyaError: 검증 실패(비-2xx) 응답이면 바디의 서버 code/message를 살린다.
        if let moyaError = error as? MoyaError {
            if let response = moyaError.response {
                // 401(= 재발급까지 실패)은 인증 만료로 확정 → 상위에서 재로그인 유도
                if response.statusCode == 401 {
                    return .unauthorized
                }
                if let envelope = try? JSONDecoder().decode(ErrorEnvelope.self, from: response.data) {
                    return .serverError(code: envelope.code, message: envelope.message)
                }
            }
            switch moyaError {
            case .underlying(let underlyingError, _):
                return from(underlyingError)
            default:
                return .unknown(moyaError)
            }
        }

        // 3) Alamofire가 URLError를 AFError(.sessionTaskFailed 등)로 감싸므로, underlying으로 내려가
        //    실제 URLError까지 도달해야 offline/timeout이 분류된다.
        if let afError = error as? AFError, let underlying = afError.underlyingError {
            return from(underlying)
        }

        // 4) 그 외는 NSError 기반으로 URLError 코드를 매핑
        let nsError = error as NSError
        switch nsError.code {
        case NSURLErrorNotConnectedToInternet:
            return .offline
        case NSURLErrorTimedOut:
            return .timeout
        default:
            return .unknown(error)
        }
    }
}

// 비-2xx 응답 바디에서 서버 code/message만 추출한다(result 형태와 무관하게 디코딩).
private struct ErrorEnvelope: Decodable {
    let code: String
    let message: String
}

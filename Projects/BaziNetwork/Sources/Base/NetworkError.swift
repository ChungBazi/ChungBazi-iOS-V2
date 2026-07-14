// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public enum NetworkError: Error {
    case serverError(code: String, message: String)
    case decodingError(Error)
    case networkError(message: String)
    case unauthorized
    case unknown(Error)
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .serverError(let code, let message): return "[\(code)] \(message)"
        case .decodingError:                      return "데이터 디코딩에 실패했습니다."
        case .networkError(let message):          return message
        case .unauthorized:                       return "인증이 만료되었습니다. 다시 로그인해주세요."
        case .unknown:                            return "알 수 없는 오류가 발생했습니다."
        }
    }
}

extension NetworkError {
    static func from(_ error: Error) -> NetworkError {
        let nsError = error as NSError
        switch nsError.code {
        case NSURLErrorNotConnectedToInternet:
            return .networkError(message: "인터넷 연결이 끊겼습니다.")
        case NSURLErrorTimedOut:
            return .networkError(message: "요청 시간이 초과되었습니다.")
        default:
            return .unknown(error)
        }
    }
}

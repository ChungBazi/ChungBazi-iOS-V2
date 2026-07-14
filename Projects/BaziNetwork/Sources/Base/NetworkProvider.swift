// Copyright © 2026 ChungBazi. All rights reserved.

import Alamofire
import Foundation
import Moya

public final class NetworkProvider {
    private let provider: MoyaProvider<MultiTarget>

    public init(tokenStorage: TokenStorage) {
        let interceptor = TokenRefreshInterceptor(tokenStorage: tokenStorage)
        let session = Session(interceptor: interceptor)

        #if DEBUG
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        ]
        self.provider = MoyaProvider<MultiTarget>(session: session, plugins: plugins)
        #else
        self.provider = MoyaProvider<MultiTarget>(session: session)
        #endif
    }

    // MARK: - 1. 필수 데이터 요청
    public func request<T: Decodable>(_ target: any APITargetType) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(MultiTarget(target)) { result in
                switch result {
                case .success(let response):
                    do {
                        let decoded = try response.map(CommonResponse<T>.self)
                        if decoded.isSuccess {
                            continuation.resume(returning: decoded.result)
                        } else {
                            continuation.resume(throwing: NetworkError.serverError(
                                code: decoded.code,
                                message: decoded.message
                            ))
                        }
                    } catch {
                        continuation.resume(throwing: NetworkError.decodingError(error))
                    }
                case .failure(let error):
                    continuation.resume(throwing: NetworkError.from(error))
                }
            }
        }
    }

    // MARK: - 2. 옵셔널 데이터 요청 (result가 없을 수 있는 경우)
    public func requestOptional<T: Decodable>(_ target: any APITargetType) async throws -> T? {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(MultiTarget(target)) { result in
                switch result {
                case .success(let response):
                    guard !response.data.isEmpty else {
                        return continuation.resume(returning: nil)
                    }
                    do {
                        let decoded = try response.map(CommonResponse<T>.self)
                        continuation.resume(returning: decoded.isSuccess ? decoded.result : nil)
                    } catch {
                        continuation.resume(throwing: NetworkError.decodingError(error))
                    }
                case .failure(let error):
                    continuation.resume(throwing: NetworkError.from(error))
                }
            }
        }
    }

    // MARK: - 3. 상태 코드만 확인 (result 없는 경우)
    public func requestStatusCode(_ target: any APITargetType) async throws {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(MultiTarget(target)) { result in
                switch result {
                case .success(let response):
                    if (200...299).contains(response.statusCode) {
                        continuation.resume()
                    } else {
                        continuation.resume(throwing: NetworkError.serverError(
                            code: "\(response.statusCode)",
                            message: "요청에 실패했습니다."
                        ))
                    }
                case .failure(let error):
                    continuation.resume(throwing: NetworkError.from(error))
                }
            }
        }
    }
}

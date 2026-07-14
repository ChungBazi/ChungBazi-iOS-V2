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

    // MARK: - 2. 결과값이 필요 없는 요청 (서버는 항상 String result를 반환)
    public func requestStatusCode(_ target: any APITargetType) async throws {
        let _: String = try await request(target)
    }
}

// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation
import Moya

public protocol APITargetType: TargetType {}

extension APITargetType {
    public var baseURL: URL { APIDomain.baseURL }
    public var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }
    // 2xx 외(예: 401)를 Alamofire가 "실패"로 판정해야 TokenRefreshInterceptor.retry가 호출된다.
    // .none이면 401도 성공으로 흘러가 토큰 자동 재발급이 트리거되지 않는다.
    public var validationType: ValidationType { .successCodes }
}

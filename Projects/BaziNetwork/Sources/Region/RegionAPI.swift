// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation
import Moya

public enum RegionAPI {
    case getSido
    case getSigungu(sido: String)
}

extension RegionAPI: APITargetType {
    public var baseURL: URL { APIDomain.regionURL }
    
    public var path: String {
        switch self {
        case .getSido:    return "/sido"
        case .getSigungu: return "/sigungu"
        }
    }
    
    public var method: Moya.Method { .get }
    
    public var task: Task {
        switch self {
        case .getSido:
            return .requestPlain
        case .getSigungu(let sido):
            return .requestParameters(
                parameters: ["sidoCode": sido],
                encoding: URLEncoding.queryString
            )
        }
    }
}

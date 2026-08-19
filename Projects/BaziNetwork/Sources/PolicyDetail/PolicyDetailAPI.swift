// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation
import Moya

public enum PolicyDetailAPI {
    case likePolicy(policyId: Int)
    case unlikePolicy(policyId: Int)
    case getPolicyDetail(policyId: Int)
    case getPolicyCard(policyId: Int)
}

extension PolicyDetailAPI: APITargetType {
    public var baseURL: URL { APIDomain.policyURL }

    public var path: String {
        switch self {
        case .likePolicy(let policyId),
             .unlikePolicy(let policyId): return "/\(policyId)/like"
        case .getPolicyDetail(let policyId): return "/detail/\(policyId)"
        case .getPolicyCard(let policyId):   return "/card/\(policyId)"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .likePolicy:    return .post
        case .unlikePolicy:  return .delete
        case .getPolicyDetail, .getPolicyCard: return .get
        }
    }

    public var task: Task { .requestPlain }
}

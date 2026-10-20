// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation
import Moya

public enum PolicyDetailAPI {
    case likePolicy(policyId: Int)
    case unlikePolicy(policyId: Int)
    case getPolicyDetail(policyId: Int)
    case getPolicyCard(policyId: Int)
    case getPolicyCards(category: String?)
}

extension PolicyDetailAPI: APITargetType {
    public var baseURL: URL { APIDomain.policyURL }

    public var path: String {
        switch self {
        case .likePolicy(let policyId),
             .unlikePolicy(let policyId): return "/\(policyId)/like"
        case .getPolicyDetail(let policyId): return "/detail/\(policyId)"
        case .getPolicyCard(let policyId):   return "/card/\(policyId)"
        case .getPolicyCards:                return "/cards"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .likePolicy:    return .post
        case .unlikePolicy:  return .delete
        case .getPolicyDetail, .getPolicyCard, .getPolicyCards: return .get
        }
    }

    public var task: Task {
        switch self {
        case .getPolicyCards(let category):
            var params: [String: Any] = [:]
            if let category { params["category"] = category }
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        default:
            return .requestPlain
        }
    }
}

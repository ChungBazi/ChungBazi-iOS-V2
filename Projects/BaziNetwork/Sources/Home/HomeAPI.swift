// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation
import Moya

public enum HomeAPI {
    case getPolicies(category: String, sort: String, cursor: String?, size: Int)
    case getLatestPolicies(category: String?, cursor: String?, size: Int)
    case getDeadlinePolicies(category: String?, cursor: String?, size: Int)
}

extension HomeAPI: APITargetType {
    public var baseURL: URL { APIDomain.homeURL }
    
    public var path: String {
        switch self {
        case .getPolicies:         return "/policies"
        case .getLatestPolicies:   return "/policies/latest"
        case .getDeadlinePolicies: return "/policies/deadline"
        }
    }
    public var method: Moya.Method { .get }
    
    public var task: Task {
        switch self {
        case .getPolicies(let category, let sort, let cursor, let size):
            var params: [String: Any] = [
                "category": category,
                "sort": sort,
                "size": size
            ]
            if let cursor { params["cursor"] = cursor }
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)

        case .getLatestPolicies(let category, let cursor, let size),
             .getDeadlinePolicies(let category, let cursor, let size):
            var params: [String: Any] = ["size": size]
            if let category { params["category"] = category }
            if let cursor { params["cursor"] = cursor }
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        }
    }
}

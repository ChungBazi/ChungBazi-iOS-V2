// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation
import Moya

public enum HomeAPI {
    case getHomePolicySection
    case getPolicies(category: String, sort: String, cursor: String?, size: Int)
    case getRecentViewedPolicies(cursor: String?, size: Int)
    case getPopularPolicies(category: String?, cursor: String?, size: Int)
    case getLatestPolicies(category: String?, cursor: String?, size: Int)
    case getDeadlinePolicies(category: String?, cursor: String?, size: Int)
    case getPersonalizedPolicies(category: String)
}

extension HomeAPI: APITargetType {
    public var baseURL: URL { APIDomain.homeURL }
    
    public var path: String {
        switch self {
        case .getHomePolicySection: return ""
        case .getPolicies: return "/policies"
        case .getRecentViewedPolicies: return "/policies/recent-viewed"
        case .getPopularPolicies: return "/policies/popular"
        case .getLatestPolicies: return "/policies/latest"
        case .getDeadlinePolicies: return "/policies/deadline"
        case .getPersonalizedPolicies: return "/policies/personalized"
        }
    }
    public var method: Moya.Method { .get }
    
    public var task: Task {
        switch self {
        case .getHomePolicySection: return .requestPlain
        case .getPolicies(let category, let sort, let cursor, let size):
            var params: [String: Any] = [
                "category": category,
                "sort": sort,
                "size": size
            ]
            if let cursor { params["cursor"] = cursor }
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)

        case .getRecentViewedPolicies(let cursor, let size):
            var params: [String: Any] = ["size": size]
            if let cursor { params["cursor"] = cursor }
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
            
        case .getPopularPolicies(let category, let cursor, let size),
             .getLatestPolicies(let category, let cursor, let size),
             .getDeadlinePolicies(let category, let cursor, let size):
            var params: [String: Any] = ["size": size]
            if let category { params["category"] = category }
            if let cursor { params["cursor"] = cursor }
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)

        case .getPersonalizedPolicies(let category):
            return .requestParameters(
                parameters: ["category": category],
                encoding: URLEncoding.queryString
            )
        }
    }
}

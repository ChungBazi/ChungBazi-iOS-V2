// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation
import Moya

public enum PolicySearchAPI {
    case search(keyword: String, category: String?, sort: String?, cursor: String?, size: Int)
    case getSearchSuggestions(keyword: String)
}

extension PolicySearchAPI: APITargetType {
    public var baseURL: URL { APIDomain.policySearchURL }
    
    public var path: String {
        switch self {
        case .search:               return "/search"
        case .getSearchSuggestions: return "/search-suggestions"
        }
    }
    public var method: Moya.Method { .get }
    
    public var task: Task {
        switch self {
        case .search(let keyword, let category, let sort, let cursor, let size):
            var params: [String: Any] = ["keyword": keyword, "size": size]
            if let category { params["category"] = category }
            if let sort { params["sort"] = sort }
            if let cursor { params["cursor"] = cursor }
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
            
        case .getSearchSuggestions(let keyword):
            return .requestParameters(
                parameters: ["keyword": keyword],
                encoding: URLEncoding.queryString
            )
        }
    }
}

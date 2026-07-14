// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation
import Moya

public enum RecentSearchAPI {
    case getRecentSearches(cursor: String?, size: Int)
    case deleteAllRecentSearches
    case deleteRecentSearch(keywordId: Int)
    case updateAutoSave(body: UpdateAutoSaveRequestDTO)
}

extension RecentSearchAPI: APITargetType {
    public var baseURL: URL { URL(string: APIDomain.recentSearchURL)! }
    
    public var path: String {
        switch self {
        case .getRecentSearches,
             .deleteAllRecentSearches:           return ""
        case .deleteRecentSearch(let keywordId): return "/\(keywordId)"
        case .updateAutoSave:                    return "/auto-save"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .getRecentSearches:   return .get
        case .deleteAllRecentSearches,
             .deleteRecentSearch:  return .delete
        case .updateAutoSave:      return .patch
        }
    }
    
    public var task: Task {
        switch self {
        case .deleteAllRecentSearches,
             .deleteRecentSearch:
            return .requestPlain
            
        case .getRecentSearches(let cursor, let size):
            var params: [String: Any] = ["size": size]
            if let cursor { params["cursor"] = cursor }
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
            
        case .updateAutoSave(let body):
            return .requestJSONEncodable(body)
        }
    }
}

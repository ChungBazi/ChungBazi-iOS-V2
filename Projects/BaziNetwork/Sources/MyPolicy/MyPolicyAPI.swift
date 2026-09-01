// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation
import Moya

public enum MyPolicyAPI {
    case getMyPolicies(category: String?, sort: String?, cursor: String?, size: Int)
    case getOpenEndedPolicies(cursor: String?, size: Int)
    case getDeadlinePolicies
    case getDeadlineUpcomingPolicies(targetDate: String)
    case getDeadlineDatePolicies(targetDate: String, sort: String?, cursor: String?, size: Int)
    case getCalendar(targetMonth: String)
    case getMemo(policyId: Int)
    case updateMemo(policyId: Int, body: PolicyMemoRequestDTO)
}

extension MyPolicyAPI: APITargetType {
    public var baseURL: URL { APIDomain.myPolicyURL }

    public var path: String {
        switch self {
        case .getMyPolicies:                return ""
        case .getOpenEndedPolicies:         return "/open-ended"
        case .getDeadlinePolicies:          return "/deadline"
        case .getDeadlineUpcomingPolicies:  return "/deadline/upcoming"
        case .getDeadlineDatePolicies:      return "/deadline/date"
        case .getCalendar:                  return "/calendar"
        case .getMemo(let policyId),
             .updateMemo(let policyId, _):  return "/\(policyId)/memo"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .updateMemo: return .put
        default:          return .get
        }
    }

    public var task: Task {
        switch self {
        case .getDeadlinePolicies:
            return .requestPlain

        case .getMyPolicies(let category, let sort, let cursor, let size):
            var params: [String: Any] = ["size": size]
            if let category { params["category"] = category }
            if let sort { params["sort"] = sort }
            if let cursor { params["cursor"] = cursor }
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)

        case .getOpenEndedPolicies(let cursor, let size):
            var params: [String: Any] = ["size": size]
            if let cursor { params["cursor"] = cursor }
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)

        case .getDeadlineUpcomingPolicies(let targetDate):
            return .requestParameters(parameters: ["targetDate": targetDate], encoding: URLEncoding.queryString)

        case .getDeadlineDatePolicies(let targetDate, let sort, let cursor, let size):
            var params: [String: Any] = ["targetDate": targetDate, "size": size]
            if let sort { params["sort"] = sort }
            if let cursor { params["cursor"] = cursor }
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)

        case .getCalendar(let targetMonth):
            return .requestParameters(
                parameters: ["targetMonth": targetMonth],
                encoding: URLEncoding.queryString
            )

        case .getMemo:
            return .requestPlain

        case .updateMemo(_, let body):
            return .requestJSONEncodable(body)
        }
    }
}

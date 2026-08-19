// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation
import Moya

public enum NotificationAPI {
    case getNotifications(category: String?, cursor: Int?, size: Int)
    case markAsRead(notificationId: Int)
    case deleteNotification(notificationId: Int)
    case deleteAllNotifications
}

extension NotificationAPI: APITargetType {
    public var baseURL: URL { APIDomain.notificationURL }

    public var path: String {
        switch self {
        case .getNotifications,
             .deleteAllNotifications:              return ""
        case .markAsRead(let notificationId):      return "/\(notificationId)/read"
        case .deleteNotification(let notificationId): return "/\(notificationId)"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .getNotifications:      return .get
        case .markAsRead:            return .patch
        case .deleteNotification,
             .deleteAllNotifications: return .delete
        }
    }

    public var task: Task {
        switch self {
        case .getNotifications(let category, let cursor, let size):
            var params: [String: Any] = ["size": size]
            if let category { params["category"] = category }
            if let cursor { params["cursor"] = cursor }
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)

        case .markAsRead,
             .deleteNotification,
             .deleteAllNotifications:
            return .requestPlain
        }
    }
}

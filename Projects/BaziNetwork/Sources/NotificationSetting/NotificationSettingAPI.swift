// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation
import Moya

public enum NotificationSettingAPI {
    case getSettings
    case updateSettings(body: NotificationSettingUpdateRequestDTO)
}

extension NotificationSettingAPI: APITargetType {
    public var baseURL: URL { APIDomain.notificationURL }

    public var path: String { "/settings" }

    public var method: Moya.Method {
        switch self {
        case .getSettings:    return .get
        case .updateSettings: return .put
        }
    }

    public var task: Task {
        switch self {
        case .getSettings:                 return .requestPlain
        case .updateSettings(let body):    return .requestJSONEncodable(body)
        }
    }
}

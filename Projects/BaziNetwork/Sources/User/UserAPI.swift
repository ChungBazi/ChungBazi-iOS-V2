// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation
import Moya

public enum UserAPI {
    case onboarding(body: OnboardingRequestDTO)
    case getPolicyProfile
    case updatePolicyProfile(body: OnboardingRequestDTO)
    case updateName(body: NameRequestDTO)
    case getProfile
}

extension UserAPI: APITargetType {
    public var baseURL: URL { URL(string: APIDomain.userURL)! }
    public var path: String {
        switch self {
        case .onboarding:                    return "/onboarding"
        case .getPolicyProfile,
             .updatePolicyProfile:           return "/policy-profile"
        case .updateName:                    return "/name"
        case .getProfile:                    return "/me"
        }
    }
    public var method: Moya.Method {
        switch self {
        case .onboarding:          return .post
        case .getPolicyProfile:    return .get
        case .updatePolicyProfile, .updateName: return .patch
        case .getProfile:          return .get
        }
    }
    public var task: Task {
        switch self {
        case .onboarding(let body):          return .requestJSONEncodable(body)
        case .updatePolicyProfile(let body): return .requestJSONEncodable(body)
        case .updateName(let body):          return .requestJSONEncodable(body)
        case .getPolicyProfile, .getProfile: return .requestPlain
        }
    }
}

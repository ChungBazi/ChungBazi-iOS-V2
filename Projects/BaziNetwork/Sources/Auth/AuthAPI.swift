// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation
import Moya

public enum AuthAPI {
    case kakaoLogin(body: KakaoLoginRequestDTO)
    case appleLogin(body: AppleLoginRequestDTO)
    case logout
    case reissue(body: ReissueRequestDTO)
}

extension AuthAPI: APITargetType {
    public var baseURL: URL { APIDomain.authURL }
    
    public var path: String {
        switch self {
        case .kakaoLogin: return "/kakao"
        case .appleLogin: return "/apple"
        case .logout:     return "/logout"
        case .reissue:    return "/reissue"
        }
    }
    
    public var method: Moya.Method { .post }
    
    public var task: Task {
        switch self {
        case .kakaoLogin(let body): return .requestJSONEncodable(body)
        case .appleLogin(let body): return .requestJSONEncodable(body)
        case .reissue(let body): return .requestJSONEncodable(body)
        case .logout: return .requestPlain
        }
    }
}

// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

enum Config {
    nonisolated(unsafe) private static let infoDictionary: [String: Any] = {
      guard let dict = Bundle.main.infoDictionary else {
        fatalError("Plist 없음")
      }
      return dict
    }()
    
    static let baseURL: String = {
      guard let apiURL = infoDictionary["BASE_URL"] as? String else {
        fatalError()
      }
      return apiURL
    }()

    static let kakaoNativeAppKey: String = {
      guard let appKey = infoDictionary["KAKAO_NATIVE_APP_KEY"] as? String else {
        fatalError()
      }
      return appKey
    }()

    /// 앱 커스텀 URL 스킴. 빌드 구성별로 다르다(Debug: chungbazi-dev, Release: chungbazi).
    static let urlScheme: String = {
      guard let scheme = infoDictionary["APP_URL_SCHEME"] as? String else {
        fatalError()
      }
      return scheme
    }()

    static let amplitudeAPIKey: String = {
      guard let key = infoDictionary["AMPLITUDE_API_KEY"] as? String else {
        fatalError()
      }
      return key
    }()
}

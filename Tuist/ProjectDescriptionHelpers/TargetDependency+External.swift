import ProjectDescription

public enum External: String {
    case Moya
    case ComposableArchitecture
    case KakaoSDKCommon
    case KakaoSDKAuth
    case KakaoSDKUser
    case KakaoSDKShare
    case KakaoSDKTemplate
    case FirebaseCore
    case FirebaseMessaging
    case FirebaseCrashlytics
    case FirebaseRemoteConfig
}

extension TargetDependency {
    public static func external(_ dependency: External) -> TargetDependency {
        .external(name: dependency.rawValue)
    }
}

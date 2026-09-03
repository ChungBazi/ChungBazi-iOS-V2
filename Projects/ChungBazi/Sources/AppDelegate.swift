// Copyright © 2026 ChungBazi. All rights reserved.

import UIKit
import UserNotifications

import BaziCore
import FirebaseCore
import FirebaseMessaging
import KakaoSDKCommon

final class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        // Crashlytics는 SDK 링크 + FirebaseApp.configure() 이후 자동으로 크래시를 수집한다.
        KakaoSDK.initSDK(appKey: Config.kakaoNativeAppKey)

        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
        application.registerForRemoteNotifications()

        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
    }
}

// MARK: - MessagingDelegate

extension AppDelegate: MessagingDelegate {
    nonisolated func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        Log.debug("FCM 토큰 수신: \(fcmToken?.prefix(8) ?? "nil")...", category: .lifecycle)
        AppDependencies.pushTokenRepository.saveToken(fcmToken)
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {

    /// 포그라운드에서도 배너/사운드/뱃지를 그대로 보여준다.
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .badge]
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        // 알림 탭 시 payload의 policyId로 정책 상세 딥링크를 발행한다.
        let userInfo = response.notification.request.content.userInfo
        if let policyId = Self.policyId(from: userInfo) {
            DeeplinkPublisher.policyDetail(id: policyId)
        }
    }

    /// FCM payload는 값이 문자열로 오는 경우가 많아 Int/String 양쪽을 허용한다.
    private nonisolated static func policyId(from userInfo: [AnyHashable: Any]) -> Int? {
        switch userInfo["policyId"] {
        case let value as Int: return value
        case let value as String: return Int(value)
        default: return nil
        }
    }
}

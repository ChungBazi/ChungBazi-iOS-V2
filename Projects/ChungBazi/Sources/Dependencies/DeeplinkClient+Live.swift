// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import ComposableArchitecture

import BaziCore
import BaziPresentation

extension Notification.Name {
    /// 카카오 공유 링크/푸시 알림 탭에서 정책 상세로 이동해야 할 때 발행한다.
    static let deeplinkPolicyDetail = Notification.Name("ChungBazi.deeplinkPolicyDetail")
}

/// 아직 라우팅되지 못한 딥링크 1건을 보관한다(콜드런치 시 splash 단계에서 도착한 것 등).
/// 발행(DeeplinkPublisher) 시점에 저장하므로, onOpenURL이 AppFeature 구독보다 먼저 불려도 유실되지 않는다.
private let pendingDeeplink = LockIsolated<Deeplink?>(nil)

/// 카카오 공유 링크를 탭해 앱이 열릴 때 도착하는 URL(kakao{appkey}://kakaolink?...)에서
/// 공유 시 심어둔 iosExecutionParams("policyId")를 파싱한다.
enum KakaoLinkParser {
    static func policyId(from url: URL) -> Int? {
        guard url.host == "kakaolink" else { return nil }
        guard
            let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
            let value = items.first(where: { $0.name == "policyId" })?.value,
            let id = Int(value)
        else {
            // 카카오 링크인데 policyId를 못 읽으면 딥링크가 조용히 유실되므로 원인 추적용으로 남긴다.
            Log.error("카카오 공유 링크 policyId 파싱 실패: \(url.absoluteString)", category: .lifecycle)
            return nil
        }
        return id
    }
}

/// 앱 커스텀 스킴 딥링크(chungbazi://policy/{id}) 빌드/파싱.
/// 캘린더 이벤트의 URL 필드에 심고, 탭해서 앱이 열릴 때 다시 policyId로 되돌린다.
enum PolicyDeeplink {
    static let scheme = "chungbazi"
    static let host = "policy"

    /// 정책 상세로 여는 딥링크 URL(예: chungbazi://policy/123).
    static func url(policyId: Int) -> URL? {
        URL(string: "\(scheme)://\(host)/\(policyId)")
    }

    /// chungbazi://policy/{id} → policyId.
    static func policyId(from url: URL) -> Int? {
        guard url.scheme == scheme, url.host == host else { return nil }
        return Int(url.lastPathComponent)
    }
}

/// Composition Root 바깥(onOpenURL, AppDelegate)에서 딥링크를 발행하는 진입점.
/// 이들이 BaziPresentation의 DeeplinkClient를 직접 다루지 않도록 NotificationCenter로 브리지한다.
enum DeeplinkPublisher {
    static func policyDetail(id: Int) {
        // 구독 여부와 무관하게 먼저 보관(콜드런치 대응) 후, 실행 중이면 스트림으로도 전달되도록 알림 발행.
        pendingDeeplink.setValue(.policyDetail(id: id))
        NotificationCenter.default.post(
            name: .deeplinkPolicyDetail,
            object: nil,
            userInfo: ["policyId": id]
        )
    }
}

extension DeeplinkClient: @retroactive DependencyKey {

    public static let liveValue = DeeplinkClient(
        events: {
            AsyncStream { continuation in
                // 옵저버 토큰은 제거용으로만 쓰고 NotificationCenter는 스레드 안전 → 캡처 안전.
                nonisolated(unsafe) let observer = NotificationCenter.default.addObserver(
                    forName: .deeplinkPolicyDetail,
                    object: nil,
                    queue: nil
                ) { note in
                    if let id = note.userInfo?["policyId"] as? Int {
                        continuation.yield(.policyDetail(id: id))
                    }
                }
                continuation.onTermination = { _ in
                    NotificationCenter.default.removeObserver(observer)
                }
            }
        },
        takePending: {
            pendingDeeplink.withValue { value in
                let taken = value
                value = nil
                return taken
            }
        }
    )
}

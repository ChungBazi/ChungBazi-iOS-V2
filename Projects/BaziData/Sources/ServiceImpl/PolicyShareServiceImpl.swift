// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation
import UIKit

import BaziDomain
import KakaoSDKShare
import KakaoSDKTemplate

public struct PolicyShareServiceImpl: PolicyShareService {

    public init() {}

    public func shareToKakao(_ content: PolicyShareContent) async throws {
        // 카카오 SDK 호출은 메인 스레드에서 수행하고, 공유 결과 URL을 받아 앱을 전환한다.
        let sharingURL: URL = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<URL, Error>) in
            Task { @MainActor in
                guard ShareApi.isKakaoTalkSharingAvailable() else {
                    continuation.resume(throwing: UseCaseError.unknown("카카오톡이 설치되어 있지 않아 공유할 수 없습니다."))
                    return
                }
                let params = ["policyId": "\(content.policyId)"]
                let webURL = content.webURL.flatMap(URL.init(string:))
                let link = Link(
                    webUrl: webURL,
                    mobileWebUrl: webURL,
                    androidExecutionParams: params,
                    iosExecutionParams: params
                )
                // 카드 대표 이미지는 생략(제목/설명 중심). 카카오 콘솔에 등록된 앱 아이콘이 메시지 앱 출처로 표시된다.
                let template = FeedTemplate(
                    content: Content(
                        title: content.title,
                        description: content.description,
                        link: link
                    ),
                    buttons: [Button(title: "자세히 보기", link: link)]
                )
                ShareApi.shared.shareDefault(templatable: template) { result, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else if let result {
                        continuation.resume(returning: result.url)
                    } else {
                        continuation.resume(throwing: UseCaseError.unknown("카카오 공유 결과가 비어 있습니다."))
                    }
                }
            }
        }
        await MainActor.run { UIApplication.shared.open(sharingURL) }
    }
}

// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziDomain
import KakaoSDKShare
import KakaoSDKTemplate

public struct PolicyShareServiceImpl: PolicyShareService {

    public init() {}

    /// 카카오 공유 템플릿을 만들어 공유 URL을 반환한다. 앱 전환(open)은 호출부(Composition Root)가 담당한다.
    public func makeKakaoShareURL(_ content: PolicyShareContent) async throws -> URL {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<URL, Error>) in
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
                // 카드 대표 이미지는 생략(제목/설명 중심).
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
    }
}

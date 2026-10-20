// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation
import UIKit

import BaziDomain
import KakaoSDKShare
import KakaoSDKTemplate

public struct PolicyShareServiceImpl: PolicyShareService {

    /// 카테고리별 업로드 결과 세션 캐시. liveValue가 서비스를 1회 생성해 보유하므로 세션 동안 유지된다.
    private let imageCache = KakaoImageCache()

    public init() {}

    /// 카카오 공유 템플릿을 만들어 공유 URL을 반환한다. 앱 전환(open)은 호출부(Composition Root)가 담당한다.
    /// 썸네일이 있으면 카카오 서버에 업로드해 imageUrl로 첨부하고, 업로드 실패 시엔 이미지 없이 공유한다.
    public func makeKakaoShareURL(_ content: PolicyShareContent, thumbnail: ShareThumbnail?) async throws -> URL {
        // 업로드 실패가 공유 자체를 막지 않도록 실패는 이미지 없음(nil)으로 흡수한다.
        let uploaded = try? await resolveImage(thumbnail)

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<URL, Error>) in
            Task { @MainActor in
                guard ShareApi.isKakaoTalkSharingAvailable() else {
                    continuation.resume(throwing: UseCaseError.message("카카오톡이 설치되어 있지 않아 공유할 수 없어요"))
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
                let template = FeedTemplate(
                    content: Content(
                        title: content.title,
                        imageUrl: uploaded?.url,
                        // 원본 픽셀 크기를 함께 넘겨 카카오톡이 고정 비율로 크롭하지 않고 이미지 비율을 유지하게 한다.
                        imageWidth: uploaded?.width,
                        imageHeight: uploaded?.height,
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
                        continuation.resume(throwing: UseCaseError.unknown)
                    }
                }
            }
        }
    }

    /// 썸네일을 카카오 서버에 업로드해 URL·원본 크기를 얻는다(카테고리별 세션 캐시·코얼레싱). 첨부가 없으면 nil.
    private func resolveImage(_ thumbnail: ShareThumbnail?) async throws -> KakaoUploadedImage? {
        guard let thumbnail else { return nil }
        let data = thumbnail.imageData
        return try await imageCache.image(key: thumbnail.cacheKey) {
            guard let image = UIImage(data: data) else { throw UseCaseError.unknown }
            let url = try await Self.uploadImage(image)
            // data에서 디코딩한 이미지의 픽셀 크기(scale 반영).
            return KakaoUploadedImage(
                url: url,
                width: Int((image.size.width * image.scale).rounded()),
                height: Int((image.size.height * image.scale).rounded())
            )
        }
    }

    private static func uploadImage(_ image: UIImage) async throws -> URL {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<URL, Error>) in
            ShareApi.shared.imageUpload(image: image) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let url = result?.infos.original.url {
                    continuation.resume(returning: url)
                } else {
                    continuation.resume(throwing: UseCaseError.unknown)
                }
            }
        }
    }
}

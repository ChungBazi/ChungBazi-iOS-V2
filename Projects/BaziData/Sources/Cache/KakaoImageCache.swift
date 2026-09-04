// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 카카오에 업로드한 공유 이미지 정보. 원본 픽셀 크기를 함께 넘겨 카카오톡이 비율을 유지해 표시하게 한다.
struct KakaoUploadedImage: Sendable {
    let url: URL
    let width: Int
    let height: Int
}

/// 카카오 이미지 업로드 결과의 세션 캐시. 같은 키(카테고리)의 이미지는 1회만 업로드하고 재사용한다.
/// 최초 동시 호출은 하나의 업로드로 합치고(coalescing), 실패한 업로드는 캐시하지 않는다.
actor KakaoImageCache {

    private var images: [String: KakaoUploadedImage] = [:]
    private var tasks: [String: Task<KakaoUploadedImage, Error>] = [:]

    /// 캐시가 있으면 즉시, 없으면 `upload`로 1회만 업로드한다. 진행 중이면 같은 작업을 공유한다.
    func image(
        key: String,
        upload: @Sendable @escaping () async throws -> KakaoUploadedImage
    ) async throws -> KakaoUploadedImage {
        if let image = images[key] { return image }
        if let task = tasks[key] { return try await task.value }

        let task = Task { try await upload() }
        tasks[key] = task
        defer { tasks[key] = nil }
        let image = try await task.value
        images[key] = image
        return image
    }
}

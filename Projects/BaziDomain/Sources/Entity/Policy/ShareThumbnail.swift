// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 카카오 공유에 첨부할 썸네일. `cacheKey`(카테고리 식별자)별로 업로드 URL을 캐시해 재업로드를 피한다.
public struct ShareThumbnail: Equatable, Sendable {
    public let cacheKey: String
    public let imageData: Data

    public init(cacheKey: String, imageData: Data) {
        self.cacheKey = cacheKey
        self.imageData = imageData
    }
}

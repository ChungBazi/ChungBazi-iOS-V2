// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 정책 메모 작성 및 수정 Request DTO
public struct PolicyMemoRequestDTO: Encodable {
    public let memo: String

    public init(memo: String) {
        self.memo = memo
    }
}

// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 키워드로 정책을 검색한다. 분야 필터·정렬·커서 페이지네이션은 서버가 처리한다.
public protocol SearchPoliciesUseCase: Sendable {
    func execute(keyword: String, category: PolicyCategory?, sort: String?, cursor: String?, size: Int) async throws -> PolicyPage
}

// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 카카오톡으로 공유할 정책 정보. 공유 링크 탭 시 `policyId`로 정책 상세 딥링크가 열린다.
public struct PolicyShareContent: Equatable, Sendable {
    public let policyId: Int
    public let title: String
    public let description: String
    /// 카드에서 열 웹 페이지(등록된 도메인이어야 함). 없으면 앱 실행 링크만 동작한다.
    public let webURL: String?

    public init(policyId: Int, title: String, description: String, webURL: String?) {
        self.policyId = policyId
        self.title = title
        self.description = description
        self.webURL = webURL
    }
}

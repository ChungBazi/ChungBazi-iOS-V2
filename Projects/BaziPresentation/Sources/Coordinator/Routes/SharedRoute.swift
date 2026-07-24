// Copyright © 2026 ChungBazi. All rights reserved.

public enum SharedRoute: Hashable {
    case customPolicyList          // 12: 맞춤정책 더보기
    case policyDetail(id: String)  // 18: 정책 상세 (홈/검색/내정책 공유)
}

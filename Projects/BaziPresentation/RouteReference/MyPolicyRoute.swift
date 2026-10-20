// Copyright © 2026 ChungBazi. All rights reserved.

public enum MyPolicyRoute: Hashable {
    case policyList                    // 20: 내정책 전체보기
    case calendar                      // 21: 캘린더
    case policyMemo(policyId: String)  // 22: 정책 메모
}

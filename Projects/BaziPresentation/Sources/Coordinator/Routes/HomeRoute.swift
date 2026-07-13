// Copyright © 2026 ChungBazi. All rights reserved.

public enum HomeRoute: Hashable {
    case customPolicyList                      // 12: 맞춤정책 더보기
    case categoryPolicyList(category: String)  // 13: 분야별 정책 리스트
    case popularPolicyList                     // 14: 인기정책 더보기
    case deadlinePolicyList                    // 15: 마감임박 정책 더보기
    case newPolicyList                         // 16: 새로 뜬 정책 더보기
    case attendanceCalendar                    // 28: 출석 달력
    case notification                          // 33: 알림
}

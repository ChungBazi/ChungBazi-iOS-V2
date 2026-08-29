// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 프로필 플로우의 정적 데이터(외부 URL·문구 등).
/// 도메인 코드값(교육/직업/소득/관심분야)은 BaziDomain enum을 그대로 사용한다.
public enum ProfileConstants {

    // MARK: - External URLs

    /// 앱스토어 페이지 (앱 이름 경로는 생략 가능해 id만 사용 — 비ASCII 인코딩 이슈 방지).
    public static let appStoreURL = URL(string: "https://apps.apple.com/kr/app/id6753987371")

    /// 문의하기 구글폼.
    public static let inquiryFormURL = URL(string: "https://forms.gle/7XGnZof7Jwdvgyzs5")

    // MARK: - Withdraw

    /// 탈퇴 사유 선택지.
    public static let withdrawReasons = [
        "원하는 정책을 찾기 어려워요.",
        "저에게 맞는 정책 추천이 부족해요.",
        "이용할 일이 없어졌어요.",
        "앱 사용이 불편했어요.",
        "오류가 자주 발생했어요.",
        "기타 이유가 있어요.",
    ]
}

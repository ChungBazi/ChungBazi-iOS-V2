// Copyright © 2026 ChungBazi. All rights reserved.

/// 온보딩과 "정책 맞춤 조건 수정"이 공유하는 질문·선택 문구.
/// 두 화면이 동일한 맞춤 조건(생년월일/지역/학업/취업/소득)을 수집하므로, 문구를 한 곳에서 관리해 화면 간 불일치를 막는다.
public enum PolicyProfileConstants {

    /// 항목별 질문 문구.
    public enum Question {
        public static let birthDate = "생년월일이 언제인가요?"
        public static let region = "거주 중인 지역을 선택해주세요"
        public static let education = "현재 어떤 학업 단계에 있나요?"
        public static let employment = "현재 하고 있는 일이 있나요?"
        public static let income = "현재 소득분위가 어떻게 되나요?"
    }

    /// 선택(피커) 문구. 시/도·시/군/구는 title·placeholder에 동일하게 쓴다.
    public enum SelectTitle {
        public static let sido = "시/도 선택"
        public static let sigungu = "시/군/구 선택"
        public static let education = "학업 단계 선택"
        public static let employment = "취업 상태 선택"
        public static let income = "소득 분위 선택"
    }
}

// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 프로필 플로우의 정적 데이터(외부 URL·문구·약관 본문 등).
/// 도메인 코드값(교육/직업/소득/관심분야)과 탈퇴 사유는 각각 BaziDomain enum / Presentation VO를 사용한다.
public enum ProfileConstants {

    // MARK: - External URLs

    /// 앱스토어 페이지 (앱 이름 경로는 생략 가능해 id만 사용 — 비ASCII 인코딩 이슈 방지).
    public static let appStoreURL = URL(string: "https://apps.apple.com/kr/app/id6753987371")

    /// 문의하기 구글폼.
    public static let inquiryFormURL = URL(string: "https://forms.gle/7XGnZof7Jwdvgyzs5")

    // MARK: - Legal Documents

    public enum LegalDocument {

        public static let termsOfService = """
        청바지 서비스 이용약관은 다음과 같은 내용을 담고 있습니다.

        1. 서비스 제공
        청바지는 청년 정책 정보 제공, 맞춤 정책 추천 및 관련 기능을 제공하는 서비스입니다.

        2. 사용자 의무
        사용자는 다음의 행동을 금지합니다.
        - 불법적인 방법으로 서비스를 이용하거나 타인의 권리를 침해하는 행위
        - 서비스의 정상적인 운영을 방해하는 행위
        - 허위 정보를 제공하거나 악의적인 목적으로 앱을 사용하는 행위

        3. 계정 관리
        - 사용자는 서비스를 이용하기 위해 계정을 생성해야 합니다.
        - 계정 정보는 비밀로 유지해야 하며, 계정 도용 방지를 위해 타인에게 계정 정보를 제공하지 않아야 합니다.
        - 계정 해지 및 삭제는 언제든지 가능합니다.

        4. 서비스 이용 제한
        사용자가 본 약관을 위반하거나 서비스의 정상적인 운영을 방해하는 경우, 서비스 이용이 제한되거나 계정이 삭제될 수 있습니다.

        5. 서비스의 변경 및 종료
        - 서비스의 내용은 운영상 필요에 따라 변경 또는 종료될 수 있으며, 중요한 변경 사항은 앱 내 알림 등을 통해 안내합니다.
        - 서비스 종료 시 관련 법령에 따라 보관이 필요한 정보를 제외한 모든 사용자 데이터는 삭제합니다.

        6. 면책 조항
        - 사용자의 귀책사유로 발생한 손해에 대해서는 서비스 제공자가 책임을 지지 않습니다.
        - 서비스 이용 중 문의 사항이나 불편이 있는 경우, 앱 내 문의하기를 통해 문의하실 수 있습니다.

        7. 약관의 변경
        본 약관은 관련 법령 및 서비스 운영 정책에 따라 변경될 수 있으며, 변경 시 앱 내 알림 등을 통해 안내합니다.
        """

        public static let privacyPolicy = """
        청바지 개인정보처리방침은 다음과 같은 내용을 담고 있습니다.

        1. 수집하는 개인정보 항목
        청바지는 서비스 제공을 위해 다음과 같은 개인정보를 수집합니다.
        - 필수 항목: 이메일 주소, 사용자 이름(닉네임), 온보딩 입력 정보(생년월일, 거주 지역, 학력, 취업 상태, 소득 분위, 관심 분야)
        - 자동 수집 정보: IP 주소, 디바이스 정보, 사용 기록(앱 사용 시간, 기능 사용 내역 등)

        2. 개인정보의 이용 목적
        수집된 개인정보는 다음의 목적을 위해 사용됩니다.
        - 서비스 제공 및 관리
        - 사용자 맞춤형 서비스 제공
        - 서비스 개선 및 분석
        - 고객 지원 및 문의 응답
        - 법적 요구사항 준수

        3. 개인정보의 보관 및 보호
        - 개인정보는 서비스 제공에 필요한 최소한의 기간 동안 보관됩니다.
        - 개인정보 보호를 위해 합리적인 보안 조치를 적용하고 있습니다.

        4. 제3자 제공
        저희는 원칙적으로 사용자의 개인정보를 제3자에게 제공하지 않습니다. 다만, 다음의 경우에는 개인정보를 제공할 수 있습니다.
        - 법적 요구가 있을 경우
        - 사용자의 사전 동의를 받은 경우

        5. 사용자의 권리
        사용자는 언제든지 본인의 개인정보를 열람하고 수정할 수 있으며, 삭제를 요청할 수 있습니다. 개인정보 수정 및 삭제를 원하시면 문의하기로 연락해주세요.

        6. 추가 문의
        개인정보 보호에 관한 추가 문의는 chungbazibaro@gmail.com으로 연락주세요.
        """
    }

    // MARK: - Notification Setting

    public enum NotificationText {

        public struct Item: Equatable, Sendable {
            public let title: String
            public let description: String
        }

        public static let all = Item(
            title: "전체 알림",
            description: "내 정책 알림과 청바지 알림을 포함한 앱 내 모든 알림을 받아볼 수 있어요."
        )
        public static let myPolicy = Item(
            title: "내 정책 알림",
            description: "내가 찜한 정책의 신청 일정, 마감일, 정책 변경 사항 등 필요한 알림을 받아보세요."
        )
        public static let chungBazi = Item(
            title: "청바지 알림",
            description: "새롭게 등록된 정책, 추천 정책, 인기 정책 등 다양한 청바지의 소식을 받아보세요."
        )
    }

    // MARK: - Withdraw

    public enum Withdraw {

        /// 탈퇴 시 처리되는 내용 안내 항목.
        public static let noticeItems = [
            "회원 정보와 프로필이 삭제됩니다.",
            "찜한 정책, 메모, 활동 기록이 삭제됩니다.",
            "저장된 알림 설정이 삭제됩니다.",
            "탈퇴 후에는 동일한 계정으로 다시 로그인해도 이전 데이터는 복구되지 않습니다.",
        ]
    }
}

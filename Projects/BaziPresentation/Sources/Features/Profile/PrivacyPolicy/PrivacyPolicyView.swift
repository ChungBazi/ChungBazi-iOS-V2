// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import BaziDesign
import ComposableArchitecture

public struct PrivacyPolicyView: View {

    // MARK: - Properties

    @Bindable var store: StoreOf<PrivacyPolicyFeature>
    @Environment(\.dismiss) private var dismiss

    // MARK: - Init

    public init(store: StoreOf<PrivacyPolicyFeature>) {
        self.store = store
    }

    // MARK: - Body

    public var body: some View {
        StaticTextDocumentView(
            title: "개인정보 처리방침",
            text: Self.privacyText,
            onAppear: { store.send(.onAppear) },
            onBack: { dismiss() }
        )
    }
}

// MARK: - Content

extension PrivacyPolicyView {

    private static let privacyText = """
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

// MARK: - Preview

#Preview {
    NavigationStack {
        PrivacyPolicyView(
            store: Store(initialState: .init()) {
                PrivacyPolicyFeature()
            }
        )
    }
}

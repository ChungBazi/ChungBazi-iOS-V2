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
        content
            .task { store.send(.onAppear) }
            .baziNavigationBar_backWithTitle("개인정보 처리방침") {
                dismiss()
            }
    }
}

// MARK: - Subviews

extension PrivacyPolicyView {

    private var content: some View {
        ScrollView {
            Text(Self.privacyText)
                .baziFont(.small14R)
                .foregroundStyle(Color.gray700)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
        }
        .baziBackground(.bgWhite)
    }

    // TODO: 법무 검토가 끝난 실제 개인정보 처리방침 문구가 준비되면 교체한다.
    private static let privacyText = """
    청바지(이하 "회사")는 이용자의 개인정보를 중요하게 생각하며, 「개인정보 보호법」 등 관련 법령을 준수합니다.

    1. 수집하는 개인정보 항목
    회사는 회원가입, 서비스 이용 과정에서 아래와 같은 정보를 수집합니다.
    - 필수: 소셜 로그인 식별자, 닉네임, 생년월일
    - 정책 추천을 위한 정보: 거주 지역, 학력, 취업 상태, 소득분위, 관심 분야
    - 서비스 이용 과정에서 자동 생성되는 정보: 접속 기록, 기기 정보, 푸시 알림 토큰

    2. 개인정보의 수집 및 이용 목적
    - 회원 식별 및 서비스 제공
    - 맞춤형 청년 정책 추천
    - 정책 마감일, 신청 일정 등 알림 발송
    - 서비스 개선 및 신규 기능 개발

    3. 개인정보의 보유 및 이용 기간
    회원 탈퇴 시 지체 없이 파기하며, 관련 법령에 따라 보존이 필요한 경우 해당 기간 동안 보관합니다.

    4. 개인정보의 제3자 제공
    회사는 이용자의 동의 없이 개인정보를 제3자에게 제공하지 않으며, 법령에 특별한 규정이 있는 경우에만 예외로 합니다.

    5. 이용자의 권리
    이용자는 언제든지 자신의 개인정보를 조회, 수정할 수 있으며, 회원 탈퇴를 통해 개인정보 삭제를 요청할 수 있습니다.

    6. 개인정보 보호책임자
    회사는 개인정보 처리에 관한 업무를 총괄하는 개인정보 보호책임자를 지정하여 운영하고 있습니다.
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

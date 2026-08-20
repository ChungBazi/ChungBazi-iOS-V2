// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import BaziDesign
import ComposableArchitecture

public struct TermsOfServiceView: View {

    // MARK: - Properties

    @Bindable var store: StoreOf<TermsOfServiceFeature>
    @Environment(\.dismiss) private var dismiss

    // MARK: - Init

    public init(store: StoreOf<TermsOfServiceFeature>) {
        self.store = store
    }

    // MARK: - Body

    public var body: some View {
        content
            .task { store.send(.onAppear) }
            .baziNavigationBar_backWithTitle("서비스 이용약관") {
                dismiss()
            }
    }
}

// MARK: - Subviews

extension TermsOfServiceView {

    private var content: some View {
        ScrollView {
            Text(Self.termsText)
                .baziFont(.small14R)
                .foregroundStyle(Color.gray700)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
        }
        .baziBackground(.bgWhite)
    }

    // TODO: 법무 검토가 끝난 실제 약관 문구가 준비되면 교체한다.
    private static let termsText = """
    제1조 (목적)
    이 약관은 청바지(이하 "회사")가 제공하는 청년 정책 추천 서비스(이하 "서비스")의 이용과 관련하여 회사와 이용자의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.

    제2조 (정의)
    1. "서비스"란 회사가 제공하는 청년 정책 정보 조회, 추천, 알림 등 일체의 서비스를 의미합니다.
    2. "이용자"란 이 약관에 따라 회사가 제공하는 서비스를 이용하는 회원을 말합니다.

    제3조 (약관의 효력 및 변경)
    1. 이 약관은 서비스를 이용하고자 하는 모든 이용자에게 효력을 발생합니다.
    2. 회사는 관련 법령을 위반하지 않는 범위에서 이 약관을 변경할 수 있으며, 변경된 약관은 서비스 내 공지사항을 통해 공지합니다.

    제4조 (서비스의 제공 및 변경)
    1. 회사는 이용자에게 정책 정보 조회, 맞춤 추천, 마감 알림 등의 서비스를 제공합니다.
    2. 회사는 서비스의 내용을 변경할 경우 사전에 공지합니다.

    제5조 (회원가입 및 탈퇴)
    1. 이용자는 회사가 정한 절차에 따라 회원가입을 신청할 수 있습니다.
    2. 이용자는 언제든지 서비스 내 설정을 통해 탈퇴를 요청할 수 있으며, 회사는 관련 법령이 정하는 바에 따라 이를 처리합니다.

    제6조 (개인정보보호)
    회사는 관련 법령이 정하는 바에 따라 이용자의 개인정보를 보호하기 위해 노력하며, 개인정보의 처리에 관한 세부 사항은 개인정보 처리방침에서 별도로 정합니다.

    제7조 (책임의 제한)
    회사는 천재지변, 서비스 제공자의 귀책사유 없는 통신 장애 등 불가항력으로 인해 서비스를 제공할 수 없는 경우 책임이 면제됩니다.
    """
}

// MARK: - Preview

#Preview {
    NavigationStack {
        TermsOfServiceView(
            store: Store(initialState: .init()) {
                TermsOfServiceFeature()
            }
        )
    }
}

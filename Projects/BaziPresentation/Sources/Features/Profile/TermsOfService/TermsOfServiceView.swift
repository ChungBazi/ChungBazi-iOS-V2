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
                .foregroundStyle(Color.gray800)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
        }
        .baziBackground(.bgWhite)
    }

    private static let termsText = """
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

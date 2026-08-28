// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import BaziDesign
import ComposableArchitecture

public struct NotificationSettingView: View {

    // MARK: - Properties

    @Bindable var store: StoreOf<NotificationSettingFeature>
    @Environment(\.dismiss) private var dismiss

    // MARK: - Init

    public init(store: StoreOf<NotificationSettingFeature>) {
        self.store = store
    }

    // MARK: - Body

    public var body: some View {
        content
            .task { store.send(.onAppear) }
            .baziNavigationBar_backWithTitle("알림 설정") {
                dismiss()
            }
    }
}

// MARK: - Subviews

extension NotificationSettingView {

    private var content: some View {
        VStack(spacing: 0) {
            row(
                title: "전체 알림",
                description: "내 정책 알림과 청바지 알림을 포함한 앱 내 모든 알림을 받아볼 수 있어요.",
                isOn: Binding(
                    get: { store.isAllNotificationOn },
                    set: { store.send(.didToggleAllNotification($0)) }
                )
            )
            row(
                title: "내 정책 알림",
                description: "내가 찜한 정책의 신청 일정, 마감일, 정책 변경 사항 등 필요한 알림을 받아보세요.",
                isOn: Binding(
                    get: { store.isMyPolicyNotificationOn },
                    set: { store.send(.didToggleMyPolicyNotification($0)) }
                )
            )
            row(
                title: "청바지 알림",
                description: "새롭게 등록된 정책, 추천 정책, 인기 정책 등 다양한 청바지의 소식을 받아보세요.",
                isOn: Binding(
                    get: { store.isChungBaziNotificationOn },
                    set: { store.send(.didToggleChungBaziNotification($0)) }
                )
            )
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .baziBackground(.bgWhite)
    }

    private func row(title: String, description: String, isOn: Binding<Bool>) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .baziFont(.body16SB)
                    .foregroundStyle(Color.gray900)
                Text(description)
                    .baziFont(.small14R)
                    .foregroundStyle(Color.gray500)
            }
            Spacer(minLength: 30)
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(Color.bazi(.primary))
        }
        .padding(.vertical, 18)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        NotificationSettingView(
            store: Store(initialState: .init()) {
                NotificationSettingFeature()
            }
        )
    }
}

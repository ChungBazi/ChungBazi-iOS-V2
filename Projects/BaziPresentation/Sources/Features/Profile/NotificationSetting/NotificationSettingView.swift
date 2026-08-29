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
                ProfileConstants.NotificationText.all,
                isOn: Binding(
                    get: { store.isAllNotificationOn },
                    set: { store.send(.didToggleAllNotification($0)) }
                )
            )
            row(
                ProfileConstants.NotificationText.myPolicy,
                isOn: Binding(
                    get: { store.isMyPolicyNotificationOn },
                    set: { store.send(.didToggleMyPolicyNotification($0)) }
                )
            )
            .disabled(!store.isAllNotificationOn)
            .opacity(store.isAllNotificationOn ? 1 : 0.4)
            row(
                ProfileConstants.NotificationText.chungBazi,
                isOn: Binding(
                    get: { store.isChungBaziNotificationOn },
                    set: { store.send(.didToggleChungBaziNotification($0)) }
                )
            )
            .disabled(!store.isAllNotificationOn)
            .opacity(store.isAllNotificationOn ? 1 : 0.4)
        }
        .disabled(!store.hasLoaded)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .baziBackground(.bgWhite)
    }

    private func row(_ text: ProfileConstants.NotificationText.Item, isOn: Binding<Bool>) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(text.title)
                    .baziFont(.body16SB)
                    .foregroundStyle(Color.gray900)
                Text(text.description)
                    .baziFont(.small14R)
                    .foregroundStyle(Color.gray500)
            }
            Spacer(minLength: 30)
            Toggle(text.title, isOn: isOn)
                .labelsHidden()
                .tint(Color.bazi(.primary))
                .accessibilityLabel(text.title)
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

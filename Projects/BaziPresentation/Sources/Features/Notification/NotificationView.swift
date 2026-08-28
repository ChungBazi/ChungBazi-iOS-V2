// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import BaziDesign
import ComposableArchitecture

public struct NotificationView: View {

    // MARK: - Properties

    @Bindable var store: StoreOf<NotificationFeature>
    @Environment(\.dismiss) private var dismiss

    // MARK: - Init

    public init(store: StoreOf<NotificationFeature>) {
        self.store = store
    }

    // MARK: - Body

    public var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            content
                .task { store.send(.onAppear) }
                .baziNavigationBar_backWithTitleAndTextButton(
                    "알림",
                    buttonTitle: "전체 삭제",
                    onBack: { dismiss() },
                    onButtonTap: { store.send(.didTapDeleteAll) }
                )
                .baziAlert(
                    isPresented: Binding(
                        get: { store.isDeleteAllConfirmPresented },
                        set: { store.send(.didSetDeleteAllConfirm($0)) }
                    ),
                    title: "모든 알림을 삭제할까요?",
                    message: "삭제된 알림은 다시 복구할 수 없어요",
                    confirmTitle: "삭제하기",
                    confirmType: .accent,
                    onConfirm: { store.send(.didConfirmDeleteAll) }
                )
        } destination: { store in
            switch store.case {
            case .detail(let store):
                PolicyDetailView(store: store)
            }
        }
    }
}

// MARK: - Subviews

extension NotificationView {

    private var content: some View {
        VStack(spacing: 0) {
            tabBar
            if store.visibleNotifications.isEmpty {
                emptyState
            } else {
                notificationList
            }
        }
        .baziBackground(.bgGray)
    }

    private var tabBar: some View {
        BZSegmentControl(
            options: NotificationTab.allCases.map(\.rawValue),
            selection: tabSelection
        ) { _ in EmptyView() }
        .baziBackground(.bgWhite)
    }

    private var tabSelection: Binding<String> {
        Binding(
            get: { store.selectedTab.rawValue },
            set: { newValue in
                guard let tab = NotificationTab(rawValue: newValue) else { return }
                store.send(.didSelectTab(tab))
            }
        )
    }

    private var notificationList: some View {
        List {
            ForEach(Array(store.visibleNotifications.enumerated()), id: \.element.id) { index, notification in
                BZAlarmCard(
                    icon: notification.kind.iconType,
                    title: notification.title,
                    message: notification.message,
                    timeAgo: notification.elapsedTime
                )
                .listRowInsets(EdgeInsets(
                    top: index == 0 ? 20 : 6,
                    leading: 20,
                    bottom: index == store.visibleNotifications.count - 1 ? 20 : 6,
                    trailing: 20
                ))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .contentShape(Rectangle())
                .onTapGesture { store.send(.didTapNotification(id: notification.id)) }
                .baziAlarmCardSwipeToDelete {
                    store.send(.didSwipeDelete(id: notification.id))
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private var emptyState: some View {
        BZEmptyView(message: "알림이 비어 있어요")
            .frame(maxHeight: .infinity)
    }
}

// MARK: - Preview

#Preview("전체") {
    NotificationView(
        store: Store(initialState: .init()) {
            NotificationFeature()
        }
    )
}

#Preview("비어 있음") {
    var state = NotificationFeature.State()
    state.notifications = []

    return NotificationView(
        store: Store(initialState: state) {
            EmptyReducer()
        }
    )
}

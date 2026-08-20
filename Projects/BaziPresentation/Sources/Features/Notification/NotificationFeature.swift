// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import ComposableArchitecture

/// 알림 목록 화면 (33). 홈에서 진입하며, 모든 알림 카드는 정책 상세로 이동한다.
@Reducer
public struct NotificationFeature {

    // MARK: - Navigation

    @Reducer
    public enum Path {
        case detail(PolicyDetailFeature)
    }

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var path = StackState<Path.State>()

        public var selectedTab: NotificationTab
        public var notifications: IdentifiedArrayOf<NotificationItem>
        public var isDeleteAllConfirmPresented: Bool

        public var visibleNotifications: IdentifiedArrayOf<NotificationItem> {
            selectedTab == .all
                ? notifications
                : IdentifiedArray(uniqueElements: notifications.filter { $0.kind.tab == selectedTab })
        }

        public init() {
            self.selectedTab = .all
            self.notifications = []
            self.isDeleteAllConfirmPresented = false
        }
    }

    // MARK: - Action

    public enum Action {
        // MARK: View
        case onAppear
        case didSelectTab(NotificationTab)
        case didTapNotification(id: Int)
        case didSwipeDelete(id: Int)
        case didTapDeleteAll
        case didSetDeleteAllConfirm(Bool)
        case didConfirmDeleteAll

        // MARK: Child
        case path(StackActionOf<Path>)
    }

    // MARK: - Dependencies

    // TODO: BaziDomain의 알림 UseCase가 준비되면 추가
    // @Dependency(\.notificationClient) var notificationClient

    // MARK: - Init

    public init() {}

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                // TODO: notificationClient가 준비되면 NotificationAPI.getNotifications 응답으로 교체한다.
                state.notifications = IdentifiedArray(uniqueElements: NotificationItem.mockList)
                return .none

            case .didSelectTab(let tab):
                state.selectedTab = tab
                return .none

            case .didTapNotification(let id):
                guard let notification = state.notifications[id: id] else { return .none }
                state.notifications[id: id]?.isRead = true
                state.path.append(.detail(PolicyDetailFeature.State(policyId: notification.policyId)))
                return .none

            case .didSwipeDelete(let id):
                state.notifications.remove(id: id)
                return .none

            case .didTapDeleteAll:
                guard !state.notifications.isEmpty else { return .none }
                state.isDeleteAllConfirmPresented = true
                return .none

            case .didSetDeleteAllConfirm(let isPresented):
                state.isDeleteAllConfirmPresented = isPresented
                return .none

            case .didConfirmDeleteAll:
                state.notifications.removeAll()
                return .none

            case .path(.element(_, .detail(.delegate(.didSelectPolicy(let id))))):
                state.path.append(.detail(PolicyDetailFeature.State(policyId: id)))
                return .none

            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

extension NotificationFeature.Path.State: Equatable {}

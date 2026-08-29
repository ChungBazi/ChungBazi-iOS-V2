// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziDomain
import ComposableArchitecture

/// 알림 목록 화면. 홈에서 진입하며, 모든 알림 카드는 정책 상세로 이동한다.
/// 탭 필터와 페이지네이션은 서버가 처리한다(로컬 필터 금지 — 페이지가 잘려 있으면 필터가 불완전해진다).
@Reducer
public struct NotificationFeature {

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var selectedTab: NotificationTab = .all
        public var notifications: LoadingState<IdentifiedArrayOf<NotificationItemVO>> = .idle
        public var pagination = PaginationState<Int>()
        public var isDeleteAllConfirmPresented = false

        public init() {}
    }

    // MARK: - Action

    public enum Action {
        // MARK: View
        case onAppear
        case didTapRetry
        case pullToRefresh
        case didSelectTab(NotificationTab)
        case didReachListEnd
        case didTapNotification(id: Int)
        case didSwipeDelete(id: Int)
        case didTapDeleteAll
        case didSetDeleteAllConfirm(Bool)
        case didConfirmDeleteAll

        // MARK: Internal
        case pageResponse(Result<NotificationPageVO, UseCaseError>, isFirstPage: Bool)
        /// 삭제 요청 실패 → 서버 상태로 재동기화한다.
        case commandFailed

        // MARK: Delegate
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case didSelectPolicy(id: Int)
        }
    }

    // MARK: - Dependencies

    @Dependency(\.notificationClient) var notificationClient

    // MARK: - Init

    public init() {}

    private static let pageSize = 20

    private enum CancelID { case list }

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear, .didTapRetry:
                return loadFirstPage(&state)

            case .pullToRefresh:
                // 당김 새로고침: .loading으로 바꾸지 않고 현재 탭 1페이지를 다시 가져온다.
                return fetchPage(category: state.selectedTab.serverCategory, cursor: nil, isFirstPage: true)

            case .didSelectTab(let tab):
                guard tab != state.selectedTab else { return .none }
                state.selectedTab = tab
                state.pagination.reset()
                state.notifications = .loading
                return fetchPage(category: tab.serverCategory, cursor: nil, isFirstPage: true)

            case .didReachListEnd:
                guard state.pagination.canLoadNext, state.notifications.value != nil else { return .none }
                state.pagination.isLoadingNext = true
                return fetchPage(category: state.selectedTab.serverCategory, cursor: state.pagination.nextCursor, isFirstPage: false)

            case let .pageResponse(.success(page), isFirstPage):
                if isFirstPage {
                    state.notifications = .loaded(page.items)
                } else {
                    var items = state.notifications.value ?? []
                    items.append(contentsOf: page.items)
                    state.notifications = .loaded(items)
                }
                state.pagination.apply(page)
                return .none

            case let .pageResponse(.failure(error), isFirstPage):
                state.pagination.isLoadingNext = false
                if isFirstPage, state.notifications.value == nil {
                    state.notifications = .failed(error.loadFailureMessage)
                }
                return .none

            case .didTapNotification(let id):
                guard let notification = state.notifications.value?[id: id] else { return .none }
                // 읽음 처리는 서버가 조회 시점에 하므로, 상세 이동은 부모(홈 스택)에 위임한다.
                return .send(.delegate(.didSelectPolicy(id: notification.policyId)))

            case .didSwipeDelete(let id):
                guard state.notifications.value?[id: id] != nil else { return .none }
                removeNotification(&state, id: id)
                // 삭제로 현재 목록이 비었는데 다음 페이지가 남아 있으면, 빈 화면 대신 다음 페이지를 이어서 불러온다.
                if state.notifications.value?.isEmpty == true, state.pagination.canLoadNext {
                    state.pagination.isLoadingNext = true
                    return .merge(
                        deleteEffect(id: id),
                        fetchPage(category: state.selectedTab.serverCategory, cursor: state.pagination.nextCursor, isFirstPage: false)
                    )
                }
                return deleteEffect(id: id)

            case .didTapDeleteAll:
                guard let items = state.notifications.value, !items.isEmpty else { return .none }
                state.isDeleteAllConfirmPresented = true
                return .none

            case .didSetDeleteAllConfirm(let isPresented):
                state.isDeleteAllConfirmPresented = isPresented
                return .none

            case .didConfirmDeleteAll:
                state.notifications = .loaded([])
                state.pagination.reset()
                return deleteAllEffect()

            case .commandFailed:
                // 삭제 실패 → 현재 탭 1페이지로 재동기화(로딩 표시 없이 목록만 교체).
                return fetchPage(category: state.selectedTab.serverCategory, cursor: nil, isFirstPage: true)

            case .delegate:
                return .none
            }
        }
    }

    // MARK: - Private

    /// 최초 진입/재시도 로드. 이미 로딩 중이거나 로드 완료면 재요청하지 않는다.
    private func loadFirstPage(_ state: inout State) -> Effect<Action> {
        if state.notifications.isLoading || state.notifications.value != nil { return .none }
        state.pagination.reset()
        state.notifications = .loading
        return fetchPage(category: state.selectedTab.serverCategory, cursor: nil, isFirstPage: true)
    }

    private func fetchPage(category: String?, cursor: Int?, isFirstPage: Bool) -> Effect<Action> {
        .run { [notificationClient] send in
            do {
                let page = try await notificationClient.fetch(category, cursor, Self.pageSize)
                await send(.pageResponse(.success(page), isFirstPage: isFirstPage))
            } catch {
                await send(.pageResponse(.failure(UseCaseError.map(error)), isFirstPage: isFirstPage))
            }
        }
        .cancellable(id: CancelID.list, cancelInFlight: true)
    }

    private func deleteEffect(id: Int) -> Effect<Action> {
        .run { [notificationClient] send in
            do {
                try await notificationClient.delete(id)
            } catch {
                await send(.commandFailed)
            }
        }
    }

    private func deleteAllEffect() -> Effect<Action> {
        .run { [notificationClient] send in
            do {
                try await notificationClient.deleteAll()
            } catch {
                await send(.commandFailed)
            }
        }
    }

    private func removeNotification(_ state: inout State, id: Int) {
        guard var items = state.notifications.value else { return }
        items.remove(id: id)
        state.notifications = .loaded(items)
    }
}

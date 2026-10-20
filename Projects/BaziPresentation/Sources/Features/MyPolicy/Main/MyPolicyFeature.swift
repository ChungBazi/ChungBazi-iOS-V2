// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziDomain
import ComposableArchitecture

@Reducer
public struct MyPolicyFeature {

    // MARK: - Navigation

    @Reducer
    public enum Path {
        case policyList(MyPolicyListFeature)
        case calendar(CalendarFeature)
        case memo(PolicyMemoFeature)
        case detail(PolicyDetailFeature)
        case categoryPolicyList(CategoryPolicyListFeature)
    }

    // MARK: - Tab

    public enum Tab: CaseIterable, Equatable, Sendable {
        case policy
        case openEnded

        var title: String {
            switch self {
            case .policy: return "정책"
            case .openEnded: return "상시모집"
            }
        }
    }

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var path = StackState<Path.State>()

        public var deadlineTeaser: IdentifiedArrayOf<PolicySummaryVO>
        /// 티저 조회 실패 여부. 실패 시 기존 티저를 지우지 않고 이 플래그로 빈-상태 배너 오표시를 막는다.
        public var teaserLoadFailed = false
        /// 다른 화면에서 찜 해제된 정책은 목록에서 제외하기 위한 공유 오버레이(id → liked).
        @Shared(.likeOverrides) public var likeOverrides: [Int: Bool] = [:]
        /// 주간 스트립의 중심(항상 오늘). onAppear에서 주입된 `date.now` 기준으로 설정된다. (init 값은 placeholder)
        public var today: Date
        public var selectedDate: Date
        public var selectedTab: Tab

        // 탭별 목록을 각각 State에 보관해 탭 왕복 시 재조회하지 않는다(UI 상태).
        // 정책 탭: 선택 날짜 기준 2주 내 마감(정렬·페이지네이션 없음). 상시모집 탭: 날짜 무관, 진입 시 함께 조회.
        public var datePolicies: LoadingState<IdentifiedArrayOf<PolicySummaryVO>> = .idle
        /// 정책 탭 서버 총개수(비페이지네이션이라 목록 길이와 같으나, 서버 값을 그대로 쓴다).
        public var datePoliciesTotalCount = 0
        /// datePolicies가 로드된 날짜. 선택 날짜가 이와 다르면 정책 탭 진입 시 재조회한다.
        public var loadedDate: Date?
        public var openEndedPolicies: LoadingState<IdentifiedArrayOf<PolicySummaryVO>> = .idle
        public var openEndedPagination = PaginationState<String>()

        /// onAppear에서 today/selectedDate를 주입된 오늘로 최초 1회만 맞추기 위한 가드.
        public var didLoad = false

        /// 마지막 조회 시점의 좋아요 오버레이 스냅샷. 다른 화면에서 찜이 바뀌면(신규 찜 포함)
        /// 재진입 시 이 값과 달라져 목록 재조회를 트리거한다.
        public var lastSyncedLikeOverrides: [Int: Bool] = [:]

        /// 현재 탭 기준 목록(뷰용 파생).
        public var currentPolicies: LoadingState<IdentifiedArrayOf<PolicySummaryVO>> {
            selectedTab == .policy ? datePolicies : openEndedPolicies
        }
        public var currentTotalCount: Int {
            // 정책 탭은 비페이지네이션 서버 총개수, 상시모집은 페이지네이션 총개수.
            let base = selectedTab == .policy
                ? datePoliciesTotalCount
                : openEndedPagination.totalCount
            // 다른 화면에서 찜 해제(overlay == false)돼 목록에서 숨겨진 카드 수만큼 뺀다.
            let hidden = (currentPolicies.value ?? []).filter { likeOverrides[$0.id] == false }.count
            return max(0, base - hidden)
        }

        /// 오늘을 중심으로 앞뒤 3일씩, 총 7일. 좌우 스크롤 없이 이 범위 안에서만 날짜를 고를 수 있다.
        public var weekDates: [Date] {
            let calendar = Calendar.current
            return (-3...3).compactMap { calendar.date(byAdding: .day, value: $0, to: today) }
        }

        public init() {
            let today = Calendar.current.startOfDay(for: Date())
            self.deadlineTeaser = []
            self.today = today
            self.selectedDate = today
            self.selectedTab = .policy
        }
    }

    // MARK: - Action

    // PolicyDetailFeature.Action이 Equatable이 아니어서(Home Path와 동일) Action에는 Equatable을 채택하지 않는다.
    public enum Action {
        // MARK: View
        case onAppear
        case didTapHeaderMore
        case didTapCalendarIcon
        case didSelectWeekDate(Date)
        case didSelectTab(Tab)
        case didTapRetry
        case pullToRefresh
        case didReachListEnd
        case didTapPolicy(id: Int)
        case didTapMemo(id: Int)
        case didTapEmptyBannerCTA

        // MARK: Internal
        case teaserResponse(Result<[PolicySummaryVO], UseCaseError>)
        /// 정책 탭: 2주 내 마감 목록(페이지네이션 없음, 총개수 포함).
        case datePoliciesResponse(Result<PolicyPageVO, UseCaseError>)
        /// 상시모집 탭: 커서 페이지네이션 목록.
        case openEndedResponse(Result<PolicyPageVO, UseCaseError>, isFirstPage: Bool)

        // MARK: Child
        case path(StackActionOf<Path>)
    }

    // MARK: - Dependencies

    @Dependency(\.myPolicyClient) var myPolicyClient
    @Dependency(\.date.now) var now
    @Dependency(\.calendar) var calendar
    @Dependency(\.analytics) var analytics

    // MARK: - Init

    public init() {}

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                let screenView = Effect<Action>.run { [analytics] _ in analytics.track(.screenView(.myPolicy)) }
                // 최초 1회: 오늘 기준으로 맞추고 로드한다.
                if !state.didLoad {
                    state.didLoad = true
                    let today = calendar.startOfDay(for: now)
                    state.today = today
                    state.selectedDate = today
                    state.lastSyncedLikeOverrides = state.likeOverrides
                    return .merge(loadTeaser(), reloadDatePolicies(&state), reloadOpenEnded(&state), screenView)
                }
                // 재진입: 신규 찜(추가)이 생겼을 때만 재조회한다.
                // 해제는 overlay 필터가 반응형으로 처리하므로 재조회가 필요 없고, 추가만 목록에 없어 서버 재조회가 필요하다.
                let overrides = state.likeOverrides
                let synced = state.lastSyncedLikeOverrides
                let hasNewLike = overrides.contains { $0.value && synced[$0.key] != true }
                state.lastSyncedLikeOverrides = overrides
                guard hasNewLike else { return screenView }
                // 신규 찜이 정책/상시 어느 탭이든 진입 즉시 보이도록 티저 + 두 탭 모두 재조회(.loading 없이 → 깜빡임 방지).
                return .merge(
                    loadTeaser(),
                    fetchDatePolicies(state: state),
                    fetchOpenEnded(state: state, isFirstPage: true),
                    screenView
                )

            case .didTapRetry:
                // 실패 화면의 재시도 — 현재 탭에 맞춰 재조회한다(상시모집 탭 복구 포함).
                switch state.selectedTab {
                case .policy: return reloadDatePolicies(&state)
                case .openEnded: return reloadOpenEnded(&state)
                }

            case .didTapHeaderMore:
                state.path.append(.policyList(MyPolicyListFeature.State()))
                return .run { [analytics] _ in
                    analytics.track(.policyListView(listType: .myPolicy, entryPoint: .myPolicyMore, category: nil))
                }

            case .didTapCalendarIcon:
                // 진입 직후에는 항상 오늘 기준 달이 보여야 한다(선택된 날짜가 오늘과 다른 달일 수 있는
                // 주 경계 근처 예외를 없애기 위해 selectedDate가 아닌 today를 기준으로 연다).
                state.path.append(.calendar(CalendarFeature.State(centerDate: state.today)))
                return .none

            case .didSelectWeekDate(let date):
                guard date != state.selectedDate else { return .none }
                state.selectedDate = date
                // 상시모집은 날짜와 무관하므로 정책 탭에서만 재조회한다.
                return state.selectedTab == .policy ? reloadDatePolicies(&state) : .none

            case .didSelectTab(let tab):
                guard tab != state.selectedTab else { return .none }
                state.selectedTab = tab
                switch tab {
                case .policy:
                    // 로드된 날짜와 선택 날짜가 다르거나 아직 없으면 재조회, 아니면 캐시(State) 사용.
                    guard state.loadedDate != state.selectedDate || state.datePolicies.value == nil else { return .none }
                    return reloadDatePolicies(&state)
                case .openEnded:
                    // 상시모집은 진입 시 이미 조회됨(State 캐시 재사용). 미조회 상태일 때만 방어적으로 조회한다.
                    guard state.openEndedPolicies.value == nil, !state.openEndedPolicies.isLoading else { return .none }
                    return reloadOpenEnded(&state)
                }

            case .pullToRefresh:
                // 당김 새로고침: .loading으로 바꾸지 않고 티저 + 현재 탭을 다시 가져온다.
                let listReload: Effect<Action> = state.selectedTab == .policy
                    ? fetchDatePolicies(state: state)
                    : fetchOpenEnded(state: state, isFirstPage: true)
                return .merge(loadTeaser(), listReload)

            case .didReachListEnd:
                // 무한스크롤은 상시모집 탭에만 있다. 정책 탭은 2주 내 마감 단순 목록이라 페이지네이션이 없다.
                guard state.selectedTab == .openEnded,
                      state.openEndedPagination.canLoadNext,
                      state.openEndedPolicies.value != nil else { return .none }
                state.openEndedPagination.isLoadingNext = true
                return fetchOpenEnded(state: state, isFirstPage: false)

            case .teaserResponse(.success(let policies)):
                state.teaserLoadFailed = false
                state.deadlineTeaser = IdentifiedArray(deduplicating: policies)
                return .none

            case .teaserResponse(.failure):
                // 네트워크 실패 시 기존 티저를 유지하고 플래그만 세운다(찜 없음 오표시 방지).
                state.teaserLoadFailed = true
                return .none

            case .datePoliciesResponse(.success(let page)):
                state.datePolicies = .loaded(page.policies)
                state.datePoliciesTotalCount = page.totalCount
                state.loadedDate = state.selectedDate
                return .none

            case .datePoliciesResponse(.failure(let error)):
                if state.datePolicies.value == nil {
                    state.datePolicies = .failed(error.loadFailureMessage)
                }
                return .none

            case let .openEndedResponse(.success(page), isFirstPage):
                state.openEndedPagination.apply(page)
                if isFirstPage {
                    state.openEndedPolicies = .loaded(page.policies)
                } else {
                    var current = state.openEndedPolicies.value ?? []
                    current.append(contentsOf: page.policies)
                    state.openEndedPolicies = .loaded(current)
                }
                return .none

            case let .openEndedResponse(.failure(error), isFirstPage):
                if isFirstPage {
                    if state.openEndedPolicies.value == nil { state.openEndedPolicies = .failed(error.loadFailureMessage) }
                } else {
                    state.openEndedPagination.isLoadingNext = false
                }
                return .none

            case .didTapPolicy(let id):
                return pushDetail(id: id, entryPoint: .myPolicy, state: &state)

            case .didTapMemo(let id):
                state.path.append(.memo(PolicyMemoFeature.State(policyId: id)))
                return .none

            case .didTapEmptyBannerCTA:
                // 찜한 정책이 없을 때 → 분야별 정책(취업·창업)으로 둘러보러 이동.
                state.path.append(.categoryPolicyList(CategoryPolicyListFeature.State(selectedCategory: .job)))
                return .run { [analytics] _ in
                    analytics.track(.policyListView(listType: .category, entryPoint: .myPolicyEmptyCTA, category: PolicyCategoryUI.job.rawValue))
                }

            case let .path(.element(_, .policyList(.delegate(.didSelectPolicy(id))))):
                return pushDetail(id: id, entryPoint: .myPolicyMore, state: &state)
            case let .path(.element(_, .calendar(.delegate(.didSelectPolicy(id))))):
                return pushDetail(id: id, entryPoint: .calendar, state: &state)
            case let .path(.element(_, .detail(.delegate(.didSelectPolicy(id))))):
                return pushDetail(id: id, entryPoint: .recommendation, state: &state)
            case let .path(.element(_, .categoryPolicyList(.delegate(.didSelectPolicy(id))))):
                return pushDetail(id: id, entryPoint: .myPolicy, state: &state)

            case .path(.element(_, .calendar(.delegate(.didTapMemo(let policyId))))):
                state.path.append(.memo(PolicyMemoFeature.State(policyId: policyId)))
                return .none

            case .path(.element(_, .memo(.delegate(.didSaveMemo)))):
                // TODO: 서버 연결 시 저장된 메모를 목록/티저에 반영한다. (현재는 별도 갱신 없음)
                return .none

            case let .path(.element(_, .policyList(.delegate(.browsePolicies(category))))):
                // 전체보기 빈 상태 "둘러보러 가기" → 선택한 분야의 분야별 정책(미선택 시 취업·창업).
                let selected = category ?? .job
                state.path.append(.categoryPolicyList(CategoryPolicyListFeature.State(selectedCategory: selected)))
                return .run { [analytics] _ in
                    analytics.track(.policyListView(listType: .category, entryPoint: .myPolicyEmptyCTA, category: selected.rawValue))
                }

            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }

    // MARK: - Private

    private enum CancelID: Hashable { case datePolicies, openEnded }

    private static let pageSize = 20

    /// 정책 상세로 push하며 진입 경로와 함께 policy_detail_view를 기록한다.
    private func pushDetail(id: Int, entryPoint: EntryPoint, state: inout State) -> Effect<Action> {
        state.path.append(.detail(PolicyDetailFeature.State(policyId: id)))
        return .run { [analytics] _ in
            analytics.track(.policyDetailView(policyId: id, policyName: nil, category: nil, entryPoint: entryPoint))
        }
    }

    private func loadTeaser() -> Effect<Action> {
        .run { [myPolicyClient] send in
            do {
                let policies = try await myPolicyClient.fetchDeadlineTeaser()
                await send(.teaserResponse(.success(policies)))
            } catch {
                await send(.teaserResponse(.failure(UseCaseError.map(error))))
            }
        }
    }

    /// 정책 탭: 선택 날짜 기준 2주 내 마감 목록을 다시 조회(로딩 표시).
    private func reloadDatePolicies(_ state: inout State) -> Effect<Action> {
        state.datePolicies = .loading
        return fetchDatePolicies(state: state)
    }

    private func fetchDatePolicies(state: State) -> Effect<Action> {
        let targetDate = targetDateString(state.selectedDate)
        return .run { [myPolicyClient] send in
            do {
                let page = try await myPolicyClient.fetchDeadlineUpcoming(targetDate)
                await send(.datePoliciesResponse(.success(page)))
            } catch {
                await send(.datePoliciesResponse(.failure(UseCaseError.map(error))))
            }
        }
        .cancellable(id: CancelID.datePolicies, cancelInFlight: true)
    }

    /// 상시모집 탭: 1페이지부터 재조회.
    private func reloadOpenEnded(_ state: inout State) -> Effect<Action> {
        state.openEndedPolicies = .loading
        state.openEndedPagination.reset()
        return fetchOpenEnded(state: state, isFirstPage: true)
    }

    private func fetchOpenEnded(state: State, isFirstPage: Bool) -> Effect<Action> {
        let cursor = isFirstPage ? nil : state.openEndedPagination.nextCursor
        return .run { [myPolicyClient] send in
            do {
                let page = try await myPolicyClient.fetchOpenEnded(cursor, Self.pageSize)
                await send(.openEndedResponse(.success(page), isFirstPage: isFirstPage))
            } catch {
                await send(.openEndedResponse(.failure(UseCaseError.map(error)), isFirstPage: isFirstPage))
            }
        }
        .cancellable(id: CancelID.openEnded, cancelInFlight: true)
    }

    /// 주입된 calendar 기준으로 "yyyy-MM-dd" 문자열을 만든다(서버 targetDate 파라미터용).
    private func targetDateString(_ date: Date) -> String {
        BaziDateFormat.serverDayString(date, calendar: calendar)
    }
}

extension MyPolicyFeature.Path.State: Equatable {}

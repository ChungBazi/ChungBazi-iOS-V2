// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import ComposableArchitecture

@Reducer
public struct MyPolicyFeature {

    // MARK: - Navigation

    @Reducer
    public enum Path {
        case policyList(MyPolicyListFeature)
        case calendar(CalendarFeature)
        case memo(PolicyMemoFeature)
        // TODO: 정책 목록이 서버에 연결되면 case detail(PolicyDetailFeature)로 상세 화면을 연결한다.
    }

    // MARK: - Tab

    public enum Tab: String, CaseIterable, Equatable {
        case policy = "정책"
        case openEnded = "상시모집"
    }

    // MARK: - SortOrder

    public enum SortOrder: String, Equatable {
        case deadline = "마감순"
        case latest = "최신순"

        var next: SortOrder { self == .deadline ? .latest : .deadline }
    }

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var path = StackState<Path.State>()

        public var deadlineTeaser: IdentifiedArrayOf<PolicySummary>
        /// 주간 스트립의 중심(항상 오늘). onAppear에서 주입된 `date.now` 기준으로 설정된다. (init 값은 placeholder)
        public var today: Date
        public var selectedDate: Date
        public var selectedTab: Tab
        public var sortOrder: SortOrder
        public var policies: IdentifiedArrayOf<PolicySummary>
        /// onAppear에서 today/selectedDate를 주입된 오늘로 최초 1회만 맞추기 위한 가드.
        public var didLoad = false

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
            self.sortOrder = .deadline
            self.policies = []
        }
    }

    // MARK: - Action

    public enum Action {
        // MARK: View
        case onAppear
        case didTapHeaderMore
        case didTapCalendarIcon
        case didSelectWeekDate(Date)
        case didSelectTab(Tab)
        case didTapSortOrder
        case didTapPolicy(id: Int)
        case didTapMemo(id: Int)
        case didTapEmptyBannerCTA

        // MARK: Child
        case path(StackActionOf<Path>)
    }

    // MARK: - Dependencies

    @Dependency(\.date.now) var now
    @Dependency(\.calendar) var calendar
    // TODO: BaziDomain의 내 정책 UseCase가 준비되면 추가
    // @Dependency(\.myPolicyClient) var myPolicyClient

    // MARK: - Init

    public init() {}

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                // 주입된 date.now 기준으로 오늘을 최초 1회 설정한다. (재진입 시엔 선택된 날짜 유지)
                if !state.didLoad {
                    state.didLoad = true
                    let today = calendar.startOfDay(for: now)
                    state.today = today
                    state.selectedDate = today
                }
                // TODO: myPolicyClient가 준비되면 MyPolicyAPI 응답으로 교체한다.
                state.deadlineTeaser = IdentifiedArray(uniqueElements: Array(PolicySummary.mockList.prefix(2)))
                state.policies = policies(tab: state.selectedTab, date: state.selectedDate, sortOrder: state.sortOrder)
                return .none

            case .didTapHeaderMore:
                state.path.append(.policyList(MyPolicyListFeature.State()))
                return .none

            case .didTapCalendarIcon:
                // 진입 직후에는 항상 오늘 기준 달이 보여야 한다(선택된 날짜가 오늘과 다른 달일 수 있는
                // 주 경계 근처 예외를 없애기 위해 selectedDate가 아닌 today를 기준으로 연다).
                state.path.append(.calendar(CalendarFeature.State(centerDate: state.today)))
                return .none

            case .didSelectWeekDate(let date):
                state.selectedDate = date
                state.policies = policies(tab: state.selectedTab, date: date, sortOrder: state.sortOrder)
                return .none

            case .didSelectTab(let tab):
                state.selectedTab = tab
                state.policies = policies(tab: tab, date: state.selectedDate, sortOrder: state.sortOrder)
                return .none

            case .didTapSortOrder:
                state.sortOrder = state.sortOrder.next
                state.policies = policies(tab: state.selectedTab, date: state.selectedDate, sortOrder: state.sortOrder)
                return .none

            case .didTapPolicy:
                // TODO: 정책 목록 서버 연결 후 PolicyDetailFeature(policyId:)로 상세를 연결한다. (현재는 상세 진입 차단)
                return .none

            case .didTapMemo(let id):
                state.path.append(.memo(PolicyMemoFeature.State(policyId: id)))
                return .none

            case .didTapEmptyBannerCTA:
                // TODO: SharedRoute.policyRecommendationEdit(맞춤 조건 다시 설정) Feature가 준비되면 연결한다.
                return .none

            case .path(.element(_, .policyList(.delegate(.didSelectPolicy)))),
                 .path(.element(_, .calendar(.delegate(.didSelectPolicy)))):
                // TODO: 정책 목록 서버 연결 후 PolicyDetailFeature(policyId:)로 상세를 연결한다. (현재는 상세 진입 차단)
                return .none

            case .path(.element(_, .calendar(.delegate(.didTapMemo(let policyId))))):
                state.path.append(.memo(PolicyMemoFeature.State(policyId: policyId)))
                return .none

            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }

    // MARK: - Private

    private func policies(tab: Tab, date: Date, sortOrder: SortOrder) -> IdentifiedArrayOf<PolicySummary> {
        let filtered: [PolicySummary]
        switch tab {
        case .policy:
            let day = calendar.startOfDay(for: date)
            filtered = PolicySummary.mockList.filter {
                !$0.isOpenEnded && calendar.startOfDay(for: $0.deadlineDate) == day
            }
        case .openEnded:
            filtered = PolicySummary.mockList.filter(\.isOpenEnded)
        }

        let sorted = sortOrder == .deadline
            ? filtered.sorted { $0.deadlineDate < $1.deadlineDate }
            : filtered.sorted { $0.id > $1.id }
        return IdentifiedArray(uniqueElements: sorted)
    }
}

extension MyPolicyFeature.Path.State: Equatable {}

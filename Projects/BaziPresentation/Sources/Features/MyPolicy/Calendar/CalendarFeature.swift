// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import ComposableArchitecture

/// 캘린더 화면 (21). 월별로 스크롤하며 마감일이 있는 날짜를 표시하고,
/// 날짜를 탭하면 그 날짜의 정책 목록을 바텀시트로 보여준다.
/// 정책 상세/메모로의 push는 자체 NavigationStack 없이 상위(MyPolicyFeature)에 위임한다
/// (push된 화면 안에 NavigationStack을 중첩하면 SwiftUI가 `AnyNavigationPath.Error.comparisonTypeMismatch`로 크래시한다).
@Reducer
public struct CalendarFeature: Sendable {

    // MARK: - SortOrder

    public enum SortOrder: String, Equatable {
        case deadline = "마감순"
        case latest = "최신순"

        var next: SortOrder { self == .deadline ? .latest : .deadline }
    }

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var months: [CalendarMonth]
        public var deadlineDates: Set<Date>
        public var selectedDate: Date?
        public var selectedDatePolicies: IdentifiedArrayOf<PolicySummary>
        public var sortOrder: SortOrder
        /// 시트가 실제로 떠 있는지. `selectedDate`와 분리해 두어, 메모/상세로 이동할 때는
        /// 시트만 내리고(`selectedDate`는 유지) 되돌아오면 같은 날짜 시트를 다시 띄울 수 있게 한다.
        public var isDaySheetPresented: Bool
        /// 진입 시점 기준 날짜(내 정책 메인에서 선택돼 있던 날짜). 이 달을 중심으로 처음 열리고,
        /// 무한스크롤은 이 달 기준 상하 24개월까지만 허용한다.
        public let centerDate: Date
        public let earliestMonth: Date
        public let latestMonth: Date

        public init(centerDate: Date = Date()) {
            let calendar = Calendar.current
            let base = calendar.startOfDay(for: centerDate)
            let baseMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: base)) ?? base

            self.months = []
            self.deadlineDates = []
            self.selectedDate = nil
            self.selectedDatePolicies = []
            self.sortOrder = .deadline
            self.isDaySheetPresented = false
            self.centerDate = base
            self.earliestMonth = calendar.date(byAdding: .month, value: -CalendarMonth.scrollableMonthRange, to: baseMonthStart) ?? baseMonthStart
            self.latestMonth = calendar.date(byAdding: .month, value: CalendarMonth.scrollableMonthRange, to: baseMonthStart) ?? baseMonthStart
        }
    }

    // MARK: - Action

    public enum Action {
        // MARK: View
        case onAppear
        case didAppearFirstMonth
        case didAppearLastMonth
        case didSelectDate(Date)
        case didDismissSheet
        case didTapSortOrderInSheet
        case didToggleLikeInSheet(id: Int)
        case didTapPolicyInSheet(id: Int)
        case didTapMemoIcon(id: Int)

        // MARK: Delegate
        case delegate(Delegate)
    }

    // MARK: - Delegate

    public enum Delegate: Equatable {
        case didSelectPolicy(id: Int)
        case didTapMemo(policyId: Int)
    }

    // MARK: - Dependencies

    // TODO: BaziDomain의 내 정책 UseCase가 준비되면 추가
    // @Dependency(\.myPolicyClient) var myPolicyClient
    @Dependency(\.continuousClock) var clock

    // MARK: - Init

    public init() {}

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                // TODO: myPolicyClient가 준비되면 MyPolicyAPI.getCalendar 응답으로 교체한다.
                if state.months.isEmpty {
                    state.months = CalendarMonth.mockMonths(centeredOn: state.centerDate)
                    state.deadlineDates = Set(PolicySummary.mockList.filter { !$0.isOpenEnded }.map {
                        Calendar.current.startOfDay(for: $0.deadlineDate)
                    })
                }
                // 메모/상세로 이동했다 되돌아온 경우, 보고 있던 날짜의 시트를 다시 띄운다.
                if state.selectedDate != nil {
                    state.isDaySheetPresented = true
                }
                return .none

            case .didAppearFirstMonth:
                guard let firstMonth = state.months.first?.firstDayOfMonth, firstMonth > state.earliestMonth else { return .none }
                let newMonths = CalendarMonth.generate(before: firstMonth, monthCount: CalendarMonth.pageSize, notBefore: state.earliestMonth)
                guard !newMonths.isEmpty else { return .none }
                state.months = newMonths + state.months
                return .none

            case .didAppearLastMonth:
                guard let lastMonth = state.months.last?.firstDayOfMonth, lastMonth < state.latestMonth else { return .none }
                let newMonths = CalendarMonth.generate(after: lastMonth, monthCount: CalendarMonth.pageSize, notAfter: state.latestMonth)
                guard !newMonths.isEmpty else { return .none }
                state.months.append(contentsOf: newMonths)
                return .none

            case .didSelectDate(let date):
                state.selectedDate = date
                state.selectedDatePolicies = policies(on: date, sortOrder: state.sortOrder)
                state.isDaySheetPresented = true
                return .none

            case .didDismissSheet:
                state.isDaySheetPresented = false
                state.selectedDate = nil
                return .none

            case .didTapSortOrderInSheet:
                state.sortOrder = state.sortOrder.next
                if let date = state.selectedDate {
                    state.selectedDatePolicies = policies(on: date, sortOrder: state.sortOrder)
                }
                return .none

            case .didToggleLikeInSheet(let id):
                state.selectedDatePolicies[id: id]?.isLiked.toggle()
                return .none

            case .didTapPolicyInSheet(let id):
                // selectedDate는 남겨 두고 시트만 내려서, 돌아왔을 때 같은 날짜 시트를 복원할 수 있게 한다.
                // 시트 dismiss와 push를 같은 프레임에 동시에 요청하면 SwiftUI의 시트 상태 추적이
                // 꼬여서(내부적으로 아직 떠 있다고 착각) 나중에 isDaySheetPresented를 다시 true로 바꿔도
                // 시트가 안 뜬다. dismiss 애니메이션이 끝날 시간을 준 뒤에 push를 보낸다.
                state.isDaySheetPresented = false
                return .run { send in
                    try await clock.sleep(for: .milliseconds(350))
                    await send(.delegate(.didSelectPolicy(id: id)))
                }

            case .didTapMemoIcon(let id):
                state.isDaySheetPresented = false
                return .run { send in
                    try await clock.sleep(for: .milliseconds(350))
                    await send(.delegate(.didTapMemo(policyId: id)))
                }

            case .delegate:
                return .none
            }
        }
    }

    // MARK: - Private

    private func policies(on date: Date, sortOrder: SortOrder) -> IdentifiedArrayOf<PolicySummary> {
        let day = Calendar.current.startOfDay(for: date)
        let filtered = PolicySummary.mockList.filter {
            !$0.isOpenEnded && Calendar.current.startOfDay(for: $0.deadlineDate) == day
        }
        let sorted = sortOrder == .deadline
            ? filtered.sorted { $0.deadlineDate < $1.deadlineDate }
            : filtered.sorted { $0.id > $1.id }
        return IdentifiedArray(uniqueElements: sorted)
    }
}

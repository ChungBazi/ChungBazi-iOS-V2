// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziDomain
import ComposableArchitecture

/// 캘린더 화면 (21). 월별로 스크롤하며 마감일이 있는 날짜를 표시하고,
/// 날짜를 탭하면 그 날짜의 정책 목록을 바텀시트로 보여준다.
/// 정책 상세/메모로의 push는 자체 NavigationStack 없이 상위(MyPolicyFeature)에 위임한다
/// (push된 화면 안에 NavigationStack을 중첩하면 SwiftUI가 `AnyNavigationPath.Error.comparisonTypeMismatch`로 크래시한다).
@Reducer
public struct CalendarFeature: Sendable {

    // MARK: - SortOrder

    public enum SortOrder: Equatable {
        case deadline
        case latest

        var title: String {
            switch self {
            case .deadline: return "마감순"
            case .latest: return "최신순"
            }
        }

        var serverValue: String {
            switch self {
            case .deadline: return "DEADLINE"
            case .latest: return "LATEST"
            }
        }

        var next: SortOrder { self == .deadline ? .latest : .deadline }
    }

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var months: [CalendarMonth]
        /// 서버에서 받은 마감일(달별로 lazy 조회해 합집합으로 누적).
        public var deadlineDates: Set<Date>
        /// 이미 마감일을 조회한 달("yyyy-MM"). 중복 요청 방지.
        public var requestedMonths: Set<String>
        public var selectedDate: Date?
        public var selectedDatePolicies: LoadingState<IdentifiedArrayOf<PolicySummaryVO>>
        public var daySheetPagination: PaginationState<String>
        public var sortOrder: SortOrder
        /// 시트가 실제로 떠 있는지. `selectedDate`와 분리해 두어, 메모/상세로 이동할 때는
        /// 시트만 내리고(`selectedDate`는 유지) 되돌아오면 같은 날짜 시트를 다시 띄울 수 있게 한다.
        public var isDaySheetPresented: Bool
        /// 진입 시점 기준 날짜(오늘). 이 달을 중심으로 ±2년이 그려지고, 진입 시 이 달로 스크롤한다.
        public let centerDate: Date
        /// 마감일 캘린더 추가 결과 토스트.
        public var toastMessage: String
        public var isToastPresented: Bool

        /// centerDate가 속한 달의 첫날. 진입 시 이 달로 스크롤하기 위한 타깃(= CalendarMonth.id).
        public var centerMonthID: Date {
            let calendar = Calendar.current
            return calendar.date(from: calendar.dateComponents([.year, .month], from: centerDate)) ?? centerDate
        }

        public init(centerDate: Date = Date()) {
            self.months = []
            self.deadlineDates = []
            self.requestedMonths = []
            self.selectedDate = nil
            self.selectedDatePolicies = .idle
            self.daySheetPagination = PaginationState<String>()
            self.sortOrder = .deadline
            self.isDaySheetPresented = false
            self.centerDate = Calendar.current.startOfDay(for: centerDate)
            self.toastMessage = ""
            self.isToastPresented = false
        }
    }

    // MARK: - Action

    public enum Action: Equatable {
        // MARK: View
        case onAppear
        case didAppearMonth(Date)
        case didSelectDate(Date)
        case didDismissSheet
        case didTapSortOrderInSheet
        case didReachSheetListEnd
        case didTapPolicyInSheet(id: Int)
        case didTapMemoIcon(id: Int)
        case didTapAddToCalendar(id: Int)
        case dismissToast

        // MARK: Internal
        case calendarResponse(month: String, Result<[Date], UseCaseError>)
        case sheetPageResponse(Result<PolicyPageVO, UseCaseError>, isFirstPage: Bool)
        case addToCalendarSucceeded
        case addToCalendarFailed(EventKitError)

        // MARK: Delegate
        case delegate(Delegate)
    }

    // MARK: - Delegate

    public enum Delegate: Equatable {
        case didSelectPolicy(id: Int)
        case didTapMemo(policyId: Int)
    }

    // MARK: - Dependencies

    @Dependency(\.calendarClient) var calendarClient
    @Dependency(\.calendar) var calendar
    @Dependency(\.continuousClock) var clock

    // MARK: - Init

    public init() {}

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                if state.months.isEmpty {
                    state.months = CalendarMonth.mockMonths(centeredOn: state.centerDate, calendar: calendar)
                }
                // 메모/상세로 이동했다 되돌아온 경우, 보고 있던 날짜의 시트를 다시 띄운다.
                if state.selectedDate != nil {
                    state.isDaySheetPresented = true
                }
                return .none

            case .didAppearMonth(let monthDate):
                let month = monthString(monthDate)
                guard !state.requestedMonths.contains(month) else { return .none }
                state.requestedMonths.insert(month)
                return fetchDeadlines(month: month)

            case let .calendarResponse(_, .success(dates)):
                state.deadlineDates.formUnion(dates.map { calendar.startOfDay(for: $0) })
                return .none

            case let .calendarResponse(month, .failure):
                // 실패 시 재조회 가능하도록 요청 기록에서 제거(다시 스크롤로 나타나면 재시도).
                state.requestedMonths.remove(month)
                return .none

            case .didSelectDate(let date):
                state.selectedDate = date
                state.isDaySheetPresented = true
                return reloadSheetPolicies(&state)

            case .didDismissSheet:
                state.isDaySheetPresented = false
                state.selectedDate = nil
                state.selectedDatePolicies = .idle
                return .none

            case .didTapSortOrderInSheet:
                state.sortOrder = state.sortOrder.next
                return reloadSheetPolicies(&state)

            case .didReachSheetListEnd:
                guard state.daySheetPagination.canLoadNext, state.selectedDatePolicies.value != nil else { return .none }
                state.daySheetPagination.isLoadingNext = true
                return fetchSheetPolicies(state: state, isFirstPage: false)

            case let .sheetPageResponse(.success(page), isFirstPage):
                state.daySheetPagination.apply(page)
                if isFirstPage {
                    state.selectedDatePolicies = .loaded(page.policies)
                } else {
                    var current = state.selectedDatePolicies.value ?? []
                    current.append(contentsOf: page.policies)
                    state.selectedDatePolicies = .loaded(current)
                }
                return .none

            case let .sheetPageResponse(.failure(error), isFirstPage):
                if isFirstPage {
                    if state.selectedDatePolicies.value == nil {
                        state.selectedDatePolicies = .failed(error.loadFailureMessage)
                    }
                } else {
                    state.daySheetPagination.isLoadingNext = false
                }
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

            case .didTapAddToCalendar(let id):
                // 시트는 그대로 두고(화면 유지), 선택 날짜를 마감일로 종일 이벤트를 추가한다.
                guard let date = state.selectedDate,
                      let policy = state.selectedDatePolicies.value?[id: id] else { return .none }
                let title = policy.title
                return .run { [calendarClient] send in
                    do {
                        try await calendarClient.addDeadline(id, title, date)
                        await send(.addToCalendarSucceeded)
                    } catch let error as EventKitError {
                        await send(.addToCalendarFailed(error))
                    } catch {
                        await send(.addToCalendarFailed(.saveFailed))
                    }
                }

            case .addToCalendarSucceeded:
                state.toastMessage = "마감일을 캘린더에 추가했어요"
                state.isToastPresented = true
                return .none

            case .addToCalendarFailed(let error):
                switch error {
                case .accessDenied:
                    state.toastMessage = "설정에서 캘린더 접근을 허용해주세요"
                case .saveFailed:
                    state.toastMessage = "캘린더에 추가하지 못했어요"
                }
                state.isToastPresented = true
                return .none

            case .dismissToast:
                state.isToastPresented = false
                return .none

            case .delegate:
                return .none
            }
        }
    }

    // MARK: - Private

    private enum CancelID: Hashable { case sheetPolicies }

    private static let pageSize = 20

    private func fetchDeadlines(month: String) -> Effect<Action> {
        .run { [calendarClient] send in
            do {
                let dates = try await calendarClient.fetchCalendar(month)
                await send(.calendarResponse(month: month, .success(dates)))
            } catch {
                await send(.calendarResponse(month: month, .failure(UseCaseError.map(error))))
            }
        }
    }

    /// 선택 날짜 시트 목록을 1페이지부터 재조회.
    private func reloadSheetPolicies(_ state: inout State) -> Effect<Action> {
        state.selectedDatePolicies = .loading
        state.daySheetPagination.reset()
        return fetchSheetPolicies(state: state, isFirstPage: true)
    }

    private func fetchSheetPolicies(state: State, isFirstPage: Bool) -> Effect<Action> {
        guard let date = state.selectedDate else { return .none }
        let targetDate = dayString(date)
        let sort = state.sortOrder.serverValue
        let cursor = isFirstPage ? nil : state.daySheetPagination.nextCursor
        return .run { [calendarClient] send in
            do {
                let page = try await calendarClient.fetchDeadlineDate(targetDate, sort, cursor, Self.pageSize)
                await send(.sheetPageResponse(.success(page), isFirstPage: isFirstPage))
            } catch {
                await send(.sheetPageResponse(.failure(UseCaseError.map(error)), isFirstPage: isFirstPage))
            }
        }
        .cancellable(id: CancelID.sheetPolicies, cancelInFlight: true)
    }

    /// 주입된 calendar 기준 "yyyy-MM"(getCalendar targetMonth 파라미터용).
    private func monthString(_ date: Date) -> String {
        let components = calendar.dateComponents([.year, .month], from: date)
        return String(format: "%04d-%02d", components.year ?? 0, components.month ?? 0)
    }

    /// 주입된 calendar 기준 "yyyy-MM-dd"(getDeadlineDatePolicies targetDate 파라미터용).
    private func dayString(_ date: Date) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", components.year ?? 0, components.month ?? 0, components.day ?? 0)
    }
}

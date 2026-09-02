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

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var months: [CalendarMonth]
        /// 서버에서 받은 마감일(달별로 lazy 조회해 합집합으로 누적). 타임존 무관하게 yyyymmdd 정수 키로 보관한다.
        public var deadlineDays: Set<Int>
        /// 이미 마감일을 조회한 달("yyyy-MM"). 중복 요청 방지.
        public var requestedMonths: Set<String>
        public var selectedDate: Date?
        public var selectedDatePolicies: LoadingState<IdentifiedArrayOf<PolicySummaryVO>>
        /// 시트 서버 총개수(비페이지네이션).
        public var selectedDateTotalCount = 0
        /// 시트가 실제로 떠 있는지. `selectedDate`와 분리해 두어, 메모/상세로 이동할 때는
        /// 시트만 내리고(`selectedDate`는 유지) 되돌아오면 같은 날짜 시트를 다시 띄울 수 있게 한다.
        public var isDaySheetPresented: Bool
        /// 진입 시점 기준 날짜(오늘). 이 달을 중심으로 ±2년이 그려지고, 진입 시 이 달로 스크롤한다.
        public let centerDate: Date
        /// 마감일 캘린더 추가 결과 토스트.
        public var toastMessage: String
        public var isToastPresented: Bool
        /// 마감일 추가 요청 진행 중 여부. 더블탭으로 이벤트가 중복 생성되는 것을 막는다.
        public var isAddingDeadline: Bool

        /// 다른 화면에서 찜 해제된 정책을 시트 목록에서 제외하기 위한 공유 오버레이.
        @Shared(.likeOverrides) public var likeOverrides: [Int: Bool] = [:]

        /// 시트 개수 — 서버 총개수에서 다른 화면발 찜 해제(overlay == false)로 숨겨진 카드 수만큼 뺀다.
        public var visibleSheetCount: Int {
            let hidden = (selectedDatePolicies.value ?? []).filter { likeOverrides[$0.id] == false }.count
            return max(0, selectedDateTotalCount - hidden)
        }

        /// centerDate가 속한 달의 첫날. 진입 시 이 달로 스크롤하기 위한 타깃(= CalendarMonth.id).
        public var centerMonthID: Date {
            let calendar = Calendar.current
            return calendar.date(from: calendar.dateComponents([.year, .month], from: centerDate)) ?? centerDate
        }

        public init(centerDate: Date = Date()) {
            self.months = []
            self.deadlineDays = []
            self.requestedMonths = []
            self.selectedDate = nil
            self.selectedDatePolicies = .idle
            self.isDaySheetPresented = false
            self.centerDate = Calendar.current.startOfDay(for: centerDate)
            self.toastMessage = ""
            self.isToastPresented = false
            self.isAddingDeadline = false
        }
    }

    // MARK: - Action

    public enum Action: Equatable {
        // MARK: View
        case onAppear
        case didAppearMonth(Date)
        case didSelectDate(Date)
        case didDismissSheet
        case didTapPolicyInSheet(id: Int)
        case didTapMemoIcon(id: Int)
        case didTapAddToCalendar(id: Int)
        case dismissToast

        // MARK: Internal
        case calendarResponse(month: String, Result<[DateComponents], UseCaseError>)
        case sheetPoliciesResponse(Result<PolicyPageVO, UseCaseError>)
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

            case let .calendarResponse(_, .success(days)):
                // 절대시각 변환 없이 yyyymmdd 키로 누적한다(타임존 무관).
                state.deadlineDays.formUnion(days.compactMap(\.yyyymmddKey))
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
                state.selectedDateTotalCount = 0
                // 토스트/추가 진행 상태도 초기화(다음 시트 오픈 시 이전 토스트가 다시 뜨는 것 방지).
                state.isToastPresented = false
                state.toastMessage = ""
                state.isAddingDeadline = false
                return .none

            case .sheetPoliciesResponse(.success(let page)):
                state.selectedDatePolicies = .loaded(page.policies)
                state.selectedDateTotalCount = page.totalCount
                return .none

            case .sheetPoliciesResponse(.failure(let error)):
                if state.selectedDatePolicies.value == nil {
                    state.selectedDatePolicies = .failed(error.loadFailureMessage)
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
                // 시트는 그대로 두고(화면 유지), 선택 날짜를 마감일로 종일 이벤트를 추가한다. 진행 중이면 더블탭 무시.
                guard !state.isAddingDeadline,
                      let date = state.selectedDate,
                      let policy = state.selectedDatePolicies.value?[id: id] else { return .none }
                state.isAddingDeadline = true
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
                state.isAddingDeadline = false
                state.toastMessage = "마감일을 캘린더에 추가했어요"
                state.isToastPresented = true
                return .none

            case .addToCalendarFailed(let error):
                state.isAddingDeadline = false
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

    private func fetchDeadlines(month: String) -> Effect<Action> {
        .run { [calendarClient] send in
            do {
                let days = try await calendarClient.fetchCalendar(month)
                await send(.calendarResponse(month: month, .success(days)))
            } catch {
                await send(.calendarResponse(month: month, .failure(UseCaseError.map(error))))
            }
        }
    }

    /// 선택 날짜 시트 목록을 다시 조회(로딩 표시).
    private func reloadSheetPolicies(_ state: inout State) -> Effect<Action> {
        state.selectedDatePolicies = .loading
        return fetchSheetPolicies(state: state)
    }

    private func fetchSheetPolicies(state: State) -> Effect<Action> {
        guard let date = state.selectedDate else { return .none }
        let targetDate = dayString(date)
        return .run { [calendarClient] send in
            do {
                let page = try await calendarClient.fetchDeadlineDate(targetDate)
                await send(.sheetPoliciesResponse(.success(page)))
            } catch {
                await send(.sheetPoliciesResponse(.failure(UseCaseError.map(error))))
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

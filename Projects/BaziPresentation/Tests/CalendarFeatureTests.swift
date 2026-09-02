// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import ComposableArchitecture
import Testing

import BaziDomain
@testable import BaziPresentation

@MainActor
struct CalendarFeatureTests {

    private static func page(_ items: [PolicySummaryVO]) -> PolicyPageVO {
        PolicyPageVO(
            policies: IdentifiedArray(uniqueElements: items),
            nextCursor: nil,
            hasNext: false,
            totalCount: items.count
        )
    }

    @Test("달이 나타나면 그 달의 마감일을 조회해 합집합에 반영한다")
    func didAppearMonth_loadsDeadlines() async {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "Asia/Seoul") ?? cal.timeZone
        let monthDate = cal.date(from: DateComponents(year: 2026, month: 5, day: 1)) ?? Date()

        let store = TestStore(initialState: CalendarFeature.State(centerDate: monthDate)) {
            CalendarFeature()
        } withDependencies: {
            $0.calendar = cal
            $0.calendarClient.fetchCalendar = { _ in [DateComponents(year: 2026, month: 5, day: 18)] }
        }

        await store.send(.didAppearMonth(monthDate)) {
            $0.requestedMonths.insert("2026-05")
        }
        await store.receive(\.calendarResponse.success) {
            $0.deadlineDays = [20260518]
        }
    }

    @Test("날짜를 선택하면 시트를 띄우고 그 날짜의 정책을 조회한다")
    func didSelectDate_loadsSheet() async {
        let items = Array(PolicySummaryVO.mockList.prefix(3))
        let date = Date(timeIntervalSince1970: 1_774_000_000)

        let store = TestStore(initialState: CalendarFeature.State(centerDate: date)) {
            CalendarFeature()
        } withDependencies: {
            $0.calendarClient.fetchDeadlineDate = { _ in Self.page(items) }
        }

        await store.send(.didSelectDate(date)) {
            $0.selectedDate = date
            $0.isDaySheetPresented = true
            $0.selectedDatePolicies = .loading
        }
        await store.receive(\.sheetPoliciesResponse.success) {
            $0.selectedDatePolicies = .loaded(IdentifiedArray(uniqueElements: items))
            $0.selectedDateTotalCount = items.count
        }
    }

    @Test("시트를 내리면 선택 상태와 목록이 초기화된다")
    func didDismissSheet_resets() async {
        let date = Date(timeIntervalSince1970: 1_774_000_000)

        var state = CalendarFeature.State(centerDate: date)
        state.selectedDate = date
        state.isDaySheetPresented = true
        state.selectedDatePolicies = .loaded(IdentifiedArray(uniqueElements: Array(PolicySummaryVO.mockList.prefix(2))))
        state.selectedDateTotalCount = 2

        let store = TestStore(initialState: state) {
            CalendarFeature()
        }

        await store.send(.didDismissSheet) {
            $0.isDaySheetPresented = false
            $0.selectedDate = nil
            $0.selectedDatePolicies = .idle
            $0.selectedDateTotalCount = 0
        }
    }
}

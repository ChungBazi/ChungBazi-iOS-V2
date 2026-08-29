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
        let deadline = cal.date(from: DateComponents(year: 2026, month: 5, day: 18)) ?? Date()

        let store = TestStore(initialState: CalendarFeature.State(centerDate: monthDate)) {
            CalendarFeature()
        } withDependencies: {
            $0.calendar = cal
            $0.calendarClient.fetchCalendar = { _ in [deadline] }
        }

        await store.send(.didAppearMonth(monthDate)) {
            $0.requestedMonths.insert("2026-05")
        }
        await store.receive(\.calendarResponse.success) {
            $0.deadlineDates = [cal.startOfDay(for: deadline)]
        }
    }

    @Test("날짜를 선택하면 시트를 띄우고 그 날짜의 정책을 조회한다")
    func didSelectDate_loadsSheet() async {
        let items = Array(PolicySummaryVO.mockList.prefix(3))
        let date = Date(timeIntervalSince1970: 1_774_000_000)

        let store = TestStore(initialState: CalendarFeature.State(centerDate: date)) {
            CalendarFeature()
        } withDependencies: {
            $0.calendarClient.fetchDeadlineDate = { _, _, _, _ in Self.page(items) }
        }

        await store.send(.didSelectDate(date)) {
            $0.selectedDate = date
            $0.isDaySheetPresented = true
            $0.selectedDatePolicies = .loading
        }
        await store.receive(\.sheetPageResponse.success) {
            $0.selectedDatePolicies = .loaded(IdentifiedArray(uniqueElements: items))
            $0.daySheetPagination.totalCount = items.count
        }
    }

    @Test("시트 정렬 변경 시 선택 날짜 정책을 다시 조회한다")
    func didTapSortOrderInSheet_reloads() async {
        let items = Array(PolicySummaryVO.mockList.prefix(2))
        let date = Date(timeIntervalSince1970: 1_774_000_000)

        var state = CalendarFeature.State(centerDate: date)
        state.selectedDate = date
        state.isDaySheetPresented = true
        state.selectedDatePolicies = .loaded(IdentifiedArray(uniqueElements: Array(PolicySummaryVO.mockList.prefix(3))))
        state.daySheetPagination.totalCount = 3

        let store = TestStore(initialState: state) {
            CalendarFeature()
        } withDependencies: {
            $0.calendarClient.fetchDeadlineDate = { _, _, _, _ in Self.page(items) }
        }

        await store.send(.didTapSortOrderInSheet) {
            $0.sortOrder = .latest
            $0.selectedDatePolicies = .loading
            $0.daySheetPagination.reset()
        }
        await store.receive(\.sheetPageResponse.success) {
            $0.selectedDatePolicies = .loaded(IdentifiedArray(uniqueElements: items))
            $0.daySheetPagination.totalCount = items.count
        }
    }
}

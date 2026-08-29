// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import BaziDesign
import ComposableArchitecture

public struct CalendarView: View {

    // MARK: - Constants

    private static let weekdaySymbols = ["일", "월", "화", "수", "목", "금", "토"]

    // MARK: - Properties

    @Bindable var store: StoreOf<CalendarFeature>
    @Environment(\.dismiss) private var dismiss
    /// 특정 달이 로드 트리거 위치(index 1 / count-2)에 다시 나타나도 중복으로 더 불러오지 않도록 막는다.
    @State private var prependTriggeredMonthID: Date?
    @State private var appendTriggeredMonthID: Date?

    // MARK: - Init

    public init(store: StoreOf<CalendarFeature>) {
        self.store = store
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 0) {
            weekdayHeader
            content
        }
        .onAppear { store.send(.onAppear) }
        .baziNavigationBar_backWithTitle("캘린더") {
            dismiss()
        }
        .sheet(isPresented: isSheetPresented) {
            dayDetailSheet
        }
        .toolbar(.hidden, for: .tabBar)
    }
}

// MARK: - Weekday Header

extension CalendarView {

    /// 스크롤뷰에 속하지 않고 네비게이션 바 바로 아래 고정된다.
    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(Self.weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .baziFont(.small12R)
                    .foregroundStyle(Color.gray500)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .baziBackground(.bgWhite)
    }
}

// MARK: - Month Grid

extension CalendarView {

    private var content: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 32) {
                    ForEach(Array(store.months.enumerated()), id: \.element.id) { index, month in
                        monthSection(month)
                            .id(month.id)
                            .onAppear {
                                // 맨 끝(index 0/마지막)이 아니라 그 다음 칸에서 미리 불러와,
                                // 새로 끼워진 달이 렌더 버퍼에 걸려 다시 즉시 onAppear가 발동하는 걸 막는다.
                                // + 같은 프레임 안에서 여러 번 상태를 바꾸면 SwiftUI가 크래시하므로,
                                // 이미 트리거한 달이면 무시하고 상태 변경은 다음 런루프로 미룬다.
                                if index == 1, prependTriggeredMonthID != month.id {
                                    prependTriggeredMonthID = month.id
                                    Task { @MainActor in store.send(.didAppearFirstMonth) }
                                }
                                if index == store.months.count - 2, appendTriggeredMonthID != month.id {
                                    appendTriggeredMonthID = month.id
                                    Task { @MainActor in store.send(.didAppearLastMonth) }
                                }
                            }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
            // 위로 무한스크롤 시 새 달이 앞에 끼워지며 화면이 튀지 않도록, 기존 첫 달로 즉시(애니메이션 없이) 되돌린다.
            .onChange(of: store.months.first?.firstDayOfMonth) { oldValue, newValue in
                guard let oldValue, newValue != oldValue else { return }
                Task { @MainActor in
                    var transaction = Transaction()
                    transaction.disablesAnimations = true
                    withTransaction(transaction) {
                        proxy.scrollTo(oldValue, anchor: .top)
                    }
                }
            }
        }
        .baziBackground(.bgWhite)
    }

    private func monthSection(_ month: CalendarMonth) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(month.title)
                .baziFont(.head20B)
                .foregroundStyle(Color.gray900)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(Array(month.days.enumerated()), id: \.offset) { _, date in
                    if let date {
                        dayCell(date)
                    } else {
                        Color.clear.frame(height: 36)
                    }
                }
            }
        }
    }

    private func dayCell(_ date: Date) -> some View {
        let isSelected = store.selectedDate.map { Calendar.current.isDate($0, inSameDayAs: date) } ?? false
        let hasDeadline = store.deadlineDates.contains(Calendar.current.startOfDay(for: date))

        return Button {
            store.send(.didSelectDate(date))
        } label: {
            VStack(spacing: 4) {
                Text("\(Calendar.current.component(.day, from: date))")
                    .baziFont(.small14R)
                    .foregroundStyle(isSelected ? Color.grayWhite : Color.gray700)
                    .frame(width: 36, height: 36)
                    .background(isSelected ? Color.bazi(.primary) : Color.clear)
                    .clipShape(Circle())

                Capsule()
                    .fill(hasDeadline ? (isSelected ? Color.bazi(.primary) : Color.blue100) : Color.clear)
                    .frame(width: 20, height: 2)
            }
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Day Detail Sheet

extension CalendarView {

    private var isSheetPresented: Binding<Bool> {
        Binding(
            get: { store.isDaySheetPresented },
            set: { isPresented in
                if !isPresented { store.send(.didDismissSheet) }
            }
        )
    }

    private var dayDetailSheet: some View {
        VStack(spacing: 0) {
            if let date = store.selectedDate {
                Text(dayTitle(for: date))
                    .baziFont(.body16SB)
                    .foregroundStyle(Color.gray900)
                    .padding(.top, 26)
                    .padding(.bottom, 18)
            }

            sheetResultsToolbar

            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(store.selectedDatePolicies) { policy in
                        sheetCard(policy)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .baziBackground(.bgGray)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private var sheetResultsToolbar: some View {
        HStack {
            Text("\(store.selectedDatePolicies.count)개")
                .baziFont(.small14R)
                .foregroundStyle(Color.gray600)
            Spacer()
            Button {
                store.send(.didTapSortOrderInSheet)
            } label: {
                Label(store.sortOrder.rawValue, systemImage: "arrow.up.arrow.down")
                    .labelStyle(.titleAndIcon)
            }
            .buttonStyle(.plain)
            .baziFont(.small14R)
            .foregroundStyle(Color.gray600)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }

    private func sheetCard(_ policy: PolicySummary) -> some View {
        BZCard(
            size: .medium,
            category: policy.category.rawValue,
            dDay: policy.dDay,
            title: policy.title,
            viewCount: policy.viewCount,
            isBookmarked: sheetBookmarkBinding(id: policy.id),
            accessory: .memo(action: { store.send(.didTapMemoIcon(id: policy.id)) })
        )
        .onTapGesture { store.send(.didTapPolicyInSheet(id: policy.id)) }
    }

    private func dayTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일 (E)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}

// MARK: - Bindings

extension CalendarView {

    private func sheetBookmarkBinding(id: Int) -> Binding<Bool> {
        Binding(
            get: { store.selectedDatePolicies[id: id]?.isBookmarked ?? false },
            set: { _ in store.send(.didToggleBookmarkInSheet(id: id)) }
        )
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CalendarView(
            store: Store(initialState: .init()) {
                CalendarFeature()
            }
        )
    }
}

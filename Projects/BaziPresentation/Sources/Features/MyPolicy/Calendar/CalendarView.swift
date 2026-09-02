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
    /// 진입 시 centerDate(오늘) 달로 최초 1회만 스크롤하기 위한 가드.
    @State private var didInitialScroll = false

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
        .task { store.send(.onAppear) }
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
                    ForEach(store.months) { month in
                        monthSection(month)
                            .id(month.id)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
            // 진입 시(months가 채워지는 순간) centerDate(오늘) 달로 즉시(애니메이션 없이) 이동한다.
            .onChange(of: store.months.isEmpty) { _, isEmpty in
                guard !isEmpty, !didInitialScroll else { return }
                didInitialScroll = true
                Task { @MainActor in
                    var transaction = Transaction()
                    transaction.disablesAnimations = true
                    withTransaction(transaction) {
                        proxy.scrollTo(store.centerMonthID, anchor: .top)
                    }
                }
            }
            .hiddenTabBarSafeBottom()
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
        // 달이 화면에 나타나면 그 달의 마감일을 조회한다(중복은 Reducer에서 무시).
        .onAppear { store.send(.didAppearMonth(month.firstDayOfMonth)) }
    }

    /// 오늘은 강조 원(primary), 찜한 정책 마감이 있는 날만 하단 인디케이터 바 + 탭 선택 가능.
    /// - 인디케이터 바: blue300, 단 오늘+마감이면 primary.
    /// - 인디케이터가 없는(마감 없는) 날짜는 선택할 수 없다.
    private func dayCell(_ date: Date) -> some View {
        // centerDate는 진입 시점의 오늘(= MyPolicy의 state.today)이라 오늘 표시 기준으로 쓴다.
        let isToday = Calendar.current.isDate(date, inSameDayAs: store.centerDate)
        let dayKey = Calendar.current.dateComponents([.year, .month, .day], from: date).yyyymmddKey
        let hasDeadline = dayKey.map { store.deadlineDays.contains($0) } ?? false

        return VStack(spacing: 4) {
            Text("\(Calendar.current.component(.day, from: date))")
                .baziFont(.small14R)
                .foregroundStyle(isToday ? Color.grayWhite : Color.gray700)
                .frame(width: 36, height: 36)
                .background(isToday ? Color.bazi(.primary) : Color.clear)
                .clipShape(Circle())

            Capsule()
                .fill(hasDeadline ? (isToday ? Color.bazi(.primary) : Color.blue300) : Color.clear)
                .frame(width: 20, height: 2)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            // 인디케이터(마감)가 있는 날짜만 선택 가능.
            guard hasDeadline else { return }
            store.send(.didSelectDate(date))
        }
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

    private var isToastPresented: Binding<Bool> {
        Binding(
            get: { store.isToastPresented },
            set: { isPresented in
                if !isPresented { store.send(.dismissToast) }
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

            sheetContent
        }
        .baziBackground(.bgGray)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .baziToast(isPresented: isToastPresented, message: store.toastMessage)
    }

    @ViewBuilder
    private var sheetContent: some View {
        switch store.selectedDatePolicies {
        case .idle, .loading:
            BZLoadingView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed:
            BZRetryView {
                if let date = store.selectedDate { store.send(.didSelectDate(date)) }
            }
        case .loaded(let policies):
            // 다른 화면에서 찜 해제된 정책(overlay == false)은 시트에서 제외한다.
            let visible = IdentifiedArray(uniqueElements: policies.filter { store.likeOverrides[$0.id] != false })
            if visible.isEmpty {
                BZEmptyView(message: "이 날짜에는 등록된 정책이 없어요")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                sheetResultsToolbar
                ScrollView {
                    sheetList(visible)
                }
            }
        }
    }

    private var sheetResultsToolbar: some View {
        // 정렬 없이 갯수만 표시한다.
        BZResultsToolbar(count: store.visibleSheetCount)
    }

    private func sheetList(_ policies: IdentifiedArrayOf<PolicySummaryVO>) -> some View {
        LazyVStack(spacing: 12) {
            ForEach(policies) { policy in
                sheetCard(policy)
            }
        }
        .padding(.top, 8)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    private func sheetCard(_ policy: PolicySummaryVO) -> some View {
        BZCard(
            size: .medium,
            category: policy.category.rawValue,
            dDay: policy.dDay,
            title: policy.title,
            viewCount: policy.viewCount,
            isLiked: .constant(policy.isLiked),
            accessory: .calendarAndMemo(
                onAddCalendar: { store.send(.didTapAddToCalendar(id: policy.id)) },
                onMemo: { store.send(.didTapMemoIcon(id: policy.id)) }
            )
        )
        .onTapGesture { store.send(.didTapPolicyInSheet(id: policy.id)) }
    }

    private static let dayTitleFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일 (E)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()

    private func dayTitle(for date: Date) -> String {
        Self.dayTitleFormatter.string(from: date)
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

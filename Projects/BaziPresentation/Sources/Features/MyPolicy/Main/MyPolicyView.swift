// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import BaziDesign
import ComposableArchitecture

public struct MyPolicyView: View {

    // MARK: - Properties

    @Bindable var store: StoreOf<MyPolicyFeature>

    // MARK: - Init

    public init(store: StoreOf<MyPolicyFeature>) {
        self.store = store
    }

    // MARK: - Body

    public var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            VStack(spacing: 0) {
                header
                content
            }
            .task { store.send(.onAppear) }
        } destination: { store in
            switch store.case {
            case .policyList(let store):
                MyPolicyListView(store: store)
            case .calendar(let store):
                CalendarView(store: store)
            case .memo(let store):
                PolicyMemoView(store: store)
            }
        }
    }
}

// MARK: - Content

private extension MyPolicyView {

    /// 고정 헤더 아래 스크롤 영역.
    /// teaser는 섹션 앞에 있어 먼저 스크롤되어 사라지고, `pinnedControls`(달력·탭·툴바)는 섹션 헤더로 상단에 고정된다.
    /// 그 아래 리스트만 스크롤된다.
    var content: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                teaser
                Section {
                    results
                } header: {
                    pinnedControls
                }
            }
        }
        .refreshable { await store.send(.pullToRefresh).finish() }
        .baziBackground(.bgGray)
    }

    /// "내 정책" 상단 헤더. 스크롤과 무관하게 항상 고정된다.
    var header: some View {
        BZNavigationRowHeader(title: "내 정책") {
            store.send(.didTapHeaderMore)
        }
        .baziBackground(.bgWhite)
    }

    /// 스크롤 시 상단에 고정되는 컨트롤 묶음(달력·탭·결과 툴바). 리스트가 뒤로 비쳐 보이지 않도록 흰 배경으로 채운다.
    var pinnedControls: some View {
        VStack(spacing: 0) {
            miniCalendar
            tabBar
            resultsToolbar
        }
        .baziBackground(.bgWhite)
    }

    @ViewBuilder
    var teaser: some View {
        if store.deadlineTeaser.isEmpty {
            emptyTeaserBanner
        } else {
            teaserBanner
        }
    }

    @ViewBuilder
    var results: some View {
        switch store.currentPolicies {
        case .idle, .loading:
            BZLoadingView()
                .frame(maxWidth: .infinity, minHeight: 200)
        case .failed:
            BZRetryView { store.send(.onAppear) }
        case .loaded(let policies):
            if policies.isEmpty {
                emptyPolicyList
            } else {
                policyList(policies)
            }
        }
    }
}

// MARK: - Deadline Teaser

private extension MyPolicyView {

    var teaserBanner: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("찜한 정책들의 마감이 다가와요!")
                .baziFont(.head18B)
                .foregroundStyle(Color.gray900)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(store.deadlineTeaser) { policy in
                        policyCard(policy, size: .small)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.blue100)
    }

    var emptyTeaserBanner: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("아직 찜한 정책이 없어요!")
                    .baziFont(.body16B)
                    .foregroundStyle(Color.bazi(.primary))
                Text("관심 있는 정책을 찜하고\n놓치지 않게 관리해보세요")
                    .baziFont(.small14R)
                    .foregroundStyle(Color.gray600)
            }
            Spacer(minLength: 12)
            BZCircleButton {
                store.send(.didTapEmptyBannerCTA)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.grayWhite)
        .baziRadius(.medium)
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.blue100)
    }
}

// MARK: - Mini Calendar

private extension MyPolicyView {

    var miniCalendar: some View {
        VStack(alignment: .leading, spacing: 0) {
            monthSelector
            weekStrip
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .baziBackground(.bgWhite)
    }

    var monthSelector: some View {
        Button {
            store.send(.didTapCalendarIcon)
        } label: {
            HStack(spacing: 11) {
                Text(Self.monthFormatter.string(from: store.selectedDate))
                    .baziFont(.body16SB)
                    .foregroundStyle(Color.gray900)
                Circle()
                    .fill(Color.blue50)
                    .frame(width: 29, height: 29)
                    .overlay {
                        Image.bazi(.calendarIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 15.5)
                    }
            }
        }
        .buttonStyle(.plain)
        .padding(.vertical, 12)
    }

    var weekStrip: some View {
        HStack(spacing: 0) {
            ForEach(store.weekDates, id: \.self) { date in
                weekDayCell(date)
            }
        }
        .padding(.vertical, 12)
    }

    func weekDayCell(_ date: Date) -> some View {
        let calendar = Calendar.current
        let isSelected = calendar.isDate(date, inSameDayAs: store.selectedDate)

        return Button {
            store.send(.didSelectWeekDate(date))
        } label: {
            VStack(spacing: 4) {
                Text(Self.weekdayFormatter.string(from: date))
                    .baziFont(.small12R)
                    .foregroundStyle(Color.gray500)
                Text("\(calendar.component(.day, from: date))")
                    .baziFont(.small14R)
                    .foregroundStyle(isSelected ? Color.grayWhite : Color.gray700)
                    .frame(width: 36, height: 36)
                    .background(isSelected ? Color.bazi(.primary) : Color.clear)
                    .clipShape(Circle())
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Tab

private extension MyPolicyView {

    var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(MyPolicyFeature.Tab.allCases, id: \.self) { tab in
                tabItem(tab)
            }
        }
        .baziBackground(.bgWhite)
    }

    func tabItem(_ tab: MyPolicyFeature.Tab) -> some View {
        let isSelected = store.selectedTab == tab
        return Button {
            store.send(.didSelectTab(tab))
        } label: {
            Text(tab.title)
                .baziFont(isSelected ? .small14SB : .small14R)
                .foregroundStyle(isSelected ? Color.bazi(.primary) : Color.gray500)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
                .overlay(alignment: .bottom) {
                    if isSelected {
                        Rectangle()
                            .fill(Color.bazi(.primary))
                            .frame(height: 1.67)
                    }
                }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Results

private extension MyPolicyView {

    var resultsToolbar: some View {
        // 정책 탭은 갯수+정렬, 상시모집 탭은 정렬 없이 갯수만 표시한다.
        Group {
            if store.selectedTab == .policy {
                BZResultsToolbar(count: store.currentTotalCount, sortTitle: store.sortOrder.title) {
                    store.send(.didTapSortOrder)
                }
            } else {
                BZResultsToolbar(count: store.currentTotalCount)
            }
        }
        .baziBackground(.bgGray)
    }

    func policyList(_ policies: IdentifiedArrayOf<PolicySummaryVO>) -> some View {
        LazyVStack(spacing: 12) {
            ForEach(policies) { policy in
                policyCard(policy, size: .medium)
                    .onAppear {
                        if policy.id == policies.last?.id {
                            store.send(.didReachListEnd)
                        }
                    }
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 20)
        .padding(.horizontal, 20)
    }

    var emptyPolicyList: some View {
        BZEmptyView(message: store.selectedTab == .policy ? "이 날짜에는 등록된 정책이 없어요" : "상시모집 중인 정책이 없어요")
    }

    /// teaser(가로 스크롤)와 목록에서 공통으로 쓰는 정책 카드. 탭하면 상세로, 메모 액세서리로 메모 진입.
    func policyCard(_ policy: PolicySummaryVO, size: BZCardSize) -> some View {
        BZCard(
            size: size,
            category: policy.category.rawValue,
            dDay: policy.dDay,
            title: policy.title,
            viewCount: policy.viewCount,
            isLiked: .constant(policy.isLiked),
            accessory: .memo(action: { store.send(.didTapMemo(id: policy.id)) })
        )
        .onTapGesture { store.send(.didTapPolicy(id: policy.id)) }
    }
}

// MARK: - Formatters

private extension MyPolicyView {

    static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()

    static let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
}

// MARK: - Preview

#Preview("찜한 정책 있음") {
    MyPolicyView(
        store: Store(initialState: .init()) {
            MyPolicyFeature()
        }
    )
}

#Preview("찜한 정책 없음") {
    var state = MyPolicyFeature.State()
    state.deadlineTeaser = []
    state.datePolicies = .loaded([])

    return MyPolicyView(
        store: Store(initialState: state) {
            EmptyReducer()
        }
    )
}

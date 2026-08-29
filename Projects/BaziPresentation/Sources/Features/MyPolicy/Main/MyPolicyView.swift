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
            content
                .task { store.send(.onAppear) }
                // 커스텀 헤더(BZNavigationRowHeader)를 쓰는 화면이라, 시스템이 기본으로 얹는
                // 빈 네비바 크롬을 꺼야 상단 세이프 에리어 배경이 제대로 보인다.
                .toolbar(.hidden, for: .navigationBar)
        } destination: { store in
            switch store.case {
            case .policyList(let store):
                MyPolicyListView(store: store)
            case .calendar(let store):
                CalendarView(store: store)
            case .memo(let store):
                PolicyMemoView(store: store)
            case .detail(let store):
                PlaceholderDetailView(store: store)
            }
        }
    }
}

// MARK: - Subviews

extension MyPolicyView {

    private var content: some View {
        ScrollView {
            VStack(spacing: 0) {
                header
                if store.deadlineTeaser.isEmpty {
                    emptyTeaserBanner
                } else {
                    teaserBanner
                }
                miniCalendar
                tabBar
                resultsToolbar
                if store.policies.isEmpty {
                    emptyPolicyList
                } else {
                    policyList
                }
            }
        }
        .baziBackground(.bgGray)
        // 시스템 네비바가 없는 화면이라 상단 세이프 에리어(상태바 영역)가 기본적으로 안 칠해져 있다.
        // ScrollView 안(header)에 걸면 스크롤 클리핑에 가려지므로, ScrollView 자체의 배경으로 걸어야 한다.
        .background(Color.bazi(.bgWhite).ignoresSafeArea(edges: .top))
    }

    private var header: some View {
        BZNavigationRowHeader(title: "내 정책") {
            store.send(.didTapHeaderMore)
        }
    }
}

// MARK: - Deadline Teaser

extension MyPolicyView {

    private var teaserBanner: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("찜한 정책들의 마감이 다가와요!")
                .baziFont(.head18B)
                .foregroundStyle(Color.gray900)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(store.deadlineTeaser) { policy in
                        BZCard(
                            size: .small,
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
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.blue100)
    }

    private var emptyTeaserBanner: some View {
        Button {
            store.send(.didTapEmptyBannerCTA)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("아직 찜한 정책이 없어요!")
                        .baziFont(.head18B)
                        .foregroundStyle(Color.gray900)
                    Text("관심 있는 정책을 찜하고 놓치지 않게 관리해보세요")
                        .baziFont(.small14R)
                        .foregroundStyle(Color.gray600)
                }
                Spacer()
                Circle()
                    .fill(Color.bazi(.primary))
                    .frame(width: 38, height: 38)
                    .overlay {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.grayWhite)
                    }
            }
            .padding(20)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .background(Color.blue100)
    }
}

// MARK: - Mini Calendar

extension MyPolicyView {

    private var miniCalendar: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                store.send(.didTapCalendarIcon)
            } label: {
                HStack(spacing: 8) {
                    Text(monthTitle)
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
            .padding(.horizontal, 20)

            HStack(spacing: 0) {
                ForEach(store.weekDates, id: \.self) { date in
                    weekDayCell(date)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .baziBackground(.bgWhite)
    }

    private func weekDayCell(_ date: Date) -> some View {
        let calendar = Calendar.current
        let isSelected = calendar.isDate(date, inSameDayAs: store.selectedDate)

        return Button {
            store.send(.didSelectWeekDate(date))
        } label: {
            VStack(spacing: 4) {
                Text(weekdaySymbol(for: date))
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

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: store.selectedDate)
    }

    private func weekdaySymbol(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}

// MARK: - Tab & List

extension MyPolicyView {

    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(MyPolicyFeature.Tab.allCases, id: \.self) { tab in
                tabItem(tab)
            }
        }
        .baziBackground(.bgWhite)
    }

    private func tabItem(_ tab: MyPolicyFeature.Tab) -> some View {
        let isSelected = store.selectedTab == tab
        return Button {
            store.send(.didSelectTab(tab))
        } label: {
            Text(tab.rawValue)
                .baziFont(isSelected ? .small14SB : .small14R)
                .foregroundStyle(isSelected ? Color.bazi(.primary) : Color.gray500)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
                .overlay(alignment: .bottom) {
                    if isSelected {
                        Rectangle()
                            .fill(Color.bazi(.primary))
                            .frame(height: 1.667)
                    }
                }
        }
        .buttonStyle(.plain)
    }

    private var resultsToolbar: some View {
        HStack {
            Text("\(store.policies.count)개")
                .baziFont(.small14R)
                .foregroundStyle(Color.gray600)
            Spacer()
            Button {
                store.send(.didTapSortOrder)
            } label: {
                Label(store.sortOrder.rawValue, systemImage: "arrow.up.arrow.down")
                    .labelStyle(.titleAndIcon)
            }
            .buttonStyle(.plain)
            .baziFont(.small14R)
            .foregroundStyle(Color.gray600)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    private var policyList: some View {
        LazyVStack(spacing: 12) {
            ForEach(store.policies) { policy in
                BZCard(
                    size: .medium,
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
        .padding(.horizontal, 16)
    }

    private var emptyPolicyList: some View {
        Text(store.selectedTab == .policy ? "이 날짜에는 등록된 정책이 없어요" : "상시모집 중인 정책이 없어요")
            .baziFont(.small14R)
            .foregroundStyle(Color.gray400)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
    }
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
    state.policies = []

    return MyPolicyView(
        store: Store(initialState: state) {
            EmptyReducer()
        }
    )
}

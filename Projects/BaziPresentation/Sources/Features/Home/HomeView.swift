// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import BaziDesign
import ComposableArchitecture

public struct HomeView: View {

    // MARK: - Properties

    @Bindable var store: StoreOf<HomeFeature>

    // MARK: - Init

    public init(store: StoreOf<HomeFeature>) {
        self.store = store
    }

    // MARK: - Body

    public var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            content
                .task { store.send(.onAppear) }
                .baziNavigationBar_home {
                    store.send(.didTapBell)
                }
        } destination: { store in
            switch store.case {
            case .categoryPolicyList(let store):
                CategoryPolicyListView(store: store)
            case .rankedPolicyList(let store):
                RankedPolicyListView(store: store)
            case .customPolicyList(let store):
                CustomPolicyListView(store: store)
            case .detail(let store):
                PlaceholderDetailView(store: store)
            }
        }
    }
}

// MARK: - Subviews

extension HomeView {

    private var content: some View {
        ScrollView {
            VStack(spacing: 0) {
                personalizedSection
                categorySection
                cardRowSection(
                    title: "최근 본 정책",
                    subtitle: "내가 관심 있게 살펴본 정책이에요!",
                    policies: store.recentViewedPolicies,
                    section: .recentViewed
                )
                cardRowSection(
                    title: "인기 정책",
                    subtitle: "가장 인기 있는 정책을 모아봤어요!",
                    policies: store.popularPolicies,
                    section: .popular,
                    moreAction: { store.send(.didTapPopularMore) }
                )
                cardRowSection(
                    title: "마감임박 정책",
                    subtitle: "곧 마감되는 정책을 놓치지 마세요!",
                    policies: store.deadlinePolicies,
                    section: .deadline,
                    moreAction: { store.send(.didTapDeadlineMore) }
                )
                cardRowSection(
                    title: "새로 뜬 정책",
                    subtitle: "따끈하게 새로 올라온 정책을 먼저 확인해봐요!",
                    policies: store.newPolicies,
                    section: .newest,
                    moreAction: { store.send(.didTapNewMore) }
                )
            }
            .padding(.bottom, 20)
        }
        .baziBackground(.bgGray)
    }
}

// MARK: - Personalized Section

extension HomeView {

    private var personalizedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if store.personalizedPolicies.isEmpty {
                personalizedEmptyState
            } else {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(store.userName)님을 기다리는 정책")
                            .baziFont(.head20B)
                            .foregroundStyle(Color.gray900)
                        Text("\(store.userName)님에게 딱 맞는 정책이에요!")
                            .baziFont(.small14R)
                            .foregroundStyle(Color.gray500)
                    }
                    Spacer()
                    Button("더 보기") {
                        store.send(.didTapPersonalizedMore)
                    }
                    .baziFont(.small12R)
                    .foregroundStyle(Color.gray600)
                }
                .padding(.horizontal, 20)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(store.personalizedPolicies) { policy in
                            BZCard(
                                size: .large,
                                category: policy.category.rawValue,
                                dDay: policy.dDay,
                                title: policy.title,
                                viewCount: policy.viewCount,
                                isBookmarked: bookmarkBinding(section: .personalized, id: policy.id)
                            )
                            .onTapGesture { store.send(.didTapPolicy(section: .personalized, id: policy.id)) }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.blue100)
    }

    private var personalizedEmptyState: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top) {
                Text("\(store.userName)님 조건에 딱 맞는 정책이\n아직 없어요")
                    .baziFont(.head20B)
                    .foregroundStyle(Color.gray900)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                Image.bazi(.personalizedEmptyIllustration)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60)
            }

            Button {
                store.send(.didTapPersonalizedEmptyCTA)
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("맞춤 조건 다시 설정하기")
                            .baziFont(.body16B)
                            .foregroundStyle(Color.bazi(.primary))
                        Text("관심 분야를 추가하면\n더 많은 정책을 만날 수 있어요!")
                            .baziFont(.small14R)
                            .foregroundStyle(Color.gray600)
                    }
                    Spacer()
                    Circle()
                        .strokeBorder(Color.gray200, lineWidth: 0.8)
                        .frame(width: 38, height: 38)
                        .overlay {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.gray700)
                        }
                }
                .padding(.horizontal, 20)
                .frame(height: 100)
                .frame(maxWidth: .infinity)
                .baziBackground(.bgWhite)
                .baziRadius(.medium)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Category Section

extension HomeView {

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("분야별 정책")
                    .baziFont(.head18B)
                    .foregroundStyle(Color.gray900)
                Text("필요한 정책을 분야별로 빠르게 찾아보세요!")
                    .baziFont(.small14R)
                    .foregroundStyle(Color.gray500)
            }

            HStack {
                ForEach(PolicyCategory.allCases) { category in
                    categoryButton(category)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 22)
    }

    private func categoryButton(_ category: PolicyCategory) -> some View {
        Button {
            store.send(.didTapCategory(category))
        } label: {
            VStack(spacing: 4) {
                category.icon.image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .frame(width: 56, height: 56)
                    .baziBackground(.bgWhite)
                    .baziRadius(.medium)
                Text(category.rawValue)
                    .baziFont(.small12R)
                    .foregroundStyle(Color.gray700)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Card Row Section

extension HomeView {

    private func cardRowSection(
        title: String,
        subtitle: String,
        policies: IdentifiedArrayOf<PolicySummary>,
        section: HomeFeature.PolicySection,
        moreAction: (() -> Void)? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .baziFont(.head18B)
                        .foregroundStyle(Color.gray900)
                    Text(subtitle)
                        .baziFont(.small14R)
                        .foregroundStyle(Color.gray500)
                }
                Spacer()
                if let moreAction {
                    Button("더보기", action: moreAction)
                        .baziFont(.small12R)
                        .foregroundStyle(Color.gray400)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(policies) { policy in
                        BZCard(
                            size: .small,
                            category: policy.category.rawValue,
                            dDay: policy.dDay,
                            title: policy.title,
                            viewCount: policy.viewCount,
                            isBookmarked: bookmarkBinding(section: section, id: policy.id)
                        )
                        .onTapGesture { store.send(.didTapPolicy(section: section, id: policy.id)) }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 44)
    }
}

// MARK: - Bindings

extension HomeView {

    private func bookmarkBinding(section: HomeFeature.PolicySection, id: Int) -> Binding<Bool> {
        Binding(
            get: {
                switch section {
                case .personalized: return store.personalizedPolicies[id: id]?.isBookmarked ?? false
                case .recentViewed: return store.recentViewedPolicies[id: id]?.isBookmarked ?? false
                case .popular: return store.popularPolicies[id: id]?.isBookmarked ?? false
                case .deadline: return store.deadlinePolicies[id: id]?.isBookmarked ?? false
                case .newest: return store.newPolicies[id: id]?.isBookmarked ?? false
                }
            },
            set: { _ in store.send(.didToggleBookmark(section: section, id: id)) }
        )
    }
}

// MARK: - Preview

#Preview("맞춤정책 있음") {
    HomeView(
        store: Store(initialState: .init()) {
            HomeFeature()
        }
    )
}

#Preview("맞춤정책 없음") {
    var emptyPersonalizedState = HomeFeature.State()
    emptyPersonalizedState.personalizedPolicies = []
    emptyPersonalizedState.recentViewedPolicies = IdentifiedArray(uniqueElements: Array(PolicySummary.mockList.suffix(2)))
    emptyPersonalizedState.popularPolicies = IdentifiedArray(uniqueElements: Array(PolicySummary.mockList.prefix(2)))
    emptyPersonalizedState.deadlinePolicies = IdentifiedArray(uniqueElements: Array(PolicySummary.mockList.dropFirst(2).prefix(2)))
    emptyPersonalizedState.newPolicies = IdentifiedArray(uniqueElements: Array(PolicySummary.mockList.dropFirst(4).prefix(2)))

    return HomeView(
        store: Store(initialState: emptyPersonalizedState) {
            EmptyReducer()
        }
    )
}

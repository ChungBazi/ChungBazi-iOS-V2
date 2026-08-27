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
                .task { store.send(.task) }
                .baziNavigationBar_home(
                    hasUnread: store.feed.value?.hasUnreadNotification ?? false
                ) {
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

// MARK: - Content (LoadingState 분기)

extension HomeView {

    private var content: some View {
        Group {
            switch store.feed {
            case .idle, .loading:
                loadingView
            case let .loaded(feed):
                loadedContent(feed)
            case .failed:
                retryView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .baziBackground(.bgGray)
    }

    private var loadingView: some View {
        BZLoadingView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var retryView: some View {
        // .failed의 연관 메시지는 로깅용이며, 화면엔 BZRetryView의 고정 문구를 쓴다.
        BZRetryView {
            store.send(.didTapRetry)
        }
    }

    private func loadedContent(_ feed: HomeFeedVO) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                personalizedSection(feed)
                categorySection
                cardRowSection(
                    title: "최근 본 정책",
                    subtitle: "내가 관심 있게 살펴본 정책이에요!",
                    emptyMessage: "관심 가는 정책을 눌러보세요",
                    policies: feed.recentViewed,
                    section: .recentViewed
                )
                cardRowSection(
                    title: "인기 정책",
                    subtitle: "가장 인기 있는 정책을 모아봤어요!",
                    emptyMessage: "지금은 인기 정책이 없어요",
                    policies: feed.popular,
                    section: .popular,
                    moreAction: { store.send(.didTapPopularMore) }
                )
                cardRowSection(
                    title: "마감임박 정책",
                    subtitle: "곧 마감되는 정책을 놓치지 마세요!",
                    emptyMessage: "마감이 임박한 정책이 없어요",
                    policies: feed.deadline,
                    section: .deadline,
                    moreAction: { store.send(.didTapDeadlineMore) }
                )
                cardRowSection(
                    title: "새로 뜬 정책",
                    subtitle: "따끈하게 새로 올라온 정책을 먼저 확인해봐요!",
                    emptyMessage: "새로 올라온 정책이 없어요",
                    policies: feed.newest,
                    section: .newest,
                    moreAction: { store.send(.didTapNewMore) }
                )
            }
            .padding(.bottom, 20)
        }
        .refreshable { await store.send(.pullToRefresh).finish() }
    }
}

// MARK: - Personalized Section

extension HomeView {

    private func personalizedSection(_ feed: HomeFeedVO) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if feed.personalized.isEmpty {
                personalizedEmptyState
            } else {
                personalizedContent(feed.personalized)
            }
        }
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.blue100)
    }

    private func personalizedContent(_ policies: IdentifiedArrayOf<PolicySummaryVO>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
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
                LazyHStack(spacing: 10) {
                    ForEach(policies) { policy in
                        BZCard(
                            size: .large,
                            category: policy.category.rawValue,
                            dDay: policy.dDay,
                            title: policy.title,
                            viewCount: policy.viewCount,
                            image: policy.category.cardImage.image,
                            isBookmarked: bookmarkBinding(section: .personalized, id: policy.id)
                        )
                        .onTapGesture { store.send(.didTapPolicy(section: .personalized, id: policy.id)) }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private var personalizedEmptyState: some View {
        VStack(spacing: 12) {
            Text("\(store.userName)님 조건에 딱 맞는 정책이\n아직 없어요")
                .baziFont(.head20B)
                .foregroundStyle(Color.gray900)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.trailing, 75) // glassBaro 자리 확보

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
                BZCircleButton {
                    store.send(.didTapPersonalizedEmptyCTA)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            .frame(maxWidth: .infinity)
            .baziBackground(.bgWhite)
            .baziRadius(.medium)
        }
        .background(alignment: .topTrailing) {
            Image.bazi(.glassBaro)
                .resizable()
                .scaledToFit()
                .frame(width: 75)
                .padding(.trailing, 15)
                .padding(.top, 5)
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
                ForEach(PolicyCategoryUI.allCases) { category in
                    categoryButton(category)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 22)
    }

    private func categoryButton(_ category: PolicyCategoryUI) -> some View {
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
        emptyMessage: String,
        policies: IdentifiedArrayOf<PolicySummaryVO>,
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
                if let moreAction, !policies.isEmpty {
                    Button("더보기", action: moreAction)
                        .baziFont(.small12R)
                        .foregroundStyle(Color.gray400)
                }
            }
            .padding(.horizontal, 20)

            if policies.isEmpty {
                Text(emptyMessage)
                    .baziFont(.small14R)
                    .foregroundStyle(Color.gray400)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 12) {
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
                    .padding(.horizontal, 20)
                }
            }
        }
        .padding(.top, 44)
    }
}

// MARK: - Bindings

extension HomeView {

    private func bookmarkBinding(section: HomeFeature.PolicySection, id: Int) -> Binding<Bool> {
        Binding(
            get: {
                guard let feed = store.feed.value else { return false }
                switch section {
                case .personalized: return feed.personalized[id: id]?.isBookmarked ?? false
                case .recentViewed: return feed.recentViewed[id: id]?.isBookmarked ?? false
                case .popular: return feed.popular[id: id]?.isBookmarked ?? false
                case .deadline: return feed.deadline[id: id]?.isBookmarked ?? false
                case .newest: return feed.newest[id: id]?.isBookmarked ?? false
                }
            },
            set: { _ in store.send(.didToggleBookmark(section: section, id: id)) }
        )
    }
}

// MARK: - Preview

#Preview("맞춤정책 있음") {
    var state = HomeFeature.State()
    state.userName = "바지"
    state.feed = .loaded(.mock)
    return HomeView(
        store: Store(initialState: state) {
            HomeFeature()
        }
    )
}

#Preview("맞춤정책 없음") {
    var emptyFeed = HomeFeedVO.mock
    emptyFeed.personalized = []
    var state = HomeFeature.State()
    state.userName = "바지"
    state.feed = .loaded(emptyFeed)
    return HomeView(
        store: Store(initialState: state) {
            HomeFeature()
        }
    )
}

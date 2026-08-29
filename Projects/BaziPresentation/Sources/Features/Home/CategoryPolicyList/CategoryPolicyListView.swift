// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import BaziDesign
import ComposableArchitecture

public struct CategoryPolicyListView: View {

    // MARK: - Properties

    @Bindable var store: StoreOf<CategoryPolicyListFeature>
    @Environment(\.dismiss) private var dismiss

    // MARK: - Init

    public init(store: StoreOf<CategoryPolicyListFeature>) {
        self.store = store
    }

    // MARK: - Body

    public var body: some View {
        content
            .task { store.send(.task) }
            .baziNavigationBar_backWithTitle("분야별 정책") {
                dismiss()
            }
    }
}

// MARK: - Subviews

extension CategoryPolicyListView {

    private var content: some View {
        VStack(spacing: 0) {
            BZSegmentControl(
                options: PolicyCategoryUI.allCases.map(\.rawValue),
                selection: categorySelection
            ) { _ in EmptyView() }
                .baziBackground(.bgWhite)

            listArea
        }
    }

    @ViewBuilder
    private var listArea: some View {
        switch store.list {
        case .idle, .loading:
            BZLoadingView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .baziBackground(.bgGray)

        case .failed:
            BZRetryView { store.send(.didTapRetry) }
                .baziBackground(.bgGray)

        case .loaded(let policies):
            loadedContent(policies)
        }
    }

    private func loadedContent(_ policies: IdentifiedArrayOf<PolicySummaryVO>) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                if !store.teaser.isEmpty {
                    personalizedBanner
                }
                if policies.isEmpty {
                    emptyView
                } else {
                    resultsToolbar
                    policyList(policies)
                }
            }
        }
        .baziBackground(.bgGray)
        .refreshable { await store.send(.pullToRefresh).finish() }
    }

    private var personalizedBanner: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                Text("\(store.selectedCategory.categoryHeadline)\n\(store.displayName)님 맞춤 정책이에요")
                    .baziFont(.head18B)
                    .foregroundStyle(Color.gray900)
                Spacer()
                Button("더 보기") {
                    store.send(.didTapPersonalizedMore)
                }
                .baziFont(.small12R)
                .foregroundStyle(Color.gray600)
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(store.teaser) { policy in
                        BZCard(
                            size: .small,
                            category: policy.category.rawValue,
                            dDay: policy.dDay,
                            title: policy.title,
                            viewCount: policy.viewCount,
                            isLiked: teaserLikeBinding(id: policy.id)
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.blue100)
    }

    private var resultsToolbar: some View {
        BZResultsToolbar(count: store.pagination.totalCount, sortTitle: store.sortOrder.rawValue) {
            store.send(.didTapSortOrder)
        }
    }

    private func policyList(_ policies: IdentifiedArrayOf<PolicySummaryVO>) -> some View {
        LazyVStack(spacing: 12) {
            ForEach(policies) { policy in
                BZCard(
                    size: .medium,
                    category: policy.category.rawValue,
                    dDay: policy.dDay,
                    title: policy.title,
                    viewCount: policy.viewCount,
                    isLiked: likeBinding(id: policy.id)
                )
                .onTapGesture { store.send(.didTapPolicy(id: policy.id)) }
                .onAppear {
                    if policy.id == policies.last?.id {
                        store.send(.didReachListEnd)
                    }
                }
            }
        }
        .padding(.top, 8)
        .padding([.horizontal, .bottom], 20)
    }

    private var emptyView: some View {
        BZEmptyView(message: "조건에 맞는 정책이 없어요")
    }
}

// MARK: - Bindings

extension CategoryPolicyListView {

    private var categorySelection: Binding<String> {
        Binding(
            get: { store.selectedCategory.rawValue },
            set: { newValue in
                guard let category = PolicyCategoryUI(rawValue: newValue) else { return }
                store.send(.didSelectCategory(category))
            }
        )
    }

    private func likeBinding(id: Int) -> Binding<Bool> {
        Binding(
            get: { store.list.value?[id: id]?.isLiked ?? false },
            set: { _ in store.send(.didToggleLike(id: id)) }
        )
    }

    private func teaserLikeBinding(id: Int) -> Binding<Bool> {
        Binding(
            get: { store.teaser[id: id]?.isLiked ?? false },
            set: { _ in store.send(.didToggleTeaserLike(id: id)) }
        )
    }
}

// MARK: - PolicyCategoryUI + Headline

extension PolicyCategoryUI {
    fileprivate var categoryHeadline: String {
        switch self {
        case .job: return "취업과 창업에 도움이 될"
        case .dwelling: return "주거비 부담을 덜어줄"
        case .study: return "배움과 자기계발에 도움이 될"
        case .livingSupport: return "일상생활의 부담을 덜어줄"
        case .activity: return "다양한 경험과 새로운 도전에 도움이 될"
        }
    }
}

// MARK: - Preview

#Preview("취업·창업") {
    NavigationStack {
        CategoryPolicyListView(
            store: Store(initialState: .init(selectedCategory: .job)) {
                CategoryPolicyListFeature()
            }
        )
    }
}

#Preview("월세·주거") {
    NavigationStack {
        CategoryPolicyListView(
            store: Store(initialState: .init(selectedCategory: .dwelling)) {
                CategoryPolicyListFeature()
            }
        )
    }
}

#Preview("목록 빔 · 티저 있음") {
    var state = CategoryPolicyListFeature.State(selectedCategory: .job)
    state.teaser = IdentifiedArray(uniqueElements: PolicySummaryVO.mockList)
    state.list = .loaded([])

    return NavigationStack {
        CategoryPolicyListView(
            store: Store(initialState: state) {
                EmptyReducer()
            }
        )
    }
}

#Preview("목록 빔 · 티저 없음") {
    var state = CategoryPolicyListFeature.State(selectedCategory: .job)
    state.teaser = []
    state.list = .loaded([])

    return NavigationStack {
        CategoryPolicyListView(
            store: Store(initialState: state) {
                EmptyReducer()
            }
        )
    }
}

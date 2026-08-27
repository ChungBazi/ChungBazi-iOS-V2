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
            .task { store.send(.onAppear) }
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
                options: PolicyCategory.allCases.map(\.rawValue),
                selection: categorySelection
            ) { _ in EmptyView() }
                .baziBackground(.bgWhite)

            ScrollView {
                VStack(spacing: 0) {
                    personalizedBanner
                    resultsToolbar
                    policyList
                }
            }
            .baziBackground(.bgGray)
        }
    }

    private var personalizedBanner: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                Text("\(store.selectedCategory.categoryHeadline)\n민재님 맞춤 정책이에요")
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
                    ForEach(store.personalizedTeaser) { policy in
                        BZCard(
                            size: .small,
                            category: policy.category.rawValue,
                            dDay: policy.dDay,
                            title: policy.title,
                            viewCount: policy.viewCount,
                            isBookmarked: teaserBookmarkBinding(id: policy.id)
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
        HStack {
            Text("\(store.policies.count)개")
            Spacer()
            Button {
                store.send(.didTapSortOrder)
            } label: {
                HStack(spacing: 3) {
                    Image(systemName: "arrow.up.arrow.down")
                    Text(store.sortOrder.rawValue)
                }
            }
        }
        .baziFont(.small14R)
        .foregroundStyle(Color.gray600)
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
                    isBookmarked: bookmarkBinding(id: policy.id)
                )
                .onTapGesture { store.send(.didTapPolicy(id: policy.id)) }
            }
        }
        .padding([.horizontal, .bottom], 20)
    }
}

// MARK: - Bindings

extension CategoryPolicyListView {

    private var categorySelection: Binding<String> {
        Binding(
            get: { store.selectedCategory.rawValue },
            set: { newValue in
                guard let category = PolicyCategory(rawValue: newValue) else { return }
                store.send(.didSelectCategory(category))
            }
        )
    }

    private func bookmarkBinding(id: Int) -> Binding<Bool> {
        Binding(
            get: { store.policies[id: id]?.isBookmarked ?? false },
            set: { _ in store.send(.didToggleBookmark(id: id)) }
        )
    }

    private func teaserBookmarkBinding(id: Int) -> Binding<Bool> {
        Binding(
            get: { store.personalizedTeaser[id: id]?.isBookmarked ?? false },
            set: { _ in store.send(.didToggleTeaserBookmark(id: id)) }
        )
    }
}

// MARK: - PolicyCategory + Headline

extension PolicyCategory {
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

// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import BaziDesign
import ComposableArchitecture

public struct PolicyDetailView: View {

    // MARK: - Properties

    @Bindable var store: StoreOf<PolicyDetailFeature>
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    // MARK: - Init

    public init(store: StoreOf<PolicyDetailFeature>) {
        self.store = store
    }

    // MARK: - Body

    public var body: some View {
        Group {
            switch store.detail {
            case .idle, .loading:
                BZLoadingView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .failed:
                BZRetryView { store.send(.didTapRetry) }
            case .loaded(let detail):
                content(detail)
            }
        }
        .task { store.send(.onAppear) }
        .baziNavigationBar(
            leading: .back(action: { dismiss() }),
            trailing: .share(action: { store.send(.didTapShare) })
        )
        .toolbar(.hidden, for: .tabBar)
    }
}

// MARK: - Subviews

extension PolicyDetailView {

    private func content(_ detail: PolicyDetailVO) -> some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    headerSection(detail)
                    qnaSection(detail)
                    if !detail.personalized.isEmpty {
                        recommendationSection(
                            title: "\(store.userName)님 이런 정책은 어때요?",
                            background: Color.green100,
                            policies: detail.personalized,
                            section: .personalized
                        )
                    }
                    if !detail.popular.isEmpty {
                        recommendationSection(
                            title: "\(detail.category.rawValue) 분야의 가장 인기 있는 정책",
                            background: Color.green50,
                            policies: detail.popular,
                            section: .popular
                        )
                    }
                }
            }
            ctaButtons
        }
        .baziBackground(.bgWhite)
    }

    private func headerSection(_ detail: PolicyDetailVO) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    BZTag(detail.category.rawValue, type: .blue200)
                    Text(detail.dDay)
                        .baziFont(.small12SB)
                        .foregroundStyle(Color.gray700)
                }
                Spacer()
                likeButton(isLiked: detail.isLiked)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(detail.title)
                    .baziFont(.head24B)
                    .foregroundStyle(Color.grayBlack)
                if !detail.summary.isEmpty {
                    Text(detail.summary)
                        .baziFont(.small14R)
                        .foregroundStyle(Color.grayBlack80)
                }
            }

            HStack(spacing: 4) {
                Image.bazi(.eyeIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 14)
                Text(detail.viewCount, format: .number)
                    .baziFont(.small12R)
            }
            .foregroundStyle(Color.gray400)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.blue50)
    }

    private func likeButton(isLiked: Bool) -> some View {
        Button {
            store.send(.didTapLike)
        } label: {
            Image.bazi(isLiked ? .filledStar : .unfilledStar)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("찜하기")
    }

    private func qnaSection(_ detail: PolicyDetailVO) -> some View {
        VStack(alignment: .leading, spacing: 32) {
            qnaRow(number: 1, question: "누가 신청할 수 있나요?", answer: detail.eligibilityDescription)
            qnaRow(number: 2, question: "언제 신청할 수 있나요?", answer: detail.applyPeriod)
            qnaRow(number: 3, question: "어떤 지원을 받을 수 있나요?", answer: detail.supportContent)
            qnaRow(number: 4, question: "어떻게 신청하나요?", answer: detail.applicationMethod)
            qnaRow(number: 5, question: "어떤 서류가 필요한가요?", answer: detail.submittedDocument)
            if let url = detail.referenceURLs.first {
                qnaRow(number: 6, question: "참고할 수 있는 링크예요", answer: url)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func qnaRow(number: Int, question: String, answer: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(number). \(question)")
                .baziFont(.body15SB)
                .foregroundStyle(Color.gray900)
            // 서버가 내용 없는 항목을 null(→ 빈 문자열)로 내려주므로 "-"로 대체 표시한다.
            Text(answer.isEmpty ? "-" : answer)
                .baziFont(.small14R)
                .foregroundStyle(Color.gray600)
                // 사용자가 답변/링크를 길게 눌러 복사할 수 있게 한다.
                .textSelection(.enabled)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func recommendationSection(
        title: String,
        background: Color,
        policies: IdentifiedArrayOf<PolicySummaryVO>,
        section: PolicyDetailFeature.RecommendationSection
    ) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(title)
                .baziFont(.head18B)
                .foregroundStyle(Color.gray900)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(policies) { policy in
                        BZCard(
                            size: .small,
                            category: policy.category.rawValue,
                            dDay: policy.dDay,
                            title: policy.title,
                            viewCount: policy.viewCount,
                            isLiked: recommendationLikeBinding(section: section, id: policy.id)
                        )
                        .onTapGesture { store.send(.didTapPolicy(id: policy.id)) }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(background)
    }

    private var ctaButtons: some View {
        // 신청 링크(참고 링크 첫 항목)가 없으면 신청 버튼을 비활성화한다.
        let applyURL = store.detail.value?.applyURL
        return HStack(spacing: 10) {
            BZButton("찜하기", type: .normal, size: .small) {
                store.send(.didTapLike)
            }
            BZButton("바로 신청하러 가기", type: .cta, size: .medium) {
                if let applyURL { openURL(applyURL) }
            }
            .disabled(applyURL == nil)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 5)
        .baziBackground(.bgWhite)
    }
}

// MARK: - Bindings

extension PolicyDetailView {

    private func recommendationLikeBinding(
        section: PolicyDetailFeature.RecommendationSection,
        id: Int
    ) -> Binding<Bool> {
        Binding(
            get: {
                switch section {
                case .personalized: return store.detail.value?.personalized[id: id]?.isLiked ?? false
                case .popular: return store.detail.value?.popular[id: id]?.isLiked ?? false
                }
            },
            set: { _ in store.send(.didToggleRecommendationLike(section: section, id: id)) }
        )
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PolicyDetailView(
            store: Store(initialState: .init(policyId: 1)) {
                PolicyDetailFeature()
            }
        )
    }
}

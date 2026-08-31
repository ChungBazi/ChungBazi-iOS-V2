// Copyright © 2026 ChungBazi. All rights reserved.

import BaziDesign
import BaziDomain
import ComposableArchitecture
import Foundation

/// 진입한 쪽(홈/분야별)이 넘겨준 맞춤 정책 id들의 카드(getPolicyCard)를 병렬로 조회한다.
@Reducer
public struct CustomPolicyListFeature {

    // MARK: - GuideStep

    public enum GuideStep: Equatable {
        case swipeHint
        case tapHint

        var next: GuideStep? { self == .swipeHint ? .tapHint : nil }
        var illustration: BaziImage { self == .swipeHint ? .dimSwipeIcon : .dimSimpleIcon }
        var message: String {
            self == .swipeHint
                ? "카드를 좌우로 넘기며\n맞춤 정책을 살펴보세요!"
                : "카드를 눌러 간편하게\n정책 정보를 확인해보세요!"
        }
        var buttonTitle: String { self == .swipeHint ? "다음" : "확인" }
    }

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        /// 분야별에서 진입 시 해당 분야. 홈 맞춤정책에서 진입하면 nil.
        public var category: PolicyCategoryUI?
        /// 카드로 보여줄 맞춤 정책 id 목록(진입 측에서 전달).
        public var policyIds: [Int]
        public var displayName = ""
        public var cards: LoadingState<IdentifiedArrayOf<PolicyCardVO>> = .idle
        /// 최초 진입 시에만 노출. `.task`에서 hasSeenGuide로 결정한다.
        public var guideStep: GuideStep?
        /// 홈·내정책이 반영하는 공유 찜 오버레이(id → liked).
        @Shared(.likeOverrides) public var likeOverrides: [Int: Bool] = [:]

        public init(category: PolicyCategoryUI? = nil, policyIds: [Int] = []) {
            self.category = category
            self.policyIds = policyIds
        }
    }

    // MARK: - Action

    public enum Action: Equatable {
        // MARK: View
        case onAppear
        case didTapRetry
        case didToggleLike(id: Int)
        case didTapDetail(id: Int)
        case didTapApply(id: Int)
        case didShowCard(id: Int)
        case didTapGuideNext

        // MARK: Internal
        case cardsResponse(Result<[PolicyCardVO], UseCaseError>)
        case summarizeStarted(id: Int)
        case summaryResponse(id: Int, summary: String?)
        case likeFailed(id: Int, liked: Bool)

        // MARK: Delegate
        case delegate(Delegate)
    }

    // MARK: - Delegate

    public enum Delegate: Equatable {
        case didSelectPolicy(id: Int)
    }

    // MARK: - Dependencies

    @Dependency(\.customPolicyClient) var customPolicyClient
    @Dependency(\.sessionClient) var sessionClient
    @Dependency(\.policyLikeClient) var policyLikeClient
    @Dependency(\.continuousClock) var clock
    @Dependency(\.openURL) var openURL

    // MARK: - Init

    public init() {}

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard state.cards.value == nil, !state.cards.isLoading else { return .none }
                state.displayName = sessionClient.displayName()
                if !customPolicyClient.hasSeenGuide() {
                    state.guideStep = .swipeHint
                }
                return loadCards(&state)

            case .didTapRetry:
                return loadCards(&state)

            case .didTapApply(let id):
                guard
                    let urlString = state.cards.value?[id: id]?.applyUrl,
                    let url = URL(string: urlString)
                else { return .none }
                return .run { [openURL] _ in _ = await openURL(url) }

            case let .cardsResponse(.success(cards)):
                state.cards = .loaded(IdentifiedArray(deduplicating: cards))
                return .none

            case let .cardsResponse(.failure(error)):
                if state.cards.value == nil {
                    state.cards = .failed(error.loadFailureMessage)
                }
                return .none

            case .didShowCard(let id):
                // 지원 기기면 현재 보이는 카드를 미리 요약. 스크롤로 지나친 카드는 debounce+취소로 추론을 생략한다.
                guard
                    customPolicyClient.isAISummaryAvailable(),
                    let card = state.cards.value?[id: id],
                    card.aiSummary == .idle
                else { return .none }
                let content = card.supportContent
                return .run { [customPolicyClient, clock] send in
                    // 스크롤이 정착한 카드만 요약. 지나친 카드는 아래 cancellable로 취소돼 .idle로 남는다.
                    try await clock.sleep(for: .milliseconds(300))
                    await send(.summarizeStarted(id: id))
                    let summary = await customPolicyClient.summarize(content)
                    await send(.summaryResponse(id: id, summary: summary))
                }
                .cancellable(id: CancelID.summarize, cancelInFlight: true)

            case .summarizeStarted(let id):
                guard var cards = state.cards.value, cards[id: id]?.aiSummary == .idle else { return .none }
                cards[id: id]?.aiSummary = .loading
                state.cards = .loaded(cards)
                return .none

            case let .summaryResponse(id, summary):
                guard var cards = state.cards.value else { return .none }
                cards[id: id]?.aiSummary = summary.map(CardSummaryState.ready) ?? .unavailable
                state.cards = .loaded(cards)
                return .none

            case .didToggleLike(let id):
                guard var cards = state.cards.value, let current = cards[id: id]?.isLiked else { return .none }
                let newValue = !current
                cards[id: id]?.isLiked = newValue
                state.cards = .loaded(cards)
                state.$likeOverrides.withLock { $0[id] = newValue }
                return likeEffect(id: id, liked: newValue)

            case let .likeFailed(id, liked):
                guard var cards = state.cards.value else { return .none }
                cards[id: id]?.isLiked = !liked
                state.cards = .loaded(cards)
                state.$likeOverrides.withLock { $0[id] = !liked }
                return .none

            case .didTapDetail(let id):
                return .send(.delegate(.didSelectPolicy(id: id)))

            case .didTapGuideNext:
                state.guideStep = state.guideStep?.next
                if state.guideStep == nil {
                    return .run { [customPolicyClient] _ in customPolicyClient.markGuideSeen() }
                }
                return .none

            case .delegate:
                return .none
            }
        }
    }

    // MARK: - Private

    private enum CancelID: Hashable { case like(Int), summarize }

    /// 찜 토글: 서버 반영. 실패 시 likeFailed로 롤백한다. 연타는 정책별로 취소.
    private func likeEffect(id: Int, liked: Bool) -> Effect<Action> {
        .run { [policyLikeClient] send in
            do {
                try await policyLikeClient.setLike(id, liked)
            } catch {
                await send(.likeFailed(id: id, liked: liked))
            }
        }
        .cancellable(id: CancelID.like(id), cancelInFlight: true)
    }

    /// 전달받은 id들의 카드를 병렬로 조회한다.
    private func loadCards(_ state: inout State) -> Effect<Action> {
        let ids = state.policyIds
        guard !ids.isEmpty else {
            state.cards = .loaded([])
            return .none
        }
        state.cards = .loading
        return .run { [customPolicyClient, clock] send in
            do {
                // push 전환이 끝난 뒤 노출하도록 최소 로딩 시간을 함께 기다린다.
                async let settle: Void = clock.sleep(for: .milliseconds(400))
                let cards = try await withThrowingTaskGroup(of: (Int, PolicyCardVO).self) { group in
                    for (index, id) in ids.enumerated() {
                        group.addTask { (index, try await customPolicyClient.fetchCard(id)) }
                    }
                    var collected: [(Int, PolicyCardVO)] = []
                    for try await pair in group { collected.append(pair) }
                    return collected.sorted { $0.0 < $1.0 }.map(\.1)
                }
                try await settle
                await send(.cardsResponse(.success(cards)))
            } catch {
                await send(.cardsResponse(.failure(UseCaseError.map(error))))
            }
        }
    }
}

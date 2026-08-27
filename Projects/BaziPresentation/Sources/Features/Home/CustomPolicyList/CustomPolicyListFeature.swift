// Copyright © 2026 ChungBazi. All rights reserved.

import BaziDesign
import BaziDomain
import ComposableArchitecture

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
        public var category: PolicyCategory?
        /// 카드로 보여줄 맞춤 정책 id 목록(진입 측에서 전달).
        public var policyIds: [Int]
        public var userName = ""
        public var cards: LoadingState<IdentifiedArrayOf<PolicyCardVO>> = .idle
        /// 최초 진입 시에만 노출. `.task`에서 hasSeenGuide로 결정한다.
        public var guideStep: GuideStep?
        /// 요약 진행 중인 카드 id(뒷면 로딩 표시용).
        public var summarizingIds: Set<Int> = []
        /// 이미 요약을 요청한 카드 id(중복 요청 방지).
        public var requestedSummaries: Set<Int> = []

        public init(category: PolicyCategory? = nil, policyIds: [Int] = []) {
            self.category = category
            self.policyIds = policyIds
        }
    }

    // MARK: - Action

    public enum Action {
        // MARK: View
        case task
        case didTapRetry
        case didToggleBookmark(id: Int)
        case didTapDetail(id: Int)
        case didShowCard(id: Int)
        case didTapGuideNext

        // MARK: Internal
        case cardsResponse(Result<[PolicyCardVO], UseCaseError>)
        case summaryResponse(id: Int, summary: String?)

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

    // MARK: - Init

    public init() {}

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                guard state.cards.value == nil, !state.cards.isLoading else { return .none }
                state.userName = sessionClient.userName() ?? ""
                if !customPolicyClient.hasSeenGuide() {
                    state.guideStep = .swipeHint
                }
                return loadCards(&state)

            case .didTapRetry:
                return loadCards(&state)

            case let .cardsResponse(.success(cards)):
                state.cards = .loaded(IdentifiedArray(uniqueElements: cards))
                return .none

            case let .cardsResponse(.failure(error)):
                if state.cards.value == nil {
                    state.cards = .failed(error.loadFailureMessage)
                }
                return .none

            case .didShowCard(let id):
                // 지원 기기면 현재 보이는 카드를 미리 요약(뒤집기 전에 준비). 1회만.
                guard
                    customPolicyClient.isAISummaryAvailable(),
                    let card = state.cards.value?[id: id],
                    card.aiSummary == nil,
                    !state.requestedSummaries.contains(id)
                else { return .none }
                state.requestedSummaries.insert(id)
                state.summarizingIds.insert(id)
                let content = card.supportContent
                return .run { [customPolicyClient] send in
                    let summary = await customPolicyClient.summarize(content)
                    await send(.summaryResponse(id: id, summary: summary))
                }

            case let .summaryResponse(id, summary):
                state.summarizingIds.remove(id)
                if let summary {
                    guard var cards = state.cards.value else { return .none }
                    cards[id: id]?.aiSummary = summary
                    state.cards = .loaded(cards)
                }
                return .none

            case .didToggleBookmark(let id):
                guard var cards = state.cards.value else { return .none }
                cards[id: id]?.isBookmarked.toggle()
                state.cards = .loaded(cards)
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

    /// 전달받은 id들의 카드를 병렬로 조회한다.
    private func loadCards(_ state: inout State) -> Effect<Action> {
        let ids = state.policyIds
        guard !ids.isEmpty else {
            state.cards = .loaded([])
            return .none
        }
        state.cards = .loading
        return .run { [customPolicyClient] send in
            do {
                let cards = try await withThrowingTaskGroup(of: (Int, PolicyCardVO).self) { group in
                    for (index, id) in ids.enumerated() {
                        group.addTask { (index, try await customPolicyClient.fetchCard(id)) }
                    }
                    var collected: [(Int, PolicyCardVO)] = []
                    for try await pair in group { collected.append(pair) }
                    return collected.sorted { $0.0 < $1.0 }.map(\.1)
                }
                await send(.cardsResponse(.success(cards)))
            } catch {
                await send(.cardsResponse(.failure(UseCaseError.map(error))))
            }
        }
    }
}

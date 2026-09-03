// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziDomain
import ComposableArchitecture

/// 검색 메인 화면. 최근 검색어·자동완성 + 검색 제출로 결과 화면에 진입한다.
/// 최근 검색어/자동저장/자동완성은 모두 서버가 관리한다(검색하면 서버가 최근검색에 자동 저장).
@Reducer
public struct SearchFeature {

    // MARK: - Navigation

    @Reducer
    public enum Path {
        case searchResult(SearchResultFeature)
        case detail(PolicyDetailFeature)
    }

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var path = StackState<Path.State>()

        public var query: String = ""
        public var recentKeywords: IdentifiedArrayOf<RecentSearchKeywordVO> = []
        public var isAutoSaveEnabled: Bool = true
        public var suggestions: [SearchSuggestionVO] = []
        /// 최근검색 삭제 실패 시 표시할 경고 토스트 메시지(nil이면 미표시).
        public var errorToast: String?

        public var isTyping: Bool { !query.isEmpty }

        public init() {}
    }

    // MARK: - Action

    public enum Action {
        // MARK: View
        case onAppear
        case didChangeQuery(String)
        case didSubmitQuery
        case didTapSuggestion(String)
        case didTapDeleteRecentKeyword(id: Int)
        case didTapDeleteAllRecentKeywords
        case didToggleAutoSave

        // MARK: Internal
        case recentSearchesResponse(Result<RecentSearchResultVO, UseCaseError>)
        case suggestionsResponse(Result<[SearchSuggestionVO], UseCaseError>)
        case deleteRecentFailed(UseCaseError)
        case dismissErrorToast

        // MARK: Child
        case path(StackActionOf<Path>)
    }

    // MARK: - Dependencies

    @Dependency(\.policySearchClient) var policySearchClient
    @Dependency(\.continuousClock) var clock
    @Dependency(\.analytics) var analytics

    // MARK: - Init

    public init() {}

    private static let recentSize = 10
    private enum CancelID { case suggestions, recentSearches }

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .merge(
                    .run { [policySearchClient] send in
                        do {
                            let result = try await policySearchClient.recentSearches(nil, Self.recentSize)
                            await send(.recentSearchesResponse(.success(result)))
                        } catch {
                            await send(.recentSearchesResponse(.failure(UseCaseError.map(error))))
                        }
                    }
                    .cancellable(id: CancelID.recentSearches, cancelInFlight: true),
                    .run { [analytics] _ in analytics.track(.screenView(.search)) }
                )

            case let .recentSearchesResponse(.success(result)):
                state.recentKeywords = result.keywords
                state.isAutoSaveEnabled = result.autoSaveEnabled
                return .none

            case .recentSearchesResponse(.failure):
                return .none

            case .didChangeQuery(let query):
                state.query = query
                guard !query.isEmpty else {
                    state.suggestions = []
                    return .cancel(id: CancelID.suggestions)
                }
                // 입력 중 디바운스(0.3s) 후 서버 자동완성 조회. 다음 입력이 오면 취소.
                return .run { [policySearchClient, clock] send in
                    try await clock.sleep(for: .milliseconds(300))
                    do {
                        let suggestions = try await policySearchClient.suggestions(query)
                        await send(.suggestionsResponse(.success(suggestions)))
                    } catch {
                        await send(.suggestionsResponse(.failure(UseCaseError.map(error))))
                    }
                }
                .cancellable(id: CancelID.suggestions, cancelInFlight: true)

            case let .suggestionsResponse(.success(suggestions)):
                // 같은 키워드가 최근검색·정책후보로 중복될 수 있어, 먼저 온 항목(최근검색) 기준으로 dedup한다.
                var seen = Set<String>()
                state.suggestions = suggestions.filter { seen.insert($0.keyword).inserted }
                return .none

            case .suggestionsResponse(.failure):
                return .none

            case .didSubmitQuery:
                guard !state.query.isEmpty else { return .none }
                let query = state.query
                return .merge(submitSearch(state: &state, query: query), .run { [analytics] _ in
                    analytics.track(.search(keyword: query, source: .submit))
                })

            case .didTapSuggestion(let keyword):
                return .merge(submitSearch(state: &state, query: keyword), .run { [analytics] _ in
                    analytics.track(.search(keyword: keyword, source: .suggestion))
                })

            case .didTapDeleteRecentKeyword(let id):
                state.recentKeywords.remove(id: id)
                return .run { [policySearchClient] send in
                    do {
                        try await policySearchClient.deleteRecentSearch(id)
                    } catch {
                        await send(.deleteRecentFailed(UseCaseError.map(error)))
                    }
                }

            case .didTapDeleteAllRecentKeywords:
                state.recentKeywords.removeAll()
                return .run { [policySearchClient] send in
                    do {
                        try await policySearchClient.deleteAllRecentSearches()
                    } catch {
                        await send(.deleteRecentFailed(UseCaseError.map(error)))
                    }
                }

            case .deleteRecentFailed(let error):
                if error != .cancelled { state.errorToast = error.loadFailureMessage }
                return .none

            case .dismissErrorToast:
                state.errorToast = nil
                return .none

            case .didToggleAutoSave:
                let enabled = !state.isAutoSaveEnabled
                state.isAutoSaveEnabled = enabled
                // 끌 때는 서버 반영만. 켤 때는 서버 반영 후 최근 검색어를 다시 불러와 즉시 노출한다.
                guard enabled else {
                    // 진행 중인 재조회(ON)의 늦은 응답이 다시 ON으로 덮지 않도록 취소한다.
                    return .merge(
                        .cancel(id: CancelID.recentSearches),
                        .run { [policySearchClient] _ in
                            try? await policySearchClient.updateAutoSave(false)
                        }
                    )
                }
                return .run { [policySearchClient] send in
                    try? await policySearchClient.updateAutoSave(true)
                    do {
                        let result = try await policySearchClient.recentSearches(nil, Self.recentSize)
                        await send(.recentSearchesResponse(.success(result)))
                    } catch {
                        await send(.recentSearchesResponse(.failure(UseCaseError.map(error))))
                    }
                }
                .cancellable(id: CancelID.recentSearches, cancelInFlight: true)

            case .path(.element(_, .searchResult(.delegate(.didSelectPolicy(let id))))):
                state.path.append(.detail(PolicyDetailFeature.State(policyId: id)))
                return .run { [analytics] _ in
                    analytics.track(.policyDetailView(policyId: id, policyName: nil, category: nil, entryPoint: .search))
                }
            case .path(.element(_, .detail(.delegate(.didSelectPolicy(let id))))):
                state.path.append(.detail(PolicyDetailFeature.State(policyId: id)))
                return .run { [analytics] _ in
                    analytics.track(.policyDetailView(policyId: id, policyName: nil, category: nil, entryPoint: .recommendation))
                }

            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }

    // MARK: - Private

    private func submitSearch(state: inout State, query: String) -> Effect<Action> {
        state.query = query
        state.suggestions = []
        // 서버가 검색 시점에 최근검색을 저장한다. 낙관적 추가 없이 재진입(onAppear) 시 서버에서 다시 불러온다.
        state.path.append(.searchResult(SearchResultFeature.State(query: query)))
        return .merge(
            .cancel(id: CancelID.suggestions),
            .run { [analytics] _ in
                analytics.track(.policyListView(listType: .searchResult, entryPoint: .search, category: nil))
            }
        )
    }
}

extension SearchFeature.Path.State: Equatable {}

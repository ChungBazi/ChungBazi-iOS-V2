// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziData
import BaziDomain
import BaziPresentation

extension PolicySearchClient: @retroactive DependencyKey {

    public static let liveValue: PolicySearchClient = {
        let repository: any SearchRepository = SearchRepositoryImpl(networkProvider: AppDependencies.networkProvider)
        let searchUseCase: any SearchPoliciesUseCase = SearchPoliciesUseCaseImpl(searchRepository: repository)
        let suggestUseCase: any FetchSearchSuggestionsUseCase = FetchSearchSuggestionsUseCaseImpl(searchRepository: repository)
        let recentUseCase: any RecentSearchUseCase = RecentSearchUseCaseImpl(searchRepository: repository)

        return PolicySearchClient(
            search: { keyword, category, sort, cursor, size in
                PolicyPageVO(
                    try await searchUseCase.execute(
                        keyword: keyword,
                        category: category?.toDomain(),
                        sort: sort,
                        cursor: cursor,
                        size: size
                    )
                )
            },
            suggestions: { keyword in
                try await suggestUseCase.execute(keyword: keyword).map(SearchSuggestionVO.init)
            },
            recentSearches: { cursor, size in
                RecentSearchResultVO(try await recentUseCase.fetch(cursor: cursor, size: size))
            },
            deleteRecentSearch: { id in try await recentUseCase.delete(keywordId: id) },
            deleteAllRecentSearches: { try await recentUseCase.deleteAll() },
            updateAutoSave: { enabled in try await recentUseCase.updateAutoSave(enabled: enabled) }
        )
    }()
}

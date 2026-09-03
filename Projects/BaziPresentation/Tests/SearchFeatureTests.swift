// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture
import Testing

import BaziDomain
@testable import BaziPresentation

@MainActor
struct SearchFeatureTests {

    @Test("진입 시 최근 검색어와 자동저장 상태를 불러온다")
    func onAppear_loadsRecent() async {
        let store = TestStore(initialState: SearchFeature.State()) {
            SearchFeature()
        } withDependencies: {
            $0.policySearchClient.recentSearches = { _, _ in .mock }
        }

        await store.send(.onAppear)
        await store.receive(\.recentSearchesResponse.success) {
            $0.recentKeywords = RecentSearchResultVO.mock.keywords
            $0.isAutoSaveEnabled = RecentSearchResultVO.mock.autoSaveEnabled
        }
    }

    @Test("입력하면 디바운스 후 서버 자동완성을 가져온다")
    func didChangeQuery_fetchesSuggestions() async {
        let store = TestStore(initialState: SearchFeature.State()) {
            SearchFeature()
        } withDependencies: {
            $0.continuousClock = ImmediateClock()
            $0.policySearchClient.suggestions = { _ in SearchSuggestionVO.mockList }
        }

        await store.send(.didChangeQuery("청년")) {
            $0.query = "청년"
        }
        await store.receive(\.suggestionsResponse.success) {
            $0.suggestions = SearchSuggestionVO.mockList
        }
    }

    @Test("검색 제출 시 결과 화면으로 이동한다(최근 검색 저장은 서버 담당)")
    func didSubmitQuery_pushesResult() async {
        var state = SearchFeature.State()
        state.query = "청년 월세"
        let store = TestStore(initialState: state) {
            SearchFeature()
        }

        await store.send(.didSubmitQuery) {
            $0.suggestions = []
            $0.path.append(.searchResult(SearchResultFeature.State(query: "청년 월세")))
        }
    }

    @Test("최근 검색어 삭제는 목록에서 즉시 제거한다")
    func didTapDeleteRecentKeyword_removes() async {
        var state = SearchFeature.State()
        state.recentKeywords = RecentSearchResultVO.mock.keywords
        let store = TestStore(initialState: state) {
            SearchFeature()
        } withDependencies: {
            $0.policySearchClient.deleteRecentSearch = { _ in }
        }

        var expected = RecentSearchResultVO.mock.keywords
        expected.remove(id: 1)

        await store.send(.didTapDeleteRecentKeyword(id: 1)) {
            $0.recentKeywords = expected
        }
    }

    @Test("개별 삭제가 실패하고 재동기화도 실패하면 삭제 전 목록으로 복원한다")
    func deleteRecent_failure_resyncFailure_restores() async {
        var state = SearchFeature.State()
        state.recentKeywords = RecentSearchResultVO.mock.keywords
        let store = TestStore(initialState: state) {
            SearchFeature()
        } withDependencies: {
            $0.policySearchClient.deleteRecentSearch = { _ in throw UseCaseError.offline }
            $0.policySearchClient.recentSearches = { _, _ in throw UseCaseError.offline }
        }

        let original = RecentSearchResultVO.mock.keywords
        var afterDelete = original
        afterDelete.remove(id: 1)

        await store.send(.didTapDeleteRecentKeyword(id: 1)) {
            $0.recentKeywords = afterDelete
        }
        await store.receive(\.deleteRecentFailed) {
            $0.errorToast = UseCaseError.offline.toastMessage
        }
        await store.receive(\.recentResyncResponse) {
            $0.recentKeywords = original
        }
    }

    @Test("전체 삭제가 실패하고 재동기화도 실패하면 삭제 전 목록으로 복원한다")
    func deleteAllRecent_failure_resyncFailure_restores() async {
        var state = SearchFeature.State()
        state.recentKeywords = RecentSearchResultVO.mock.keywords
        let store = TestStore(initialState: state) {
            SearchFeature()
        } withDependencies: {
            $0.policySearchClient.deleteAllRecentSearches = { throw UseCaseError.offline }
            $0.policySearchClient.recentSearches = { _, _ in throw UseCaseError.offline }
        }

        let original = RecentSearchResultVO.mock.keywords

        await store.send(.didTapDeleteAllRecentKeywords) {
            $0.recentKeywords = []
        }
        await store.receive(\.deleteRecentFailed) {
            $0.errorToast = UseCaseError.offline.toastMessage
        }
        await store.receive(\.recentResyncResponse) {
            $0.recentKeywords = original
        }
    }

    @Test("삭제 실패 후 재동기화에 성공하면 서버 결과로 교체한다")
    func deleteRecent_failure_resyncSuccess_replacesWithServer() async {
        var state = SearchFeature.State()
        state.recentKeywords = RecentSearchResultVO.mock.keywords
        let store = TestStore(initialState: state) {
            SearchFeature()
        } withDependencies: {
            $0.policySearchClient.deleteRecentSearch = { _ in throw UseCaseError.offline }
            $0.policySearchClient.recentSearches = { _, _ in .mock }
        }

        var afterDelete = RecentSearchResultVO.mock.keywords
        afterDelete.remove(id: 1)

        await store.send(.didTapDeleteRecentKeyword(id: 1)) {
            $0.recentKeywords = afterDelete
        }
        await store.receive(\.deleteRecentFailed) {
            $0.errorToast = UseCaseError.offline.toastMessage
        }
        await store.receive(\.recentResyncResponse) {
            $0.recentKeywords = RecentSearchResultVO.mock.keywords
            $0.isAutoSaveEnabled = RecentSearchResultVO.mock.autoSaveEnabled
        }
    }
}

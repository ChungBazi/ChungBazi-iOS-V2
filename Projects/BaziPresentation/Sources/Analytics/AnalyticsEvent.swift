// Copyright © 2026 ChungBazi. All rights reserved.

/// Amplitude로 전송할 타입드 분석 이벤트. `name`/`properties`로 매핑한다.
/// (단계별로 case를 추가한다 — Phase A: 화면/계정 생명주기)
public enum AnalyticsEvent: Equatable, Sendable {
    case screenView(ScreenName)
    case login(method: String, isNewUser: Bool)
    case logout
    case withdrawComplete(reasons: [String])
    // MARK: 탐색 퍼널
    case policyListView(listType: ListType, entryPoint: EntryPoint, category: String?)
    case policyDetailView(policyId: Int, policyName: String?, category: String?, entryPoint: EntryPoint)
    case applyClick(policyId: Int, applyURL: String, source: ApplySource)
    // MARK: 검색/필터
    case search(keyword: String, source: SearchSource)
    case sortApply(listType: ListType, sortOrder: String)
    case categoryFilter(listType: ListType, category: String)
    // MARK: 기능 채택
    case likeToggle(policyId: Int, liked: Bool, source: LikeSource)
    case calendarAdd(policyId: Int)
    case memoSave(policyId: Int, hasContent: Bool)
    case shareClick(policyId: Int)
    // MARK: 심화 인터랙션
    case customCardView(policyId: Int, position: Int)
    case aiSummaryView(policyId: Int)
    case aiSummaryGenerated(policyId: Int, available: Bool)
    case policyDetailScroll(policyId: Int, depth: Int)
    // MARK: 생명주기
    case onboardingStart
    case onboardingComplete
    case policyProfileEditSave(changed: Bool)
    case notificationClick(notificationId: Int, policyId: Int?)

    /// Amplitude 이벤트명(snake_case).
    public var name: String {
        switch self {
        case .screenView: return "screen_view"
        case .login: return "login"
        case .logout: return "logout"
        case .withdrawComplete: return "withdraw_complete"
        case .policyListView: return "policy_list_view"
        case .policyDetailView: return "policy_detail_view"
        case .applyClick: return "apply_click"
        case .search: return "search"
        case .sortApply: return "sort_apply"
        case .categoryFilter: return "category_filter"
        case .likeToggle: return "like_toggle"
        case .calendarAdd: return "calendar_add"
        case .memoSave: return "memo_save"
        case .shareClick: return "share_click"
        case .customCardView: return "custom_card_view"
        case .aiSummaryView: return "ai_summary_view"
        case .aiSummaryGenerated: return "ai_summary_generated"
        case .policyDetailScroll: return "policy_detail_scroll"
        case .onboardingStart: return "onboarding_start"
        case .onboardingComplete: return "onboarding_complete"
        case .policyProfileEditSave: return "policy_profile_edit_save"
        case .notificationClick: return "notification_click"
        }
    }

    /// Amplitude 이벤트 파라미터.
    public var properties: [String: Any] {
        switch self {
        case let .screenView(screen):
            return ["screen_name": screen.rawValue]
        case let .login(method, isNewUser):
            return ["method": method, "is_new_user": isNewUser]
        case .logout:
            return [:]
        case let .withdrawComplete(reasons):
            return ["reasons": reasons]
        case let .policyListView(listType, entryPoint, category):
            var props: [String: Any] = ["list_type": listType.rawValue, "entry_point": entryPoint.rawValue]
            if let category { props["category"] = category }
            return props
        case let .policyDetailView(policyId, policyName, category, entryPoint):
            var props: [String: Any] = ["policy_id": policyId, "entry_point": entryPoint.rawValue]
            if let policyName { props["policy_name"] = policyName }
            if let category { props["policy_category"] = category }
            return props
        case let .applyClick(policyId, applyURL, source):
            return ["policy_id": policyId, "apply_url": applyURL, "source": source.rawValue]
        case let .search(keyword, source):
            return ["keyword": keyword, "source": source.rawValue]
        case let .sortApply(listType, sortOrder):
            return ["list_type": listType.rawValue, "sort_order": sortOrder]
        case let .categoryFilter(listType, category):
            return ["list_type": listType.rawValue, "category": category]
        case let .likeToggle(policyId, liked, source):
            return ["policy_id": policyId, "liked": liked, "source": source.rawValue]
        case let .calendarAdd(policyId):
            return ["policy_id": policyId]
        case let .memoSave(policyId, hasContent):
            return ["policy_id": policyId, "has_content": hasContent]
        case let .shareClick(policyId):
            return ["policy_id": policyId]
        case let .customCardView(policyId, position):
            return ["policy_id": policyId, "position": position]
        case let .aiSummaryView(policyId):
            return ["policy_id": policyId]
        case let .aiSummaryGenerated(policyId, available):
            return ["policy_id": policyId, "available": available]
        case let .policyDetailScroll(policyId, depth):
            return ["policy_id": policyId, "depth": depth]
        case .onboardingStart, .onboardingComplete:
            return [:]
        case let .policyProfileEditSave(changed):
            return ["changed": changed]
        case let .notificationClick(notificationId, policyId):
            var props: [String: Any] = ["notification_id": notificationId]
            if let policyId { props["policy_id"] = policyId }
            return props
        }
    }
}

/// `screen_view`의 화면 식별자. (단계별로 추가)
public enum ScreenName: String, Sendable {
    case home
    case search
    case myPolicy = "my_policy"
    case profile
}

/// 정책 리스트 종류.
public enum ListType: String, Sendable {
    case category
    case rankedPopular = "ranked_popular"
    case rankedDeadline = "ranked_deadline"
    case rankedNew = "ranked_new"
    case custom
    case searchResult = "search_result"
    case myPolicy = "my_policy"
}

/// 리스트/상세 진입 경로.
public enum EntryPoint: String, Sendable {
    case homeCategory = "home_category"
    case homePersonalizedMore = "home_personalized_more"
    case homePopularMore = "home_popular_more"
    case homeDeadlineMore = "home_deadline_more"
    case homeNewMore = "home_new_more"
    case homeRecent = "home_recent"
    case homeEmptyCTA = "home_empty_cta"
    case search
    case myPolicy = "my_policy"
    case myPolicyMore = "my_policy_more"
    case myPolicyEmptyCTA = "my_policy_empty_cta"
    case calendar
    case categoryPersonalizedMore = "category_personalized_more"
    case recommendationPersonalized = "recommendation_personalized"
    case recommendationPopular = "recommendation_popular"
    /// 랭킹 리스트에서 상세 진입(세부 kind는 직전 policy_list_view에 기록됨).
    case ranked
    /// 상세 추천 카드에서 상세 진입(세부 섹션 미구분).
    case recommendation
    case deeplink
    case push
    case notification
}

/// 신청하기 발생 위치.
public enum ApplySource: String, Sendable {
    case detail
    case customCard = "custom_card"
}

/// 검색 실행 방식.
public enum SearchSource: String, Sendable {
    case submit
    case suggestion
}

/// 찜 토글 발생 화면.
public enum LikeSource: String, Sendable {
    case home
    case customList = "custom_list"
    case ranked
    case category
    case searchResult = "search_result"
    case myPolicyList = "my_policy_list"
    case detail
    case recommendation
}

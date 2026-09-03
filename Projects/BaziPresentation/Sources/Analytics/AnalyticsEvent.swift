// Copyright © 2026 ChungBazi. All rights reserved.

/// Amplitude로 전송할 타입드 분석 이벤트. `name`/`properties`로 매핑한다.
/// (단계별로 case를 추가한다 — Phase A: 화면/계정 생명주기)
public enum AnalyticsEvent: Equatable, Sendable {
    case screenView(ScreenName)
    case login(method: String, isNewUser: Bool)
    case logout
    case withdrawComplete(reasons: [String])
    // MARK: 탐색 퍼널 (Phase B)
    case policyListView(listType: ListType, entryPoint: EntryPoint, category: String?)
    case policyDetailView(policyId: Int, policyName: String?, category: String?, entryPoint: EntryPoint)
    case applyClick(policyId: Int, applyURL: String, source: ApplySource)

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

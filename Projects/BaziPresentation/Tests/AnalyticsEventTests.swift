// Copyright © 2026 ChungBazi. All rights reserved.

import Testing

@testable import BaziPresentation

struct AnalyticsEventTests {

    @Test("이벤트 이름 매핑")
    func eventNames() {
        #expect(AnalyticsEvent.screenView(.home).name == "screen_view")
        #expect(AnalyticsEvent.login(method: "kakao", isNewUser: true).name == "login")
        #expect(AnalyticsEvent.logout.name == "logout")
        #expect(AnalyticsEvent.withdrawComplete(reasons: []).name == "withdraw_complete")
    }

    @Test("screen_view 파라미터")
    func screenViewProperties() {
        #expect(AnalyticsEvent.screenView(.myPolicy).properties["screen_name"] as? String == "my_policy")
        #expect(AnalyticsEvent.screenView(.home).properties["screen_name"] as? String == "home")
    }

    @Test("login 파라미터")
    func loginProperties() {
        let props = AnalyticsEvent.login(method: "apple", isNewUser: false).properties
        #expect(props["method"] as? String == "apple")
        #expect(props["is_new_user"] as? Bool == false)
    }

    @Test("withdraw_complete 파라미터")
    func withdrawProperties() {
        let props = AnalyticsEvent.withdrawComplete(reasons: ["a", "b"]).properties
        #expect(props["reasons"] as? [String] == ["a", "b"])
    }

    @Test("퍼널 이벤트 이름")
    func funnelEventNames() {
        #expect(AnalyticsEvent.policyListView(listType: .category, entryPoint: .homeCategory, category: nil).name == "policy_list_view")
        #expect(AnalyticsEvent.policyDetailView(policyId: 1, policyName: nil, category: nil, entryPoint: .deeplink).name == "policy_detail_view")
        #expect(AnalyticsEvent.applyClick(policyId: 1, applyURL: "u", source: .detail).name == "apply_click")
    }

    @Test("policy_list_view 파라미터 — category nil이면 키 생략")
    func policyListViewProperties() {
        let props = AnalyticsEvent.policyListView(listType: .rankedPopular, entryPoint: .homePopularMore, category: nil).properties
        #expect(props["list_type"] as? String == "ranked_popular")
        #expect(props["entry_point"] as? String == "home_popular_more")
        #expect(props["category"] == nil)
        let withCat = AnalyticsEvent.policyListView(listType: .category, entryPoint: .homeCategory, category: "취업·창업").properties
        #expect(withCat["category"] as? String == "취업·창업")
    }

    @Test("policy_detail_view / apply_click 파라미터")
    func detailAndApplyProperties() {
        let detail = AnalyticsEvent.policyDetailView(policyId: 7, policyName: nil, category: nil, entryPoint: .search).properties
        #expect(detail["policy_id"] as? Int == 7)
        #expect(detail["entry_point"] as? String == "search")
        let apply = AnalyticsEvent.applyClick(policyId: 3, applyURL: "https://x", source: .customCard).properties
        #expect(apply["policy_id"] as? Int == 3)
        #expect(apply["apply_url"] as? String == "https://x")
        #expect(apply["source"] as? String == "custom_card")
    }
}

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
}

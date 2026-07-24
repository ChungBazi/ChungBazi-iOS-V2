// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

struct SharedRouteView: View {
    let route: SharedRoute

    var body: some View {
        switch route {
        case .policyDetail(let id):
            Text("정책 상세: \(id)") // TODO: PolicyDetailView 구현 후 교체
        case .customPolicyList:
            Text("맞춤정책 더보기")    // TODO
        case .policyRecommendationEdit:
            Text("추천기준 수정")    // TODO
        }
    }
}

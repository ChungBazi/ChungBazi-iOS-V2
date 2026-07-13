// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

struct ProfileTabView: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        @Bindable var coordinator = coordinator
        NavigationStack(path: $coordinator.profile.path) {
            Text("Profile") // TODO: ProfileView 구현 후 교체
                .navigationDestination(for: ProfileRoute.self) { buildProfileView(for: $0) }
                .navigationDestination(for: SharedRoute.self) { SharedRouteView(route: $0) }
        }
    }

    @ViewBuilder
    private func buildProfileView(for route: ProfileRoute) -> some View {
        switch route {
        case .wardrobe:                 Text("바로의 옷장")      // TODO
        case .nicknameEdit:             Text("닉네임 수정")      // TODO
        case .policyRecommendationEdit: Text("추천기준 수정")    // TODO
        case .notificationSettings:     Text("알림 설정")        // TODO
        case .appInfo:                  Text("앱 정보")          // TODO
        case .termsOfService:           Text("서비스 이용약관")  // TODO
        case .privacyPolicy:            Text("개인정보처리방침") // TODO
        case .withdrawal:               Text("탈퇴")             // TODO
        }
    }
}

// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

struct AuthCoordinatorView: View {
    let root: AuthRoot
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        @Bindable var coordinator = coordinator
        switch root {
        case .login:
            NavigationStack(path: $coordinator.authPath) {
                Text("Login") // TODO
                    .navigationDestination(for: OnboardingRoute.self) {
                        buildOnboardingView(for: $0)
                    }
            }
        case .nicknameSetup:
            Text("Nickname") // TODO
        case .onboarding:
            NavigationStack(path: $coordinator.authPath) {
                Text("Onboarding") // TODO
                    .navigationDestination(for: OnboardingRoute.self) {
                        buildOnboardingView(for: $0)
                    }
            }
        }
    }

    @ViewBuilder
    private func buildOnboardingView(for route: OnboardingRoute) -> some View {
        switch route {
        case .policyInterestSetup:
            Text("관심 정책 설정") // TODO
        case .onboardingComplete:
            Text("온보딩 완료") // TODO
                .navigationBarBackButtonHidden()
        }
    }
}

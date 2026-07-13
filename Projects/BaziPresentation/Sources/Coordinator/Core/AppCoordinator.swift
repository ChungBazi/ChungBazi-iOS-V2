// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

@MainActor
@Observable
public final class AppCoordinator {

    // MARK: - App Phase
    public var appPhase: AppPhase = .splash

    // MARK: - Auth Navigation
    public var authPath = NavigationPath()

    // MARK: - Main Tab
    public var selectedTab: MainTab = .home

    // MARK: - Tab Coordinators
    public var home = TabCoordinator()
    public var search = TabCoordinator()
    public var myPolicy = TabCoordinator()
    public var profile = TabCoordinator()

    // MARK: - Modal
    public var presentedSheet: ModalRoute? = nil
    public var presentedFullScreen: ModalRoute? = nil

    // MARK: - Calendar State (캘린더 sheet → 메모/정책 상세 → 재오픈용)
    public var calendarSelectedDate: Date? = nil

    public init() {}
}

// MARK: - Phase Transition
public extension AppCoordinator {
    func transition(to phase: AppPhase) {
        authPath = NavigationPath()
        home.popToRoot()
        search.popToRoot()
        myPolicy.popToRoot()
        profile.popToRoot()
        appPhase = phase
    }
}

// MARK: - Onboarding Navigation
public extension AppCoordinator {
    func push(_ route: OnboardingRoute) { authPath.append(route) }

    func popAuth() {
        guard !authPath.isEmpty else { return }
        authPath.removeLast()
    }
}

// MARK: - Modal
public extension AppCoordinator {
    func presentModal(_ route: ModalRoute) {
        switch route.presentationStyle {
        case .sheet:
            presentedFullScreen = nil
            presentedSheet = route
        case .fullScreen:
            presentedSheet = nil
            presentedFullScreen = route
        }
    }

    func dismissModal() {
        presentedSheet = nil
        presentedFullScreen = nil
    }
}

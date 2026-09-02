// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

public enum BaziImage {
    case appLogo
    case imagePlaceholder

    // MARK: Character
    case basicBaro
    case glassBaro
    case emptyBaro

    // MARK: Card
    case activityCard
    case growthCard
    case housingCard
    case jobCard
    case lifesupportCard

    // MARK: Background
    case loginBackground
    case startOnboardingBackground
    case endOnboardingBackground

    // MARK: Icon
    case bellIcon
    case calendarIcon
    case addCalendarIcon
    case checkIcon
    case eyeIcon
    case historyIcon
    case kakaoIcon
    case appleLogo
    case memoIcon
    case searchIcon
    case shareIcon
    case trashIcon

    // MARK: Icon - Dim
    case dimSimpleIcon
    case dimSwipeIcon

    // MARK: Icon - Checkbox
    case filledCheckbox
    case unfilledCheckbox

    // MARK: Icon - Star
    case filledStar
    case unfilledStar

    // MARK: Icon - Alarm
    case baziAlarmIcon
    case policyAlarmIcon

    // MARK: Icon - PolicyField
    case activityIcon
    case dwellingIcon
    case jobIcon
    case livingSupportIcon
    case studyIcon

    // MARK: Icon - TabMenu
    case homeSelectIcon
    case homeUnselectIcon
    case mypolicySelectIcon
    case mypolicyUnselectIcon
    case searchSelectIcon
    case searchUnselectIcon
    case profileSelectIcon
    case profileUnselectIcon

    public var image: Image {
        switch self {
        case .appLogo: return BaziDesignAsset.appLogo.swiftUIImage
        case .imagePlaceholder: return BaziDesignAsset.imagePlaceholder.swiftUIImage

        case .basicBaro: return BaziDesignAsset.basicBaro.swiftUIImage
        case .glassBaro: return BaziDesignAsset.glassBaro.swiftUIImage
        case .emptyBaro: return BaziDesignAsset.emptyBaro.swiftUIImage

        case .activityCard: return BaziDesignAsset.activityCard.swiftUIImage
        case .growthCard: return BaziDesignAsset.growthCard.swiftUIImage
        case .housingCard: return BaziDesignAsset.housingCard.swiftUIImage
        case .jobCard: return BaziDesignAsset.jobCard.swiftUIImage
        case .lifesupportCard: return BaziDesignAsset.lifesupportCard.swiftUIImage

        case .loginBackground: return BaziDesignAsset.loginBackground.swiftUIImage
        case .startOnboardingBackground: return BaziDesignAsset.startOnboardingBackground.swiftUIImage
        case .endOnboardingBackground: return BaziDesignAsset.endOnboardingBackground.swiftUIImage

        case .bellIcon: return BaziDesignAsset.bellIcon.swiftUIImage
        case .calendarIcon: return BaziDesignAsset.calendarIcon.swiftUIImage
        case .addCalendarIcon: return BaziDesignAsset.addCalendarIcon.swiftUIImage
        case .checkIcon: return BaziDesignAsset.checkIcon.swiftUIImage
        case .eyeIcon: return BaziDesignAsset.eyeIcon.swiftUIImage
        case .historyIcon: return BaziDesignAsset.historyIcon.swiftUIImage
        case .kakaoIcon: return BaziDesignAsset.kakaoIcon.swiftUIImage
        case .appleLogo: return BaziDesignAsset.appleLogo.swiftUIImage
        case .memoIcon: return BaziDesignAsset.memoIcon.swiftUIImage
        case .searchIcon: return BaziDesignAsset.searchIcon.swiftUIImage
        case .shareIcon: return BaziDesignAsset.shareIcon.swiftUIImage
        case .trashIcon: return BaziDesignAsset.trashIcon.swiftUIImage

        case .dimSimpleIcon: return BaziDesignAsset.dimSimpleIcon.swiftUIImage
        case .dimSwipeIcon: return BaziDesignAsset.dimSwipeIcon.swiftUIImage

        case .filledCheckbox: return BaziDesignAsset.filledCheckbox.swiftUIImage
        case .unfilledCheckbox: return BaziDesignAsset.unfilledCheckbox.swiftUIImage

        case .filledStar: return BaziDesignAsset.filledStar.swiftUIImage
        case .unfilledStar: return BaziDesignAsset.unfilledStar.swiftUIImage

        case .baziAlarmIcon: return BaziDesignAsset.baziAlarmIcon.swiftUIImage
        case .policyAlarmIcon: return BaziDesignAsset.policyAlarmIcon.swiftUIImage

        case .activityIcon: return BaziDesignAsset.activityIcon.swiftUIImage
        case .dwellingIcon: return BaziDesignAsset.dwellingIcon.swiftUIImage
        case .jobIcon: return BaziDesignAsset.jobIcon.swiftUIImage
        case .livingSupportIcon: return BaziDesignAsset.livingSupportIcon.swiftUIImage
        case .studyIcon: return BaziDesignAsset.studyIcon.swiftUIImage

        case .homeSelectIcon: return BaziDesignAsset.homeSelectIcon.swiftUIImage
        case .homeUnselectIcon: return BaziDesignAsset.homeUnselectIcon.swiftUIImage
        case .mypolicySelectIcon: return BaziDesignAsset.mypolicySelectIcon.swiftUIImage
        case .mypolicyUnselectIcon: return BaziDesignAsset.mypolicyUnselectIcon.swiftUIImage
        case .searchSelectIcon: return BaziDesignAsset.searchSelectIcon.swiftUIImage
        case .searchUnselectIcon: return BaziDesignAsset.searchUnselectIcon.swiftUIImage
        case .profileSelectIcon: return BaziDesignAsset.profileSelectIcon.swiftUIImage
        case .profileUnselectIcon: return BaziDesignAsset.profileUnselectIcon.swiftUIImage
        }
    }
}

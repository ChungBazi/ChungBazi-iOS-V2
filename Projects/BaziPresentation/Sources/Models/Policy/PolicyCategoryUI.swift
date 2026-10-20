// Copyright © 2026 ChungBazi. All rights reserved.

import UIKit

import BaziDesign
import BaziDomain

/// 정책 분야. 홈 "분야별 정책" 아이콘 목록과 분야 필터에서 공유한다.
public enum PolicyCategoryUI: String, CaseIterable, Equatable, Identifiable, Sendable {
    case job = "취업·창업"
    case dwelling = "월세·주거"
    case study = "공부·성장"
    case livingSupport = "생활지원"
    case activity = "활동·경험"

    public var id: String { rawValue }

    public var icon: BaziImage {
        switch self {
        case .job: return .jobIcon
        case .dwelling: return .dwellingIcon
        case .study: return .studyIcon
        case .livingSupport: return .livingSupportIcon
        case .activity: return .activityIcon
        }
    }

    /// Large, Flip 카드 썸네일용 분야별 이미지.
    public var cardImage: BaziImage {
        switch self {
        case .job: return .jobCard
        case .dwelling: return .housingCard
        case .study: return .growthCard
        case .livingSupport: return .lifesupportCard
        case .activity: return .activityCard
        }
    }
}

// MARK: - Mapping

extension PolicyCategoryUI {

    /// 서버 카테고리 코드(Domain enum)를 화면용 카테고리(UI enum)로 1:1 변환한다.
    init(domain: BaziDomain.PolicyCategory) {
        switch domain {
        case .jobStartup:  self = .job
        case .housing:     self = .dwelling
        case .growth:      self = .study
        case .lifeSupport: self = .livingSupport
        case .activity:    self = .activity
        }
    }

    /// UI 카테고리 → 서버 카테고리 코드(요청 파라미터용).
    public func toDomain() -> BaziDomain.PolicyCategory {
        switch self {
        case .job:           return .jobStartup
        case .dwelling:      return .housing
        case .study:         return .growth
        case .livingSupport: return .lifeSupport
        case .activity:      return .activity
        }
    }
}

// MARK: - Kakao Share Thumbnail

extension PolicyCategoryUI {

    /// 카카오 공유 썸네일. 카테고리 카드 이미지를 JPEG로 인코딩하고, rawValue를 업로드 URL 캐시 키로 쓴다.
    var shareThumbnail: ShareThumbnail? {
        guard let data = cardUIImage.jpegData(compressionQuality: 0.8) else { return nil }
        return ShareThumbnail(cacheKey: rawValue, imageData: data)
    }

    private var cardUIImage: UIImage {
        switch self {
        case .job:           return BaziDesignAsset.jobCard.image
        case .dwelling:      return BaziDesignAsset.housingCard.image
        case .study:         return BaziDesignAsset.growthCard.image
        case .livingSupport: return BaziDesignAsset.lifesupportCard.image
        case .activity:      return BaziDesignAsset.activityCard.image
        }
    }
}

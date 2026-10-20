// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 세션과 무관하게 앱 삭제 전까지 유지되는 로컬 설정(가이드/코치마크 노출 여부 등)을 관리한다.
public protocol AppPreferenceRepository: Sendable {
    var hasSeenCustomPolicyGuide: Bool { get }
    func markCustomPolicyGuideSeen()
}

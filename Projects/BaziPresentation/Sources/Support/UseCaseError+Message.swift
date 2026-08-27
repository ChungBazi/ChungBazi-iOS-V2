// Copyright © 2026 ChungBazi. All rights reserved.

import BaziDomain

extension UseCaseError {

    /// 로드 실패 상태(`LoadingState.failed`)에 담는 기본 메시지.
    var loadFailureMessage: String {
        switch self {
        case .network:
            return "네트워크 연결을 확인해 주세요."
        case .cancelled, .unknown:
            return "정책을 불러오지 못했어요. 잠시 후 다시 시도해 주세요."
        }
    }
}

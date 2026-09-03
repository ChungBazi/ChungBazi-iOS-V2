// Copyright © 2026 ChungBazi. All rights reserved.

import BaziDomain

extension UseCaseError {

    /// 로드/동작 실패를 사용자에게 보여줄 메시지.
    var loadFailureMessage: String {
        switch self {
        case .offline:
            return "네트워크 연결을 확인해 주세요"
        case .timeout:
            return "요청 시간이 초과됐어요. 잠시 후 다시 시도해 주세요"
        case .unauthorized:
            return "로그인이 만료됐어요. 다시 로그인해 주세요"
        case .server(_, let message):
            // 서버가 내려준 사용자용 메시지를 그대로 노출한다.
            return message
        case .message(let text):
            return text
        case .cancelled, .unknown:
            return "요청을 처리하지 못했어요. 잠시 후 다시 시도해 주세요"
        }
    }
}

// Copyright © 2026 ChungBazi. All rights reserved.

import BaziDomain

/// 지역(시도/시군구) 선택 화면용 VO. 표시는 `name`, 서버 전송은 `code`.
public struct RegionVO: Equatable, Identifiable, Sendable {
    public let name: String
    public let code: String

    public var id: String { code }

    public init(_ region: RegionInfo) {
        self.name = region.name
        self.code = region.code
    }
}

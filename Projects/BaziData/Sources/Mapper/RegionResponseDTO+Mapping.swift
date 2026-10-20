// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziDomain
import BaziNetwork

extension SidoResponseDTO {
    func toDomain() -> RegionInfo {
        RegionInfo(code: sidoCode, name: sidoName)
    }
}

extension SigunguResponseDTO {
    func toDomain() -> RegionInfo {
        RegionInfo(code: sigunguCode, name: sigunguName)
    }
}

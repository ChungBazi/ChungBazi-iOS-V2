// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziDomain
import BaziNetwork

extension SidoResponseDTO {
    func toDomain() -> RegionEntity {
        RegionEntity(code: sidoCode, name: sidoName)
    }
}

extension SigunguResponseDTO {
    func toDomain() -> RegionEntity {
        RegionEntity(code: sigunguCode, name: sigunguName)
    }
}

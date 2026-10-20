// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct SidoResponseDTO: Decodable, Sendable {
    public let sidoCode: String
    public let sidoName: String
}

public struct SigunguResponseDTO: Decodable, Sendable {
    public let sigunguCode: String
    public let sigunguName: String
}

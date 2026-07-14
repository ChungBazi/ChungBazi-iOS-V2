// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct SidoResponseDTO: Decodable {
    public let sidoCode: String
    public let sidoName: String
    
    init(sidoCode: String, sidoName: String) {
        self.sidoCode = sidoCode
        self.sidoName = sidoName
    }
}

public struct SigunguResponseDTO: Decodable {
    public let sigunguCode: String
    public let sigunguName: String
    
    init(sigunguCode: String, sigunguName: String) {
        self.sigunguCode = sigunguCode
        self.sigunguName = sigunguName
    }
}

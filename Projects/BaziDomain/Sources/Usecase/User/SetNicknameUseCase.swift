// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public protocol SetNicknameUseCase: Sendable {
    func execute(name: String) async throws
}

// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

@DependencyClient
public struct NicknameClient: Sendable {
    public var setNickname: @Sendable (_ name: String) async throws -> Void
}

extension NicknameClient: TestDependencyKey {
    public static let testValue = NicknameClient()

    public static let previewValue = NicknameClient(setNickname: { _ in })
}

extension DependencyValues {
    public var nicknameClient: NicknameClient {
        get { self[NicknameClient.self] }
        set { self[NicknameClient.self] = newValue }
    }
}

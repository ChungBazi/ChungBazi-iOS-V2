// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 로컬 세션에 저장된 사용자 닉네임의 읽기/쓰기를 담당한다.
/// 서버가 준 닉네임(온보딩/홈 응답)을 저장하고, 화면에서 읽어 쓴다. 로그아웃/탈퇴 시 reset으로 정리된다.
public protocol UserNameUseCase: Sendable {
    func get() -> String?
    func save(_ name: String)
}

// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

/// 정책 찜 토글의 최근 상태(정책 id → liked)를 앱 전역에서 공유하는 인메모리 오버레이.
///
/// 서버가 준 `isLiked` 위에 한 겹 덮어, 상세/리스트 등 어디서 토글하든 홈·내정책이 즉시 반영하도록 한다.
/// (홈: 하트 표시를 `likeOverrides[id] ?? isLiked`로 / 내정책: `likeOverrides[id] == false`인 항목은 목록에서 제외)
/// 세션 동안만 유지(`.inMemory`)되고 앱 재시작 시 초기화된다.
extension SharedKey where Self == InMemoryKey<[Int: Bool]> {
    public static var likeOverrides: Self { .inMemory("likeOverrides") }
}

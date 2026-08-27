// Copyright © 2026 ChungBazi. All rights reserved.

/// "아직 로드되지 않음"과 "로드했지만 비어 있음"을 구분하기 위한 상태.
/// 화면이 로딩 스피너 / 빈 상태 / 결과 / 에러 네 가지 모습을 모두 가져야 할 때 사용한다.
public enum LoadingState<Value: Equatable>: Equatable {
    case idle
    case loading
    case loaded(Value)
    case failed(String)
}

extension LoadingState {

    /// 성공 상태의 값(그 외 상태에선 nil). 낙관적 갱신처럼 loaded 값을 읽거나 치환할 때 쓴다.
    public var value: Value? {
        get {
            guard case let .loaded(value) = self else { return nil }
            return value
        }
        set {
            guard let newValue else { return }
            self = .loaded(newValue)
        }
    }

    public var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
}

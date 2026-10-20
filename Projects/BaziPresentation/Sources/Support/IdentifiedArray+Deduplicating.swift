// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

extension IdentifiedArray where ID == Element.ID, Element: Identifiable {

    /// 서버가 중복 id를 내려줄 수 있는 목록을 매핑할 때 사용한다.
    /// `init(uniqueElements:)`는 중복 id 시 release 빌드에서도 precondition으로 trap(크래시)하므로,
    /// 중복은 먼저 온 요소를 유지하고 이후 항목을 무시한다.
    init<S: Sequence>(deduplicating elements: S) where S.Element == Element {
        self.init(elements, uniquingIDsWith: { first, _ in first })
    }
}

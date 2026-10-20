// Copyright © 2026 ChungBazi. All rights reserved.

import Testing

@testable import BaziCore

struct SemanticVersionTests {

    @Test("이전 버전이 더 작다")
    func compareOlderIsLess() {
        #expect(SemanticVersion("2.0.0")! < SemanticVersion("2.1.0")!)
        #expect(SemanticVersion("2.0.0")! < SemanticVersion("2.0.1")!)
        #expect(SemanticVersion("1.9.9")! < SemanticVersion("2.0.0")!)
    }

    @Test("같은 버전은 서로 작지 않다")
    func equalNotLess() {
        #expect(!(SemanticVersion("2.0.0")! < SemanticVersion("2.0.0")!))
    }

    @Test("자릿수가 다르면 0으로 패딩해 비교한다")
    func differentLengthPadsWithZero() {
        #expect(!(SemanticVersion("2.0")! < SemanticVersion("2.0.0")!))
        #expect(SemanticVersion("2.0")! < SemanticVersion("2.0.1")!)
    }

    @Test("형식이 잘못되면 nil을 반환한다")
    func invalidReturnsNil() {
        #expect(SemanticVersion("abc") == nil)
        #expect(SemanticVersion("") == nil)
        #expect(SemanticVersion("2.x.0") == nil)
    }
}

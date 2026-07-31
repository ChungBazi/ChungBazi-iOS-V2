// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public extension String {

    /// SwiftUI `Text`는 줄바꿈 단위를 직접 제어하는 API가 없어서 기본적으로 띄어쓰기(단어) 단위로만 줄바꿈된다.
    /// 각 글자 사이에 폭이 없는 공백(zero width space)을 끼워 넣어 모든 글자 위치를 줄바꿈 가능 지점으로 만든다.
    var byCharWrapping: String {
        map(String.init).joined(separator: "\u{200B}")
    }
}

// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

extension View {

    /// 로딩 중일 때 화면 전체를 덮는 스피너를 얹고 터치를 차단한다.
    /// - Parameters:
    ///   - isLoading: true면 스피너를 표시한다.
    ///   - dimmed: true면 뒤에 딤(Black 45%)을 깐다. false면 딤 없이 스피너만 얹는다(투명 터치 차단).
    public func baziLoading(_ isLoading: Bool, dimmed: Bool = true) -> some View {
        overlay {
            if isLoading {
                ZStack {
                    if dimmed {
                        BZDimOverlay(level: .dim1)
                    } else {
                        Color.clear
                            .ignoresSafeArea()
                            .contentShape(Rectangle())
                    }
                    BZLoadingView()
                }
            }
        }
    }
}

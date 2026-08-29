// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import BaziDesign

/// 서비스 이용약관·개인정보 처리방침처럼 "제목 + 긴 정적 텍스트"만 보여주는 화면의 공용 뷰.
struct StaticTextDocumentView: View {

    let title: String
    let text: String
    var onAppear: () -> Void = {}
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                Text(text)
                    .baziFont(.small14R)
                    .foregroundStyle(Color.gray800)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
            }
            .hiddenTabBarSafeBottom()
        }
        .baziBackground(.bgWhite)
        .task { onAppear() }
        .baziNavigationBar_backWithTitle(title) {
            onBack()
        }
    }
}

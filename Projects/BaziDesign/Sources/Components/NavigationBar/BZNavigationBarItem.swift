// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

/// 각 타입을 구성하는 leading/center/trailing 아이템.
public enum BZNavigationBarItem {
    case back(action: () -> Void)
    case title(String)
    case textButton(String, action: () -> Void)
    case share(action: () -> Void)
    case bell(action: () -> Void)
    case logo
}

/// `BZNavigationBarItem`을 실제 뷰로 그려주는 빌더.
@MainActor
enum BZNavigationBarItemBuilder {

    @ViewBuilder
    static func buildView(for item: BZNavigationBarItem) -> some View {
        switch item {
        case .back(let action):
            Button(action: action) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
            }
            .tint(Color.gray900)
            .accessibilityLabel("뒤로가기")

        case .title(let text):
            Text(text)
                .baziFont(.body16SB)
                .foregroundStyle(Color.gray900)

        case .textButton(let text, let action):
            Button(action: action) {
                Text(text)
                    .baziFont(.small14R)
                    .foregroundStyle(Color.gray700)
            }

        case .share(let action):
            Button(action: action) {
                Image.bazi(.shareIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24)
            }
            .tint(Color.gray900)
            .accessibilityLabel("공유")

        case .bell(let action):
            Button(action: action) {
                Image.bazi(.bellIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24)
            }
            .tint(Color.gray900)
            .accessibilityLabel("알림")

        case .logo:
            Image.bazi(.appLogo)
                .resizable()
                .scaledToFit()
                .frame(width: 61.5)
                .foregroundStyle(Color.bazi(.primary))
        }
    }
}

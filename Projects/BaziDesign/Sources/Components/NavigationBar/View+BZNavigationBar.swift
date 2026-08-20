// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

public extension View {

    /// 기본 nav bar를 숨기고 leading/center/trailing에 `BZNavigationBarItem`을 배치한다.
    func baziNavigationBar(
        leading: BZNavigationBarItem? = nil,
        center: BZNavigationBarItem? = nil,
        trailing: BZNavigationBarItem? = nil
    ) -> some View {
        self
            .navigationBarBackButtonHidden(true)
            .toolbarBackground(Color.bazi(.bgWhite), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                if let leading {
                    ToolbarItem(placement: .topBarLeading) {
                        BZNavigationBarItemBuilder.buildView(for: leading)
                    }
                }
                if let center {
                    ToolbarItem(placement: .principal) {
                        BZNavigationBarItemBuilder.buildView(for: center)
                    }
                }
                if let trailing {
                    ToolbarItem(placement: .topBarTrailing) {
                        BZNavigationBarItemBuilder.buildView(for: trailing)
                    }
                }
            }
    }

    /// Type=1 — 뒤로가기 + 중앙 타이틀
    func baziNavigationBar_backWithTitle(
        _ title: String,
        onBack: @escaping () -> Void
    ) -> some View {
        baziNavigationBar(
            leading: .back(action: onBack),
            center: .title(title)
        )
        .navigationBarTitleDisplayMode(.inline)
    }

    /// Type=2 — 로고(좌) + 알림벨(우), 탭 루트용. `hasUnread`면 벨에 읽지 않음 배지를 표시한다.
    func baziNavigationBar_home(
        hasUnread: Bool = false,
        onBellTap: @escaping () -> Void
    ) -> some View {
        baziNavigationBar(
            leading: .logo,
            trailing: .bell(hasUnread: hasUnread, action: onBellTap)
        )
    }

    /// Type=3 — 뒤로가기 + 공유
    func baziNavigationBar_backWithShare(
        onBack: @escaping () -> Void,
        onShare: @escaping () -> Void
    ) -> some View {
        baziNavigationBar(
            leading: .back(action: onBack),
            trailing: .share(action: onShare)
        )
    }

    /// Type=4 — 뒤로가기 + 중앙 타이틀 + 텍스트 버튼(예: 전체 삭제)
    func baziNavigationBar_backWithTitleAndTextButton(
        _ title: String,
        buttonTitle: String,
        onBack: @escaping () -> Void,
        onButtonTap: @escaping () -> Void
    ) -> some View {
        baziNavigationBar(
            leading: .back(action: onBack),
            center: .title(title),
            trailing: .textButton(buttonTitle, action: onButtonTap)
        )
        .navigationBarTitleDisplayMode(.inline)
    }

    /// Type=5 — 뒤로가기 + 중앙 타이틀 + 저장 버튼(활성 상태에 따라 색이 바뀜, 예: 메모 화면)
    func baziNavigationBar_backWithTitleAndSaveButton(
        _ title: String,
        saveButtonTitle: String = "저장",
        isSaveEnabled: Bool,
        onBack: @escaping () -> Void,
        onSave: @escaping () -> Void
    ) -> some View {
        baziNavigationBar(
            leading: .back(action: onBack),
            center: .title(title),
            trailing: .saveButton(saveButtonTitle, isEnabled: isSaveEnabled, action: onSave)
        )
        .navigationBarTitleDisplayMode(.inline)
    }
}

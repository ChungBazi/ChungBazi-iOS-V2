// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 앱 번들에서 읽는 정적 앱 정보.
public enum AppInfo {

    /// 마케팅 버전 (`CFBundleShortVersionString`). 없으면 "-".
    public static var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
    }
}

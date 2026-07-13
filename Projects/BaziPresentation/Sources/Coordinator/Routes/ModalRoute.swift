// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public enum PresentationStyle {
    case sheet
    case fullScreen
}

public enum ModalRoute: Identifiable {
    case webView(url: URL)
    case calendarPolicyList(date: Date)

    public var id: String {
        switch self {
        case .webView(let url):
            return url.absoluteString
        case .calendarPolicyList(let date):
            return "calendar-\(date.timeIntervalSince1970)"
        }
    }

    public var presentationStyle: PresentationStyle {
        switch self {
        case .webView, .calendarPolicyList: return .sheet
        }
    }
}

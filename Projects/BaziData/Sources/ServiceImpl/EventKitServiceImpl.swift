// Copyright © 2026 ChungBazi. All rights reserved.

import EventKit
import Foundation

import BaziDomain

public struct EventKitServiceImpl: EventKitService {

    public init() {}

    public func addEvent(title: String, date: Date, url: URL?) async throws {
        // EKEventStore는 Sendable이 아니라 저장하지 않고 호출마다 생성한다.
        // 시스템 권한은 앱 단위라 재요청해도 이미 허용됐으면 즉시 허용으로 돌아온다.
        let eventStore = EKEventStore()

        let granted = (try? await eventStore.requestWriteOnlyAccessToEvents()) ?? false
        guard granted else { throw EventKitError.accessDenied }

        // write-only 권한/기본 캘린더 미설정 시 nil일 수 있다. nil이면 저장이 불가하므로 명시적으로 실패 처리한다.
        guard let defaultCalendar = eventStore.defaultCalendarForNewEvents else {
            throw EventKitError.saveFailed
        }

        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.isAllDay = true
        event.startDate = date
        event.endDate = date
        // 정책 상세 딥링크. iOS 캘린더 앱에서 이벤트의 URL 필드로 노출돼 탭하면 앱으로 열린다.
        event.url = url
        event.calendar = defaultCalendar
        event.addAlarm(EKAlarm(relativeOffset: -60 * 60 * 24)) // 하루 전 알림

        do {
            try eventStore.save(event, span: .thisEvent)
        } catch {
            throw EventKitError.saveFailed
        }
    }
}

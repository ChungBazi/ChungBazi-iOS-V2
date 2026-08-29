// Copyright © 2026 ChungBazi. All rights reserved.

import EventKit
import Foundation

import BaziDomain

public struct EventKitServiceImpl: EventKitService {

    public init() {}

    public func addEvent(title: String, date: Date, notes: String?) async throws {
        // EKEventStore는 Sendable이 아니라 저장하지 않고 호출마다 생성한다.
        // 시스템 권한은 앱 단위라 재요청해도 이미 허용됐으면 즉시 허용으로 돌아온다.
        let eventStore = EKEventStore()

        let granted = (try? await eventStore.requestWriteOnlyAccessToEvents()) ?? false
        guard granted else { throw EventKitError.accessDenied }

        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.isAllDay = true
        event.startDate = date
        event.endDate = date
        event.notes = notes
        event.calendar = eventStore.defaultCalendarForNewEvents
        event.addAlarm(EKAlarm(relativeOffset: -60 * 60 * 24)) // 하루 전 알림

        do {
            try eventStore.save(event, span: .thisEvent)
        } catch {
            throw EventKitError.saveFailed
        }
    }
}

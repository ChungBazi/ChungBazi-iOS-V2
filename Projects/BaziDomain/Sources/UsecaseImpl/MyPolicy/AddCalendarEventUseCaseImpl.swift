// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct AddCalendarEventUseCaseImpl: AddCalendarEventUseCase {

    private let eventKitService: EventKitService

    public init(eventKitService: EventKitService) {
        self.eventKitService = eventKitService
    }

    public func execute(title: String, date: Date, notes: String?) async throws {
        try await eventKitService.addEvent(title: title, date: date, notes: notes)
    }
}

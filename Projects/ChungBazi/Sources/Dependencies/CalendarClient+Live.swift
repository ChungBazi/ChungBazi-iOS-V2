// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziData
import BaziDomain
import BaziPresentation

extension CalendarClient: @retroactive DependencyKey {

    public static let liveValue: CalendarClient = {
        let repository: any MyPolicyRepository = MyPolicyRepositoryImpl(
            networkProvider: AppDependencies.networkProvider
        )
        let fetchCalendarUseCase: any FetchCalendarUseCase = FetchCalendarUseCaseImpl(myPolicyRepository: repository)
        let fetchDeadlineDateUseCase: any FetchDeadlineDatePoliciesUseCase = FetchDeadlineDatePoliciesUseCaseImpl(myPolicyRepository: repository)
        let addCalendarEventUseCase: any AddCalendarEventUseCase = AddCalendarEventUseCaseImpl(eventKitService: EventKitServiceImpl())

        return CalendarClient(
            fetchCalendar: { targetMonth in
                try await fetchCalendarUseCase.execute(targetMonth: targetMonth)
            },
            fetchDeadlineDate: { targetDate, sort, cursor, size in
                let page = try await fetchDeadlineDateUseCase.execute(targetDate: targetDate, sort: sort, cursor: cursor, size: size)
                return PolicyPageVO(page)
            },
            // notes(딥링크)는 앱 커스텀 URL 스킴이 없어 v1에서는 nil. 스킴 추가 시 딥링크 문자열 전달 예정.
            addDeadline: { title, date in
                try await addCalendarEventUseCase.execute(title: title, date: date, notes: nil)
            }
        )
    }()
}

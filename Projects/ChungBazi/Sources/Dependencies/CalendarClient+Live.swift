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
            // 이벤트 URL에 정책 상세 딥링크(chungbazi://policy/{id})를 심는다. 탭하면 앱이 열려 상세로 이동.
            addDeadline: { policyId, title, date in
                try await addCalendarEventUseCase.execute(
                    title: title,
                    date: date,
                    url: PolicyDeeplink.url(policyId: policyId)
                )
            }
        )
    }()
}

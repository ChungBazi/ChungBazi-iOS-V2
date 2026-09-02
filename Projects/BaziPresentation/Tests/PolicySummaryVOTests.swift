// Copyright © 2026 ChungBazi. All rights reserved.

import Testing

@testable import BaziPresentation

struct PolicySummaryVOTests {

    private func policy(_ registeredDate: String?, id: Int = 1) -> PolicySummaryVO {
        PolicySummaryVO(
            id: id,
            category: .job,
            dDay: "D-1",
            title: "정책",
            viewCount: 0,
            registeredDate: registeredDate
        )
    }

    @Test("빈 목록이면 nil")
    func emptyList_returnsNil() {
        #expect(PolicySummaryVO.latestUpdatedText([]) == nil)
    }

    @Test("등록일이 모두 nil이면 nil")
    func allNil_returnsNil() {
        #expect(PolicySummaryVO.latestUpdatedText([policy(nil, id: 1), policy(nil, id: 2)]) == nil)
    }

    @Test("빈 문자열은 무시되어 nil")
    func emptyString_returnsNil() {
        #expect(PolicySummaryVO.latestUpdatedText([policy("")]) == nil)
    }

    @Test("yyyy-MM-dd를 '업데이트' 문구로 변환한다")
    func validDate_formats() {
        #expect(PolicySummaryVO.latestUpdatedText([policy("2026-08-31")]) == "2026년 08월 31일 업데이트")
    }

    @Test("datetime이어도 날짜 부분(앞 10자)만 사용한다")
    func datetime_usesDatePart() {
        #expect(PolicySummaryVO.latestUpdatedText([policy("2026-08-31T12:34:56")]) == "2026년 08월 31일 업데이트")
    }

    @Test("여러 등록일 중 가장 최신을 사용한다")
    func multipleDates_usesLatest() {
        let list = [policy("2026-01-15", id: 1), policy("2026-08-31", id: 2), policy("2026-08-30", id: 3)]
        #expect(PolicySummaryVO.latestUpdatedText(list) == "2026년 08월 31일 업데이트")
    }

    @Test("유효/무효가 섞이면 유효한 값 중 최신을 사용한다")
    func mixedValidInvalid_usesLatestValid() {
        let list = [
            policy("not-a-date", id: 1),
            policy("2026-03-05", id: 2),
            policy(nil, id: 3),
            policy("2026-02-01", id: 4),
        ]
        #expect(PolicySummaryVO.latestUpdatedText(list) == "2026년 03월 05일 업데이트")
    }

    @Test("모든 값이 잘못된 형식이면 nil (형식 변경 시 배너가 조용히 사라지는 회귀 방지)")
    func allInvalid_returnsNil() {
        let list = [policy("not-a-date", id: 1), policy("invalid", id: 2), policy("----------", id: 3)]
        #expect(PolicySummaryVO.latestUpdatedText(list) == nil)
    }
}

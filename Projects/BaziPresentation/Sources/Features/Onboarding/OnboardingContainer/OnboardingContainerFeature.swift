// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import ComposableArchitecture

/// 온보딩의 "진행 중" 6단계(생년월일~관심분야)를 하나의 컨테이너로 관리한다.
/// 진행바/하단 버튼이 화면 전환 없이 유지되어야 해서 각 단계를 별도 push 화면이 아닌
/// `currentStep` 전환으로 다룬다.
@Reducer
public struct OnboardingContainerFeature {

    // MARK: - Step

    public enum Step: Int, CaseIterable, Equatable {
        case birthDate = 1
        case region
        case education
        case employment
        case income
        case interest

        var previous: Step? { Step(rawValue: rawValue - 1) }
        var next: Step? { Step(rawValue: rawValue + 1) }
    }

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var currentStep: Step = .birthDate

        // MARK: BirthDate
        public var year = 2000
        public var month = 1
        public var day = 1
        public var hasChangedYear = false
        public var hasChangedMonth = false
        public var hasChangedDay = false

        // MARK: Region
        public var province: String?
        public var district: String?

        // MARK: Education
        public var education: String?

        // MARK: Employment
        public var employment: String?

        // MARK: Income
        public var income: String?

        // MARK: Interest
        public var selectedCategories: Set<String> = []

        public init() {}

        /// 선택된 연/월 기준 실제 일수(윤년 2월 포함).
        public var daysInSelectedMonth: Int {
            var components = DateComponents()
            components.year = year
            components.month = month
            let calendar = Calendar(identifier: .gregorian)
            guard let date = calendar.date(from: components),
                  let range = calendar.range(of: .day, in: .month, for: date) else {
                return 31
            }
            return range.count
        }

        var isCurrentStepValid: Bool {
            switch currentStep {
            case .birthDate: return hasChangedYear && hasChangedMonth && hasChangedDay
            case .region: return province != nil && district != nil
            case .education: return education != nil
            case .employment: return employment != nil
            case .income: return income != nil
            case .interest: return selectedCategories.count >= OnboardingContainerFeature.minimumInterestCount
            }
        }
    }

    // MARK: - Action

    public enum Action: BindableAction {
        // MARK: View
        case binding(BindingAction<State>)
        case didTapCategory(String)
        case didTapPreviousButton
        case didTapNextButton

        // MARK: Delegate
        case delegate(Delegate)
    }

    // MARK: - Delegate

    public enum Delegate: Equatable {
        case didTapPrevious
        case didCompleteAllSteps
    }

    // MARK: - Init

    public init() {}

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.province):
                state.district = nil
                return .none

            case .binding(\.year):
                state.hasChangedYear = true
                state.day = min(state.day, state.daysInSelectedMonth)
                return .none

            case .binding(\.month):
                state.hasChangedMonth = true
                state.day = min(state.day, state.daysInSelectedMonth)
                return .none

            case .binding(\.day):
                state.hasChangedDay = true
                return .none

            case .binding:
                return .none

            case .didTapCategory(let category):
                if state.selectedCategories.contains(category) {
                    state.selectedCategories.remove(category)
                } else {
                    state.selectedCategories.insert(category)
                }
                return .none

            case .didTapPreviousButton:
                guard let previousStep = state.currentStep.previous else {
                    return .send(.delegate(.didTapPrevious))
                }
                state.currentStep = previousStep
                return .none

            case .didTapNextButton:
                guard state.isCurrentStepValid else { return .none }
                guard let nextStep = state.currentStep.next else {
                    return .send(.delegate(.didCompleteAllSteps))
                }
                state.currentStep = nextStep
                return .none

            case .delegate:
                return .none
            }
        }
    }
}

// MARK: - Options

extension OnboardingContainerFeature {

    // TODO: BaziDomain에 실제 행정구역 UseCase가 준비되면 교체.
    public static let provinces = [
        "서울특별시", "부산광역시", "대구광역시", "인천광역시", "광주광역시",
        "대전광역시", "울산광역시", "세종특별자치시", "경기도", "강원특별자치도",
        "충청북도", "충청남도", "전북특별자치도", "전라남도", "경상북도", "경상남도", "제주특별자치도",
    ]

    // TODO: province별 실제 시/군/구 목록으로 교체.
    public static let districts = ["전체"]

    public static let educationOptions = [
        "고등학교에 재학 중이에요",
        "고등학교를 졸업했어요 (검정고시 포함)",
        "대학교에 재학·휴학·수료 중이에요",
        "대학교를 졸업했어요",
        "석·박사 과정을 밟고 있거나 마쳤어요",
        "기타 / 해당 없어요",
    ]

    public static let employmentOptions = [
        "재직 중이에요 (정규직/계약직 포함)",
        "단기·일용 근로 중이에요",
        "자영업/사업을 하고 있어요",
        "프리랜서로 일하고 있어요",
        "현재 일하고 있지 않아요",
        "기타 / 해당 없어요",
    ]

    public static let incomeOptions = [
        "1분위", "2분위", "3분위", "4분위", "5분위",
        "6분위", "7분위", "8분위", "9분위", "10분위",
        "잘 모르겠어요",
    ]

    public static let minimumInterestCount = 3

    public static let interestCategories = [
        "취업 준비", "직장 생활",
        "창업", "주거",
        "교육 · 성장", "생활비 · 금융",
        "건강 · 복지", "권리 보호",
        "문화 · 예술", "참여 · 활동",
    ]
}
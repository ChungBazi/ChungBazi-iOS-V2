// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziCore
import BaziDomain
import ComposableArchitecture

/// 온보딩의 "진행 중" 6단계(생년월일~관심분야)를 하나의 컨테이너로 관리한다.
/// 진행바/하단 버튼이 화면 전환 없이 유지되어야 하므로 각 단계를 별도 push 화면이 아닌 `currentStep` 전환으로 다룬다.
/// State는 표시용 VO(`RegionVO`, `EducationUI` 등)를 보유하고, 제출 시에만 도메인 코드로 변환한다.
@Reducer
public struct OnboardingContainerFeature {

    // MARK: - Step

    public enum Step: Int, CaseIterable, Equatable {
        case birthDate = 1
        case region
        case education
        case employment
        case income
        case specialEligibility
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
        public var sidoOptions: [RegionVO] = []
        public var sigunguOptions: [RegionVO] = []
        public var selectedSido: RegionVO?
        public var selectedSigungu: RegionVO?

        // MARK: Education / Employment / Income
        public var education: EducationUI?
        public var employment: EmploymentUI?
        public var income: IncomeLevelUI?

        // MARK: Special Eligibility (해당 사항)
        public var specialEligibilities: Set<SpecialEligibilityUI> = []

        // MARK: Interest
        public var interests: Set<InterestCategoryUI> = []

        // MARK: Submit
        public var isSubmitting = false

        public init() {}

        var isCurrentStepValid: Bool {
            switch currentStep {
            case .birthDate: return hasChangedYear && hasChangedMonth && hasChangedDay
            case .region: return selectedSido != nil && selectedSigungu != nil
            case .education: return education != nil
            case .employment: return employment != nil
            case .income: return income != nil
            case .specialEligibility: return !specialEligibilities.isEmpty
            case .interest: return interests.count >= OnboardingContainerFeature.minimumInterestCount
            }
        }
    }

    // MARK: - Action

    public enum Action: BindableAction, Equatable {
        // MARK: View
        case onAppear
        case binding(BindingAction<State>)
        case didSelectSido(RegionVO?)
        case didSelectSigungu(RegionVO?)
        case didSelectEducation(EducationUI?)
        case didSelectEmployment(EmploymentUI?)
        case didSelectIncome(IncomeLevelUI?)
        case didTapInterest(InterestCategoryUI)
        case didTapSpecialEligibility(SpecialEligibilityUI)
        case didTapPreviousButton
        case didTapNextButton

        // MARK: Internal
        case sidoResponse(Result<[RegionVO], UseCaseError>)
        case sigunguResponse(Result<[RegionVO], UseCaseError>)
        case didSubmitOnboarding(String)
        case didFailToSubmitOnboarding(UseCaseError)

        // MARK: Delegate
        case delegate(Delegate)
    }

    // MARK: - Delegate

    public enum Delegate: Equatable {
        case didTapPrevious
        case didCompleteAllSteps(String)
    }

    // MARK: - Dependencies

    @Dependency(\.onboardingClient) var onboardingClient
    @Dependency(\.date.now) var now
    @Dependency(\.calendar) var calendar

    // MARK: - Init

    public init() {}

    // MARK: - CancelID

    private enum CancelID {
        case sigunguFetch
    }

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { [onboardingClient] send in
                    do {
                        let sido = try await onboardingClient.fetchSidoList()
                        await send(.sidoResponse(.success(sido.map(RegionVO.init))))
                    } catch {
                        await send(.sidoResponse(.failure(UseCaseError.map(error))))
                    }
                }

            case .sidoResponse(.success(let list)):
                state.sidoOptions = list
                return .none

            case .sidoResponse(.failure):
                // TODO: 시도 목록 로드 실패 알림 UI가 정해지면 State에 반영.
                return .none

            case .didSelectSido(let sido):
                state.selectedSido = sido
                return fetchSigunguList(&state)

            case .sigunguResponse(.success(let list)):
                state.sigunguOptions = list
                return .none

            case .sigunguResponse(.failure):
                // TODO: 시군구 목록 로드 실패 알림 UI가 정해지면 State에 반영.
                return .none

            case .didSelectSigungu(let sigungu):
                state.selectedSigungu = sigungu
                return .none

            case .didSelectEducation(let value):
                state.education = value
                return .none

            case .didSelectEmployment(let value):
                state.employment = value
                return .none

            case .didSelectIncome(let value):
                state.income = value
                return .none

            case .didTapInterest(let interest):
                if state.interests.contains(interest) {
                    state.interests.remove(interest)
                } else {
                    state.interests.insert(interest)
                }
                return .none

            case .didTapSpecialEligibility(let item):
                // '해당 없어요'와 나머지는 상호 배타 — 한쪽을 켜면 반대편은 자동 해제한다.
                if item == .notApplicable {
                    state.specialEligibilities = state.specialEligibilities.contains(.notApplicable) ? [] : [.notApplicable]
                } else {
                    state.specialEligibilities.remove(.notApplicable)
                    if state.specialEligibilities.contains(item) {
                        state.specialEligibilities.remove(item)
                    } else {
                        state.specialEligibilities.insert(item)
                    }
                }
                return .none

            case .binding(\.year):
                state.hasChangedYear = true
                clampBirthDateToToday(&state)
                return .none

            case .binding(\.month):
                state.hasChangedMonth = true
                clampBirthDateToToday(&state)
                return .none

            case .binding(\.day):
                state.hasChangedDay = true
                return .none

            case .binding:
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
                    return submitOnboarding(state: &state)
                }
                state.currentStep = nextStep
                return .none

            case .didSubmitOnboarding(let nickname):
                state.isSubmitting = false
                return .send(.delegate(.didCompleteAllSteps(nickname)))

            case .didFailToSubmitOnboarding:
                state.isSubmitting = false
                // TODO: 온보딩 제출 실패 알림 UI가 정해지면 State에 반영.
                return .none

            case .delegate:
                return .none
            }
        }
    }

    // MARK: - Private

    /// 생년월일이 오늘을 넘지 않도록 연/월 변경 시 연·월·일을 보정한다. (미래 생일 방지)
    private func clampBirthDateToToday(_ state: inout State) {
        let clamped = CalendarUtil.clampToNotFuture(
            year: state.year,
            month: state.month,
            day: state.day,
            now: now,
            calendar: calendar
        )
        state.year = clamped.year
        state.month = clamped.month
        state.day = clamped.day
    }

    private func fetchSigunguList(_ state: inout State) -> Effect<Action> {
        state.selectedSigungu = nil
        state.sigunguOptions = []
        guard let sidoCode = state.selectedSido?.code else {
            return .cancel(id: CancelID.sigunguFetch)
        }
        return .run { [onboardingClient] send in
            do {
                let list = try await onboardingClient.fetchSigunguList(sidoCode)
                await send(.sigunguResponse(.success(list.map(RegionVO.init))))
            } catch {
                await send(.sigunguResponse(.failure(UseCaseError.map(error))))
            }
        }
        .cancellable(id: CancelID.sigunguFetch, cancelInFlight: true)
    }

    private func submitOnboarding(state: inout State) -> Effect<Action> {
        guard
            let sido = state.selectedSido,
            let sigungu = state.selectedSigungu,
            let education = state.education,
            let employment = state.employment,
            let income = state.income
        else {
            return .none
        }

        let info = OnboardingInfo(
            birth: String(format: "%04d-%02d-%02d", state.year, state.month, state.day),
            sidoCode: sido.code,
            sigunguCode: sigungu.code,
            educationCode: education.toDomain(),
            employmentCode: employment.toDomain(),
            incomeLevel: income.toDomain(),
            interestCategories: state.interests.map { $0.toDomain() },
            specialEligibilities: state.specialEligibilities.map { $0.toDomain() }
        )

        state.isSubmitting = true
        return .run { [onboardingClient] send in
            do {
                let nickname = try await onboardingClient.submitOnboarding(info)
                await send(.didSubmitOnboarding(nickname))
            } catch {
                await send(.didFailToSubmitOnboarding(UseCaseError.map(error)))
            }
        }
    }
}

// MARK: - Options

extension OnboardingContainerFeature {
    public static let minimumInterestCount = 3
}

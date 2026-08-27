// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziDomain
import ComposableArchitecture

/// 온보딩의 "진행 중" 6단계(생년월일~관심분야)를 하나의 컨테이너로 관리한다.
/// 진행바/하단 버튼이 화면 전환 없이 유지되어야 하므로 각 단계를 별도 push 화면이 아닌 `currentStep` 전환으로 다룬다.
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
        public var sidoList: [RegionInfo] = []
        public var sigunguList: [RegionInfo] = []
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

        // MARK: Submit
        public var isSubmitting = false

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

    public enum Action: BindableAction, Equatable {
        // MARK: View
        case onAppear
        case binding(BindingAction<State>)
        case didTapCategory(String)
        case didTapPreviousButton
        case didTapNextButton

        // MARK: Internal
        case sidoListResponse(Result<[RegionInfo], UseCaseError>)
        case sigunguListResponse(Result<[RegionInfo], UseCaseError>)
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

    // MARK: - Init

    public init() {}

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { [onboardingClient] send in
                    do {
                        let sidoList = try await onboardingClient.fetchSidoList()
                        await send(.sidoListResponse(.success(sidoList)))
                    } catch {
                        await send(.sidoListResponse(.failure(UseCaseError.map(error))))
                    }
                }

            case .sidoListResponse(.success(let list)):
                state.sidoList = list
                return .none

            case .sidoListResponse(.failure):
                // TODO: 시도 목록 로드 실패 알림 UI가 정해지면 State에 반영.
                return .none

            case .binding(\.province):
                return fetchSigunguList(state: &state)

            case .sigunguListResponse(.success(let list)):
                state.sigunguList = list
                return .none

            case .sigunguListResponse(.failure):
                // TODO: 시군구 목록 로드 실패 알림 UI가 정해지면 State에 반영.
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

    private enum CancelID {
        case sigunguFetch
    }

    private func fetchSigunguList(state: inout State) -> Effect<Action> {
        state.district = nil
        state.sigunguList = []
        guard let sidoCode = state.sidoList.first(where: { $0.name == state.province })?.code else {
            return .cancel(id: CancelID.sigunguFetch)
        }
        return .run { [onboardingClient] send in
            do {
                let list = try await onboardingClient.fetchSigunguList(sidoCode)
                await send(.sigunguListResponse(.success(list)))
            } catch {
                await send(.sigunguListResponse(.failure(UseCaseError.map(error))))
            }
        }
        .cancellable(id: CancelID.sigunguFetch, cancelInFlight: true)
    }

    private func submitOnboarding(state: inout State) -> Effect<Action> {
        guard
            let sidoCode = state.sidoList.first(where: { $0.name == state.province })?.code,
            let sigunguCode = state.sigunguList.first(where: { $0.name == state.district })?.code,
            let educationCode = EducationCode.onboardingOptions.first(where: { $0.displayName == state.education }),
            let employmentCode = EmploymentCode.onboardingOptions.first(where: { $0.displayName == state.employment }),
            let incomeLevel = IncomeLevel.onboardingOptions.first(where: { $0.displayName == state.income })
        else {
            return .none
        }

        let interestCategories = PolicySubCategoryType.allCases.filter {
            state.selectedCategories.contains($0.displayName)
        }
        let info = OnboardingInfo(
            birth: String(format: "%04d-%02d-%02d", state.year, state.month, state.day),
            sidoCode: sidoCode,
            sigunguCode: sigunguCode,
            educationCode: educationCode,
            employmentCode: employmentCode,
            incomeLevel: incomeLevel,
            interestCategories: interestCategories
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

    public static let educationOptions = EducationCode.onboardingOptions.map(\.displayName)
    public static let employmentOptions = EmploymentCode.onboardingOptions.map(\.displayName)
    public static let incomeOptions = IncomeLevel.onboardingOptions.map(\.displayName)
    public static let minimumInterestCount = 3
    public static let interestCategories = PolicySubCategoryType.allCases.map(\.displayName)
}

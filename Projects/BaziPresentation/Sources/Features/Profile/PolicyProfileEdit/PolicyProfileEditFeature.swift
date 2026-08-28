// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziCore
import BaziDomain
import ComposableArchitecture

/// 프로필 > 정책 맞춤 조건 수정(24). 온보딩과 동일한 항목(생년월일/거주지역/학업단계/직업/소득분위/관심분야)을
/// 한 화면에 모아 보여주고 한 번에 저장한다.
@Reducer
public struct PolicyProfileEditFeature {

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        // MARK: BirthDate
        public var year: Int
        public var month: Int
        public var day: Int

        // MARK: Region
        public var sidoList: [RegionInfo] = []
        public var sigunguList: [RegionInfo] = []
        public var province: String?
        public var district: String?

        // MARK: Education / Employment / Income
        public var education: String?
        public var employment: String?
        public var income: String?

        // MARK: Interest
        public var selectedCategories: Set<String>

        // MARK: Save
        public var isSaving = false
        public var isSuccessToastPresented = false

        public init(
            year: Int = 2000,
            month: Int = 1,
            day: Int = 1,
            province: String? = nil,
            district: String? = nil,
            education: String? = nil,
            employment: String? = nil,
            income: String? = nil,
            selectedCategories: Set<String> = []
        ) {
            self.year = year
            self.month = month
            self.day = day
            self.province = province
            self.district = district
            self.education = education
            self.employment = employment
            self.income = income
            self.selectedCategories = selectedCategories
        }

        /// 선택된 연/월 기준 실제 일수(윤년 2월 포함).
        public var daysInSelectedMonth: Int {
            CalendarUtil.daysInMonth(year: year, month: month)
        }

        public var isSaveEnabled: Bool {
            province != nil
                && district != nil
                && education != nil
                && employment != nil
                && income != nil
                && selectedCategories.count >= PolicyProfileEditFeature.minimumInterestCount
                && !isSaving
        }
    }

    // MARK: - Action

    public enum Action: BindableAction, Equatable {
        // MARK: View
        case onAppear
        case binding(BindingAction<State>)
        case didTapCategory(String)
        case didTapSaveButton

        // MARK: Internal
        case sidoListResponse(Result<[RegionInfo], UseCaseError>)
        case sigunguListResponse(Result<[RegionInfo], UseCaseError>)
        case didSaveProfile

        // MARK: Delegate
        case delegate(Delegate)
    }

    // MARK: - Delegate

    public enum Delegate: Equatable {}

    // MARK: - Dependencies

    @Dependency(\.onboardingClient) var onboardingClient
    // TODO: BaziDomain의 정책 맞춤 조건 조회/수정 UseCase가 준비되면 추가
    // @Dependency(\.policyProfileClient) var policyProfileClient

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
                // TODO: policyProfileClient가 준비되면 getPolicyProfile 응답으로 현재 값을 채운다.
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
                state.day = min(state.day, state.daysInSelectedMonth)
                return .none

            case .binding(\.month):
                state.day = min(state.day, state.daysInSelectedMonth)
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

            case .didTapSaveButton:
                guard state.isSaveEnabled else { return .none }
                state.isSaving = true
                // TODO: policyProfileClient가 준비되면 실제 updatePolicyProfile 호출로 교체한다.
                return .run { send in
                    await send(.didSaveProfile)
                }

            case .didSaveProfile:
                state.isSaving = false
                state.isSuccessToastPresented = true
                return .none

            case .delegate:
                return .none
            }
        }
    }

    // MARK: - Private

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
}

// MARK: - Options

extension PolicyProfileEditFeature {

    public static let educationOptions = EducationCode.onboardingOptions.map(\.displayName)
    public static let employmentOptions = EmploymentCode.onboardingOptions.map(\.displayName)
    public static let incomeOptions = IncomeLevel.onboardingOptions.map(\.displayName)
    public static let minimumInterestCount = 3
    public static let interestCategories = PolicySubCategoryType.allCases.map(\.displayName)
}

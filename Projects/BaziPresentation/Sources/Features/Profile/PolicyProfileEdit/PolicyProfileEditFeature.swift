// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziCore
import BaziDomain
import ComposableArchitecture

/// 프로필 > 정책 맞춤 조건 수정. 서버 기존 값(getPolicyProfile)으로 프리필하고, 수정 후 저장(updatePolicyProfile)한다.
/// State는 표시용 VO(`RegionVO`, `EducationUI` 등)를 보유하고, 저장/프리필 시에만 도메인 코드로 변환한다.
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
        public var sidoOptions: [RegionVO] = []
        public var sigunguOptions: [RegionVO] = []
        public var selectedSido: RegionVO?
        public var selectedSigungu: RegionVO?
        /// 프리필 시 시군구 목록 로드 후 이 코드로 selectedSigungu를 채운다.
        public var pendingSigunguCode: String?

        // MARK: Education / Employment / Income
        public var education: EducationUI?
        public var employment: EmploymentUI?
        public var income: IncomeLevelUI?

        // MARK: Special Eligibility (해당 사항)
        public var specialEligibilities: Set<SpecialEligibilityUI> = []

        // MARK: Interest
        public var interests: Set<InterestCategoryUI> = []

        // MARK: Save
        public var isSaving = false
        public var isSuccessToastPresented = false
        public var isFailureToastPresented = false
        /// onAppear 프리필을 최초 1회만 수행하기 위한 플래그. (탭 전환 등으로 화면이 재등장할 때
        /// 저장하지 않은 편집이 서버 값으로 되돌아가는 것을 막는다)
        public var hasLoaded = false
        /// 프리필/저장 시점의 값 스냅샷. 현재 편집값이 이와 같으면(원래값과 동일 / 저장 직후) 저장 버튼을 비활성화한다.
        public var savedSnapshot: Snapshot?

        public init(year: Int = 2000, month: Int = 1, day: Int = 1) {
            self.year = year
            self.month = month
            self.day = day
        }

        /// 저장 대상 편집 필드의 변경 여부 판정용 스냅샷.
        public struct Snapshot: Equatable, Sendable {
            var year: Int
            var month: Int
            var day: Int
            var sidoCode: String?
            var sigunguCode: String?
            var education: EducationUI?
            var employment: EmploymentUI?
            var income: IncomeLevelUI?
            var specialEligibilities: Set<SpecialEligibilityUI>
            var interests: Set<InterestCategoryUI>
        }

        public var currentSnapshot: Snapshot {
            Snapshot(
                year: year,
                month: month,
                day: day,
                sidoCode: selectedSido?.code,
                sigunguCode: selectedSigungu?.code,
                education: education,
                employment: employment,
                income: income,
                specialEligibilities: specialEligibilities,
                interests: interests
            )
        }

        public var isSaveEnabled: Bool {
            selectedSido != nil
                && selectedSigungu != nil
                && education != nil
                && employment != nil
                && income != nil
                && interests.count >= PolicyProfileEditFeature.minimumInterestCount
                && !specialEligibilities.isEmpty
                && !isSaving
                && currentSnapshot != savedSnapshot
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
        case didTapSaveButton

        // MARK: Internal
        case profileResponse(Result<OnboardingInfo, UseCaseError>)
        case sidoResponse(Result<[RegionVO], UseCaseError>)
        case sigunguResponse(Result<[RegionVO], UseCaseError>)
        case didSaveProfile(State.Snapshot)
        case didFailToSaveProfile(UseCaseError)

        // MARK: Delegate
        case delegate(Delegate)
    }

    // MARK: - Delegate

    public enum Delegate: Equatable {}

    // MARK: - Dependencies

    @Dependency(\.onboardingClient) var onboardingClient
    @Dependency(\.policyProfileClient) var policyProfileClient
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
                // 재등장(탭 전환 등) 시 프리필이 저장 안 한 편집을 덮어쓰지 않도록 최초 1회만 로드한다.
                guard !state.hasLoaded else { return .none }
                state.hasLoaded = true
                // 시도 목록을 먼저 받은 뒤 프로필을 받아, sidoCode를 시도 VO로 역매핑할 수 있게 한다.
                return .run { [onboardingClient, policyProfileClient] send in
                    do {
                        let sido = try await onboardingClient.fetchSidoList()
                        await send(.sidoResponse(.success(sido.map(RegionVO.init))))
                    } catch {
                        await send(.sidoResponse(.failure(UseCaseError.map(error))))
                    }
                    do {
                        let profile = try await policyProfileClient.getPolicyProfile()
                        await send(.profileResponse(.success(profile)))
                    } catch {
                        await send(.profileResponse(.failure(UseCaseError.map(error))))
                    }
                }

            case .sidoResponse(.success(let list)):
                state.sidoOptions = list
                return .none

            case .sidoResponse(.failure):
                // TODO: 시도 목록 로드 실패 알림 UI가 정해지면 State에 반영.
                return .none

            case .profileResponse(.success(let profile)):
                applyProfile(profile, to: &state)
                // 서버 프리필 기준 스냅샷을 동기 시점에 고정한다. 시군구는 곧 로드될 pendingSigunguCode로 미리 반영해,
                // 응답 대기 중 사용자가 편집하더라도 기준이 오염되지 않게 한다.
                var baseline = state.currentSnapshot
                baseline.sigunguCode = state.pendingSigunguCode
                state.savedSnapshot = baseline
                return fetchSigunguList(&state)

            case .profileResponse(.failure):
                // TODO: 정책 맞춤 조건 조회 실패 알림 UI가 정해지면 State에 반영.
                return .none

            case .didSelectSido(let sido):
                state.selectedSido = sido
                state.pendingSigunguCode = nil
                return fetchSigunguList(&state)

            case .sigunguResponse(.success(let list)):
                state.sigunguOptions = list
                if let code = state.pendingSigunguCode {
                    state.selectedSigungu = list.first { $0.code == code }
                    state.pendingSigunguCode = nil
                    // 기준 스냅샷은 profileResponse에서 이미 고정했으므로 여기서 다시 설정하지 않는다.
                }
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

            case .binding(\.year), .binding(\.month):
                clampBirthDateToToday(&state)
                return .none

            case .binding:
                return .none

            case .didTapSaveButton:
                guard state.isSaveEnabled, let info = makeOnboardingInfo(state) else { return .none }
                state.isSaving = true
                // 저장 요청에 사용한 값을 고정한다. 저장 중 편집이 있어도 그 편집분은 미저장으로 남아 재저장 가능.
                let requestedSnapshot = state.currentSnapshot
                return .run { [policyProfileClient] send in
                    do {
                        try await policyProfileClient.updatePolicyProfile(info)
                        await send(.didSaveProfile(requestedSnapshot))
                    } catch {
                        await send(.didFailToSaveProfile(UseCaseError.map(error)))
                    }
                }

            case .didSaveProfile(let requestedSnapshot):
                state.isSaving = false
                state.isFailureToastPresented = false
                state.isSuccessToastPresented = true
                // 실제로 저장 요청에 사용한 스냅샷만 기준으로 삼는다. (저장 중 편집분은 미저장으로 유지)
                state.savedSnapshot = requestedSnapshot
                return .none

            case .didFailToSaveProfile:
                state.isSaving = false
                state.isSuccessToastPresented = false
                state.isFailureToastPresented = true
                return .none

            case .delegate:
                return .none
            }
        }
    }

    // MARK: - Private

    /// 서버 프로필(도메인 코드)을 화면 VO로 역매핑해 프리필한다. (시군구는 목록 로드 후 pendingSigunguCode로 해결)
    private func applyProfile(_ profile: OnboardingInfo, to state: inout State) {
        let parts = profile.birth.split(separator: "-").compactMap { Int($0) }
        if parts.count == 3 {
            state.year = parts[0]
            state.month = parts[1]
            state.day = parts[2]
        }
        state.selectedSido = state.sidoOptions.first { $0.code == profile.sidoCode }
        state.pendingSigunguCode = profile.sigunguCode
        state.education = EducationUI(domain: profile.educationCode)
        state.employment = EmploymentUI(domain: profile.employmentCode)
        state.income = IncomeLevelUI(domain: profile.incomeLevel)
        state.interests = Set(profile.interestCategories.compactMap(InterestCategoryUI.init(domain:)))
        state.specialEligibilities = Set(profile.specialEligibilities.compactMap(SpecialEligibilityUI.init(domain:)))
    }

    /// 화면 VO를 도메인 코드로 조립한다. 필수 값이 없으면 nil.
    private func makeOnboardingInfo(_ state: State) -> OnboardingInfo? {
        guard
            let sido = state.selectedSido,
            let sigungu = state.selectedSigungu,
            let education = state.education,
            let employment = state.employment,
            let income = state.income
        else {
            return nil
        }
        return OnboardingInfo(
            birth: BaziDateFormat.serverDayString(year: state.year, month: state.month, day: state.day),
            sidoCode: sido.code,
            sigunguCode: sigungu.code,
            educationCode: education.toDomain(),
            employmentCode: employment.toDomain(),
            incomeLevel: income.toDomain(),
            interestCategories: state.interests.map { $0.toDomain() },
            specialEligibilities: state.specialEligibilities.map { $0.toDomain() }
        )
    }

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
}

// MARK: - Options

extension PolicyProfileEditFeature {
    public static let minimumInterestCount = 3
}

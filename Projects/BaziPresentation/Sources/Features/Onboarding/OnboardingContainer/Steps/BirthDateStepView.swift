// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import BaziDesign
import ComposableArchitecture

struct BirthDateStepView: View {

    // MARK: - Properties

    @Bindable var store: StoreOf<OnboardingContainerFeature>

    // MARK: - Body

    var body: some View {
        VStack(spacing: 90) {
            titleText
            datePicker
        }
    }
}

// MARK: - Subviews

extension BirthDateStepView {

    private var titleText: some View {
        Text("생년월일이 언제인가요?")
            .baziFont(.head22B)
            .foregroundStyle(Color.grayBlack)
    }

    private static var maxBirthYear: Int {
        Calendar.current.component(.year, from: Date())
    }

    private var datePicker: some View {
        HStack(spacing: 0) {
            dateColumn(label: "년") {
                BZDatePicker(selection: $store.year, range: 1926...Self.maxBirthYear) { "\($0)" }
            }

            dateColumn(label: "월") {
                BZDatePicker(selection: $store.month, range: 1...12) { String(format: "%02d", $0) }
            }

            dateColumn(label: "일") {
                BZDatePicker(selection: $store.day, range: 1...store.daysInSelectedMonth) { String(format: "%02d", $0) }
            }
        }
    }

    private func dateColumn(label: String, @ViewBuilder picker: () -> some View) -> some View {
        VStack(spacing: 8) {
            columnLabel(label)

            picker()
                .frame(height: BZDatePicker.height)
        }
        .frame(maxWidth: .infinity)
    }

    private func columnLabel(_ text: String) -> some View {
        Text(text)
            .baziFont(.small12M)
            .foregroundStyle(Color.gray700)
    }
}

// MARK: - Preview

#Preview {
    BirthDateStepView(
        store: Store(initialState: .init()) {
            OnboardingContainerFeature()
        }
    )
}

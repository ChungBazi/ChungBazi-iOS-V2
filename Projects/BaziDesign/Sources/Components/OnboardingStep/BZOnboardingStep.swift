// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

public struct BZOnboardingStep: View {

    // MARK: - Properties

    private let currentStep: Int
    private let totalSteps: Int

    // MARK: - Init

    public init(currentStep: Int, totalSteps: Int = 6) {
        self.currentStep = currentStep
        self.totalSteps = totalSteps
    }

    // MARK: - Body

    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray100)

                Capsule()
                    .fill(Color.bazi(.primary))
                    .frame(width: proxy.size.width * fraction)
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
        }
        .frame(height: 4)
        .accessibilityElement()
        .accessibilityLabel("진행 단계")
        .accessibilityValue(accessibilityStepValue)
    }
}

// MARK: - Private

extension BZOnboardingStep {

    private var fraction: CGFloat {
        guard totalSteps > 0 else { return 0 }
        let clampedStep = min(max(currentStep, 0), totalSteps)
        return CGFloat(clampedStep) / CGFloat(totalSteps)
    }

    /// 접근성 값도 `fraction`과 같은 보정을 적용해 표시와 일치시킨다.
    private var accessibilityStepValue: String {
        let steps = max(totalSteps, 0)
        guard steps > 0 else { return "0단계 중 0단계" }
        let clampedStep = min(max(currentStep, 0), steps)
        return "\(steps)단계 중 \(clampedStep)단계"
    }
}

// MARK: - Preview

private struct BZOnboardingStepPreview: View {
    @State private var step = 1

    var body: some View {
        VStack(spacing: 24) {
            BZOnboardingStep(currentStep: step)
                .padding(.horizontal, 20)

            HStack {
                Button("이전") { if step > 0 { step -= 1 } }
                Button("다음") { if step < 6 { step += 1 } }
            }
        }
    }
}

#Preview {
    BZOnboardingStepPreview()
}

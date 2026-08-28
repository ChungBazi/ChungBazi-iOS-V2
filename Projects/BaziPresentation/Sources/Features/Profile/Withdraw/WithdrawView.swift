// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import BaziDesign
import ComposableArchitecture

public struct WithdrawView: View {

    // MARK: - Properties

    @Bindable var store: StoreOf<WithdrawFeature>
    @Environment(\.dismiss) private var dismiss

    // MARK: - Init

    public init(store: StoreOf<WithdrawFeature>) {
        self.store = store
    }

    // MARK: - Body

    public var body: some View {
        content
            .baziNavigationBar_backWithTitle("탈퇴하기") {
                dismiss()
            }
            .baziAlert(
                isPresented: Binding(
                    get: { store.isConfirmAlertPresented },
                    set: { if !$0 { store.send(.didCancelConfirm) } }
                ),
                title: "정말 탈퇴하시겠어요?",
                message: "탈퇴하면 계정과 저장된 정보가 삭제되며,\n삭제된 정보는 복구할 수 없어요",
                confirmTitle: "탈퇴하기",
                confirmType: .accent,
                onConfirm: { store.send(.didConfirmWithdraw) }
            )
            .alert(
                "회원 탈퇴가 완료되었습니다.",
                isPresented: Binding(
                    get: { store.isCompletionAlertPresented },
                    set: { isPresented in
                        if !isPresented { store.send(.didTapCompletionConfirm) }
                    }
                )
            ) {
                Button("확인") { store.send(.didTapCompletionConfirm) }
            }
    }
}

// MARK: - Content

extension WithdrawView {

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                titleSection
                noticeBox
                confirmedCheckbox
                reasonSection
                detailTextField
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 95)
        }
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom) {
            actionButtons
                .padding(.horizontal, 20)
                .padding(.vertical, 5)
                .background(Color.bazi(.bgWhite))
        }
        .baziBackground(.bgWhite)
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("회원 탈퇴 전\n확인해주세요.")
                .baziFont(.head22B)
                .foregroundStyle(Color.gray900)
            Text("탈퇴하면 계정과 저장된 정보가 삭제되며 복구할 수 없습니다.\n아래 내용을 확인한 후 진행해주세요.")
                .baziFont(.small14R)
                .foregroundStyle(Color.gray500)
        }
        .padding(.vertical, 12)
    }

    private var noticeBox: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("탈퇴 시 처리되는 내용")
                .baziFont(.body16SB)
                .foregroundStyle(Color.gray900)
            ForEach(Self.noticeItems, id: \.self) { item in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 5)
                        .padding(.top, 5)
                    Text(item)
                }
                .baziFont(.small14R)
                .foregroundStyle(Color.gray700)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.bazi(.bgWhite))
        .overlay(
            RoundedRectangle(cornerRadius: BaziRadius.small.rawValue, style: .continuous)
                .strokeBorder(Color.gray200, lineWidth: 0.8)
        )
        .baziRadius(.small)
    }

    private static let noticeItems = [
        "회원 정보와 프로필이 삭제됩니다.",
        "찜한 정책, 메모, 활동 기록이 삭제됩니다.",
        "저장된 알림 설정이 삭제됩니다.",
        "탈퇴 후에는 동일한 계정으로 다시 로그인해도 이전 데이터는 복구되지 않습니다.",
    ]

    private var confirmedCheckbox: some View {
        checkboxRow(
            title: "위 내용을 모두 확인했습니다.",
            suffix: "(필수)",
            suffixColor: Color.bazi(.accent),
            isSelected: store.hasConfirmedNotice
        ) {
            store.send(.didToggleConfirmedNotice)
        }
        .padding(.vertical, 22)
    }
}

// MARK: - Reason

extension WithdrawView {

    private var reasonSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("탈퇴하려는 이유를 알려주세요.")
                    .baziFont(.head18B)
                    .foregroundStyle(Color.gray900)
                Text("복수 선택 가능 · 필수")
                    .baziFont(.small12R)
                    .foregroundStyle(Color.gray500)
            }

            ForEach(WithdrawFeature.reasons, id: \.self) { reason in
                checkboxRow(title: reason, isSelected: store.selectedReasons.contains(reason)) {
                    store.send(.didToggleReason(reason))
                }
            }
        }
        .padding(.vertical, 28)
    }

    private var detailTextField: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 4) {
                Text("기타 불편했던 점을 자세히 알려주세요.")
                    .baziFont(.body16M)
                    .foregroundStyle(Color.gray700)
                Text("(선택)")
                    .baziFont(.body16R)
                    .foregroundStyle(Color.bazi(.primary))
            }

            TextEditor(text: Binding(
                get: { store.detailText },
                set: { store.send(.didChangeDetailText($0)) }
            ))
            .baziFont(.small14R)
            .foregroundStyle(Color.grayBlack)
            .scrollContentBackground(.hidden)
            .frame(height: 150)
            .padding(8)
            .overlay {
                if store.detailText.isEmpty {
                    Text("불편했던 점이나 개선되었으면 하는 내용을 자유롭게 작성해주세요.")
                        .baziFont(.small14R)
                        .foregroundStyle(Color.gray400)
                        .padding(16)
                        .allowsHitTesting(false)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: BaziRadius.small.rawValue, style: .continuous)
                    .strokeBorder(Color.gray200, lineWidth: 0.8)
            )
        }
        .padding(.vertical, 24)
    }

    private func checkboxRow(title: String, suffix: String? = nil, suffixColor: Color = Color.gray400, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image.bazi(isSelected ? .filledCheckbox : .unfilledCheckbox)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20)
                HStack(spacing: 4) {
                    Text(title)
                        .foregroundStyle(Color.gray700)
                    if let suffix {
                        Text(suffix)
                            .foregroundStyle(suffixColor)
                    }
                }
                .baziFont(.body16R)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Bottom Buttons

extension WithdrawView {

    private var actionButtons: some View {
        HStack(spacing: 10) {
            BZButton("취소하기", type: .normal, size: .medium) {
                dismiss()
            }
            BZButton("탈퇴하기", type: .accent, size: .medium) {
                store.send(.didTapWithdrawButton)
            }
            .disabled(!store.isSubmitEnabled)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        WithdrawView(
            store: Store(initialState: .init()) {
                WithdrawFeature()
            }
        )
    }
}

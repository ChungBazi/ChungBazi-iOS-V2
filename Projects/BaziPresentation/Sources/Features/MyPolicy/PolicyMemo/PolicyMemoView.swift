// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import BaziDesign
import ComposableArchitecture

public struct PolicyMemoView: View {

    // MARK: - Properties

    @Bindable var store: StoreOf<PolicyMemoFeature>
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool

    // MARK: - Init

    public init(store: StoreOf<PolicyMemoFeature>) {
        self.store = store
    }

    // MARK: - Body

    public var body: some View {
        content
            .task { store.send(.onAppear) }
            .baziNavigationBar_backWithTitleAndSaveButton(
                "메모",
                isSaveEnabled: store.isSaveEnabled,
                onBack: { dismiss() },
                onSave: {
                    store.send(.didTapSave)
                    dismiss()
                }
            )
            .onAppear { isFocused = true }
            .toolbar(.hidden, for: .tabBar)
    }
}

// MARK: - Subviews

extension PolicyMemoView {

    private var content: some View {
        VStack(spacing: 0) {
            if let memo = store.memo {
                header(memo)
            }
            memoEditor
        }
        .baziBackground(.bgWhite)
    }

    private func header(_ memo: PolicyMemo) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                BZTag(memo.category.rawValue, type: .blue200)
                Text(memo.dDay)
                    .baziFont(.small12SB)
                    .foregroundStyle(Color.gray700)
            }
            Text(memo.title)
                .baziFont(.head20B)
                .foregroundStyle(Color.grayBlack)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.blue50)
    }

    private var memoEditor: some View {
        TextEditor(
            text: Binding(
                get: { store.draftText },
                set: { store.send(.didChangeDraftText($0)) }
            )
        )
        .focused($isFocused)
        .baziFont(.body16R)
        .foregroundStyle(Color.gray900)
        .scrollContentBackground(.hidden)
        .scrollDismissesKeyboard(.immediately)
        // 텍스트 콘텐츠만 좌우로 인셋하고, 스크롤 인디케이터는 가장자리(맨 오른쪽)에 붙게 둔다.
        .contentMargins(.horizontal, 15, for: .scrollContent)
        .overlay(alignment: .topLeading) {
            if store.draftText.isEmpty {
                Text("신청 일정이나 준비할 내용을 메모해보세요")
                    .baziFont(.body16R)
                    .foregroundStyle(Color.gray300)
                    .padding(.top, 8)
                    .padding(.leading, 20) // 콘텐츠 인셋(15) + TextEditor 내부 여백(5)에 맞춰 텍스트 시작점 정렬
                    .allowsHitTesting(false)
            }
        }
        .padding(.top, 12)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PolicyMemoView(
            store: Store(initialState: .init(policyId: 1)) {
                PolicyMemoFeature()
            }
        )
    }
}

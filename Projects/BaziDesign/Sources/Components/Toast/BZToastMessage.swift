// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

/// 토스트 종류. 기본(안내)과 경고(accent 배경).
public enum BZToastStyle: Equatable {
    case `default`
    case warning

    var background: Color {
        switch self {
        case .default: return Color.blue200
        case .warning: return Color.bazi(.accent)
        }
    }

    var foreground: Color {
        switch self {
        case .default: return Color.gray800
        case .warning: return Color.grayWhite
        }
    }
}

/// 화면 하단 등에 잠깐 띄우는 토스트 메시지. (Figma: Overlay - Toast Message)
public struct BZToastMessage: View {

    // MARK: - Properties

    private let message: String
    private let style: BZToastStyle

    // MARK: - Init

    public init(_ message: String, style: BZToastStyle = .default) {
        self.message = message
        self.style = style
    }

    // MARK: - Body

    public var body: some View {
        HStack(spacing: 8) {
            icon
                .accessibilityHidden(true)
            Text(message)
                .baziFont(.small14SB)
                .foregroundStyle(style.foreground)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(style.background)
        .baziRadius(.medium)
    }

    @ViewBuilder
    private var icon: some View {
        switch style {
        case .default:
            Image.bazi(.checkIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 16)
        case .warning:
            Image(systemName: "exclamationmark.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 16)
                .foregroundStyle(Color.grayWhite)
        }
    }
}

// MARK: - Anchor

private struct BZToastAnchorKey: PreferenceKey {
    static let defaultValue: Anchor<CGRect>? = nil
    static func reduce(value: inout Anchor<CGRect>?, nextValue: () -> Anchor<CGRect>?) {
        value = value ?? nextValue()
    }
}

extension View {
    /// 토스트를 이 뷰(보통 토스트를 띄우는 버튼) 위에 띄우기 위한 위치 기준을 표시한다.
    public func baziToastAnchor() -> some View {
        anchorPreference(key: BZToastAnchorKey.self, value: .bounds) { $0 }
    }
}

// MARK: - Auto-dismiss

extension View {
    /// `isPresented`가 `true`가 되면 토스트를 띄우고 2초 뒤 자동으로 내린다.
    /// `baziToastAnchor()`로 표시된 뷰가 있으면 그 위 15pt에, 없으면 `edge` 가장자리(20pt)에 띄운다.
    public func baziToast(isPresented: Binding<Bool>, message: String, style: BZToastStyle = .default, edge: VerticalEdge = .bottom) -> some View {
        overlayPreferenceValue(BZToastAnchorKey.self) { anchor in
            GeometryReader { proxy in
                if isPresented.wrappedValue {
                    let placement = BZToastPlacement(anchor: anchor, edge: edge, proxy: proxy)
                    BZToastMessage(message, style: style)
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: placement.alignment)
                        .padding(placement.paddingEdge, placement.inset)
                        .allowsHitTesting(false)
                        .zIndex(999)
                        .transition(.opacity.animation(.easeInOut(duration: 0.3)))
                        .id(message)
                        .task {
                            // 상태 토스트는 자동 낭독되지 않으므로, 뜰 때 VoiceOver로 메시지를 읽어준다.
                            AccessibilityNotification.Announcement(message).post()
                            // 메시지 교체로 .task가 취소되면(.id(message)) 이전 작업이 새 토스트를 지우지 않도록 즉시 반환한다.
                            do {
                                try await Task.sleep(for: .seconds(2.0))
                            } catch {
                                return
                            }
                            isPresented.wrappedValue = false
                        }
                }
            }
        }
    }

    /// 에러 메시지(`String?`)를 warning 토스트로 띄운다. 표시하고 2초 뒤 nil로 지운다.
    /// 쓰기 실패 시 `state.errorToast = 메시지`만 세팅하면 되는 공용 헬퍼(BindableAction 피처용).
    public func baziToast(errorMessage: Binding<String?>, edge: VerticalEdge = .bottom) -> some View {
        baziToast(
            isPresented: Binding(
                get: { errorMessage.wrappedValue != nil },
                set: { if !$0 { errorMessage.wrappedValue = nil } }
            ),
            message: errorMessage.wrappedValue ?? "",
            style: .warning,
            edge: edge
        )
    }

    /// 위 헬퍼의 non-Binding 버전. `BindableAction`이 아니라 `$store` 바인딩을 못 쓰는 피처에서
    /// 2초 뒤 `onDismiss`로 상태를 지우도록 액션을 보내게 한다.
    public func baziToast(errorMessage: String?, onDismiss: @escaping () -> Void, edge: VerticalEdge = .bottom) -> some View {
        baziToast(
            isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { onDismiss() } }
            ),
            message: errorMessage ?? "",
            style: .warning,
            edge: edge
        )
    }
}

// MARK: - Placement

/// 앵커가 있으면 트리거 뷰 상단 15pt 위에, 없으면 지정 edge 가장자리 20pt에 토스트를 둔다.
private struct BZToastPlacement {
    let alignment: Alignment
    let paddingEdge: Edge.Set
    let inset: CGFloat

    init(anchor: Anchor<CGRect>?, edge: VerticalEdge, proxy: GeometryProxy) {
        if let anchor {
            alignment = .bottom
            paddingEdge = .bottom
            inset = max(0, proxy.size.height - proxy[anchor].minY + 15)
        } else if edge == .top {
            alignment = .top
            paddingEdge = .top
            inset = 20
        } else {
            alignment = .bottom
            paddingEdge = .bottom
            inset = 20
        }
    }
}

// MARK: - Preview

private struct BZToastMessagePreview: View {
    @State private var isPresented = false

    var body: some View {
        Button("토스트 띄우기") {
            isPresented = true
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .baziToast(isPresented: $isPresented, message: "텍스트")
    }
}

#Preview {
    BZToastMessagePreview()
}

#Preview("스타일") {
    VStack(spacing: 16) {
        BZToastMessage("정책 맞춤 조건이 수정되었어요")
        BZToastMessage("필수 항목을 모두 선택해 주세요", style: .warning)
    }
    .padding(20)
}

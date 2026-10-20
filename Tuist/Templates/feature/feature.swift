import ProjectDescription

let nameAttribute: Template.Attribute = .required("name")

let template = Template(
    description: "docs/TCA_GUIDELINES.md 컨벤션을 따르는 새 Feature 골격을 생성합니다 (@Reducer + State/Action/Delegate/Dependencies/Init/Body, @Bindable View).",
    attributes: [nameAttribute],
    items: [
        .string(
            path: "Projects/BaziPresentation/Sources/Features/\(nameAttribute)/\(nameAttribute)Feature.swift",
            contents: """
            // Copyright © 2026 ChungBazi. All rights reserved.

            import ComposableArchitecture

            @Reducer
            public struct \(nameAttribute)Feature {

                // MARK: - State

                @ObservableState
                public struct State: Equatable {
                    public init() {}
                }

                // MARK: - Action

                public enum Action {
                    // MARK: View
                    case onAppear

                    // MARK: Internal

                    // MARK: Child

                    // MARK: Delegate
                    case delegate(Delegate)
                }

                // MARK: - Delegate

                public enum Delegate: Equatable {}

                // MARK: - Dependencies

                // TODO: 이 Feature가 쓸 Client가 준비되면 추가
                // @Dependency(\\.someClient) var someClient

                // MARK: - Init

                public init() {}

                // MARK: - Body

                public var body: some ReducerOf<Self> {
                    Reduce { state, action in
                        switch action {
                        case .onAppear:
                            return .none

                        case .delegate:
                            return .none
                        }
                    }
                }
            }
            """
        ),
        .string(
            path: "Projects/BaziPresentation/Sources/Features/\(nameAttribute)/\(nameAttribute)View.swift",
            contents: """
            // Copyright © 2026 ChungBazi. All rights reserved.

            import SwiftUI

            import ComposableArchitecture

            public struct \(nameAttribute)View: View {

                // MARK: - Properties

                @Bindable var store: StoreOf<\(nameAttribute)Feature>

                // MARK: - Init

                public init(store: StoreOf<\(nameAttribute)Feature>) {
                    self.store = store
                }

                // MARK: - Body

                public var body: some View {
                    content
                        .task { store.send(.onAppear) }
                }
            }

            // MARK: - Subviews

            extension \(nameAttribute)View {

                private var content: some View {
                    Text("\(nameAttribute)")
                }
            }

            // MARK: - Preview

            #Preview {
                \(nameAttribute)View(
                    store: Store(initialState: .init()) {
                        \(nameAttribute)Feature()
                    }
                )
            }
            """
        ),
    ]
)

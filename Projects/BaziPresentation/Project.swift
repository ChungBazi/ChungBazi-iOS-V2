import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.project(
    name: BaziModule.BaziPresentation.name,
    targets: [
        .target(
            name: BaziModule.BaziPresentation.name,
            product: Project.product,
            sources: .sources,
            dependencies: [
                .domain(),
                .design(),
                .core(),
                .external(.ComposableArchitecture),
            ],
            // 기기(arm64) Release `-O` 최적화기가 진단 없이 크래시하는 컴파일러 버그 회피.
            // Debug는 기본값이 -Onone이라 영향 없음.
            settings: .settings(base: ["SWIFT_OPTIMIZATION_LEVEL": "-Onone"])
        ),
        .tests(
            name: BaziModule.BaziPresentation.name,
            dependencies: [
                .target(name: BaziModule.BaziPresentation.name),
                .domain(),
                .external(.ComposableArchitecture),
            ]
        ),
    ]
)

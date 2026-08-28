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
            ]
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

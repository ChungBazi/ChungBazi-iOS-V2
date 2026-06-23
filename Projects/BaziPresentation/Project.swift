import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.project(
    name: BaziModule.BaziPresentation.name,
    targets: [
        .target(
            name: BaziModule.BaziPresentation.name,
            product: Project.product,
            sources: .sources,
            resources: .default,
            dependencies: [
                .domain(),
                .design(),
                .core(),
            ]
        ),
        .tests(
            name: BaziModule.BaziPresentation.name
        ),
    ]
)

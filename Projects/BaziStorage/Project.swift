import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.project(
    name: BaziModule.BaziStorage.name,
    targets: [
        .target(
            name: BaziModule.BaziStorage.name,
            product: Project.product,
            sources: .sources,
            dependencies: [
                .core(),
            ]
        ),
        .tests(
            name: BaziModule.BaziStorage.name
        ),
    ]
)

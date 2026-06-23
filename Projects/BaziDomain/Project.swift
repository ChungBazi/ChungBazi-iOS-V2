import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.project(
    name: BaziModule.BaziDomain.name,
    targets: [
        .target(
            name: BaziModule.BaziDomain.name,
            product: Project.product,
            sources: .sources,
            dependencies: [
                .core(),
            ]
        ),
        .tests(
            name: BaziModule.BaziDomain.name
        ),
    ]
)

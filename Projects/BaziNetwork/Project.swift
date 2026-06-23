import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.project(
    name: BaziModule.BaziNetwork.name,
    targets: [
        .target(
            name: BaziModule.BaziNetwork.name,
            product: Project.product,
            sources: .sources,
            dependencies: [
                .core(),
            ]
        ),
        .tests(
            name: BaziModule.BaziNetwork.name
        ),
    ]
)

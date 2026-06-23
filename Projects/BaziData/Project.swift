import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.project(
    name: BaziModule.BaziData.name,
    targets: [
        .target(
            name: BaziModule.BaziData.name,
            product: Project.product,
            sources: .sources,
            dependencies: [
                .domain(),
                .network(),
                .storage(),
                .core(),
            ]
        ),
        .tests(
            name: BaziModule.BaziData.name
        ),
    ]
)

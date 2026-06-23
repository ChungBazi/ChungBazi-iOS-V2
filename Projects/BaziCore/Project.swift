import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.project(
    name: BaziModule.BaziCore.name,
    targets: [
        .target(
            name: BaziModule.BaziCore.name,
            product: Project.product,
            sources: .sources
        ),
        .tests(
            name: BaziModule.BaziCore.name
        ),
    ]
)

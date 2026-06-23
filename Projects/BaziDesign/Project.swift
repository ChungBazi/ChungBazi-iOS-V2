import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.project(
    name: BaziModule.BaziDesign.name,
    targets: [
        .target(
            name: BaziModule.BaziDesign.name,
            product: Project.product,
            sources: .sources,
            resources: .default,
            dependencies: [
                .core(),
            ]
        ),
        .sampleApp(
            name: BaziModule.BaziDesign.name,
            dependencies: [BaziModule.BaziDesign.dependency]
        ),
        .tests(
            name: BaziModule.BaziDesign.name
        ),
    ]
)

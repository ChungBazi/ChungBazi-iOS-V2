import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.project(
    name: BaziModule.ChungBazi.name,
    targets: [
        .target(
            name: BaziModule.ChungBazi.name,
            product: .app,
            bundleId: Project.bundleID,
            infoPlist: .extendingDefault(with: [
                "UILaunchScreen": .dictionary([:]),
                "UISupportedInterfaceOrientations": .array([.string("UIInterfaceOrientationPortrait")]),
                "UIApplicationSceneManifest": .dictionary([
                    "UIApplicationSupportsMultipleScenes": .boolean(false),
                ]),
            ]),
            sources: .sources,
            resources: .default,
            entitlements: .file(path: "SupportingFiles/ChungBazi.entitlements"),
            dependencies: [
                .presentation(),
                .data(),
                .domain(),
                .design(),
                .core(),
            ],
            settings: .settings(
                configurations: [
                    .debug(name: "Debug", xcconfig: .relativeToRoot("Projects/ChungBazi/Configurations/Debug.xcconfig")),
                    .release(name: "Release", xcconfig: .relativeToRoot("Projects/ChungBazi/Configurations/Release.xcconfig")),
                ]
            )
        ),
    ],
    schemes: [
        .scheme(
            name: BaziModule.ChungBazi.name,
            buildAction: .buildAction(targets: [.target(BaziModule.ChungBazi.name)]),
            runAction: .runAction(executable: .target(BaziModule.ChungBazi.name))
        ),
    ]
)

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
                "BASE_URL": .string("$(BASE_URL)"),
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
                .external(.ComposableArchitecture),
            ],
            // CODE_SIGN_IDENTITY는 팀/개발자마다 다른 인증서 이름을 쓸 수 있어서 소스에 고정하지 않고
            // 각자의 xcconfig(Debug/Release.xcconfig, setup.sh가 생성)에서 값을 채우도록 한다.
            settings: .settings(
                configurations: [
                    .debug(
                        name: "Debug",
                        settings: [
                            "CODE_SIGN_IDENTITY": "$(CODE_SIGN_IDENTITY)",
                        ],
                        xcconfig: .relativeToRoot("Projects/ChungBazi/Configurations/Debug.xcconfig")
                    ),
                    .release(
                        name: "Release",
                        settings: [
                            "CODE_SIGN_IDENTITY": "$(CODE_SIGN_IDENTITY)",
                        ],
                        xcconfig: .relativeToRoot("Projects/ChungBazi/Configurations/Release.xcconfig")
                    ),
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
    ],
    additionalFiles: [
        .glob(pattern: "Configurations/**"),
    ]
)

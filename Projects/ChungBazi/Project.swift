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
            // CODE_SIGN_IDENTITY는 match가 발급한 팀 공유 인증서 이름을 정확히 명시한 것.
            // 비워두면 서명이 스킵되고, 이름을 애매하게 두면 로컬의 다른 인증서와 충돌한다.
            settings: .settings(
                configurations: [
                    .debug(
                        name: "Debug",
                        settings: [
                            "CODE_SIGN_IDENTITY": "Apple Development: Created via API (K7YX95Y9ZU)",
                        ],
                        xcconfig: .relativeToRoot("Projects/ChungBazi/Configurations/Debug.xcconfig")
                    ),
                    .release(
                        name: "Release",
                        settings: [
                            "CODE_SIGN_IDENTITY": "Apple Distribution: Hyeonju Lee (UKY6HK6U6Y)",
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

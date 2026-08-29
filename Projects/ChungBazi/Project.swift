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
                "KAKAO_NATIVE_APP_KEY": .string("$(KAKAO_NATIVE_APP_KEY)"),
                // 앱 표시 이름 / 마케팅 버전
                "CFBundleDisplayName": .string("청바지"),
                "CFBundleName": .string("청바지"),
                "CFBundleShortVersionString": .string("2.0.0"),
                "UILaunchScreen": .dictionary([:]),
                "UISupportedInterfaceOrientations": .array([.string("UIInterfaceOrientationPortrait")]),
                "UIApplicationSceneManifest": .dictionary([
                    "UIApplicationSupportsMultipleScenes": .boolean(false),
                ]),
                "UIBackgroundModes": .array([.string("remote-notification")]),
                "NSCalendarsWriteOnlyAccessUsageDescription": .string("찜한 정책의 마감일을 기기 캘린더에 추가하기 위해 캘린더 접근이 필요해요."),
                "CFBundleURLTypes": .array([
                    .dictionary([
                        "CFBundleURLSchemes": .array([.string("kakao$(KAKAO_NATIVE_APP_KEY)")]),
                    ]),
                    // 캘린더 이벤트/앱 딥링크용 커스텀 스킴(chungbazi://policy/{id}).
                    .dictionary([
                        "CFBundleURLName": .string("\(Project.bundleID).deeplink"),
                        "CFBundleURLSchemes": .array([.string("chungbazi")]),
                    ]),
                ]),
                "LSApplicationQueriesSchemes": .array([
                    .string("kakaokompassauth"),
                    .string("kakaolink"),
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
                .external(.KakaoSDKCommon),
                .external(.KakaoSDKAuth),
                .external(.FirebaseCore),
                .external(.FirebaseMessaging),
            ],
            // CODE_SIGN_IDENTITY는 팀/개발자마다 다른 인증서 이름을 쓸 수 있어서 소스에 고정하지 않고
            // 각자의 xcconfig(Debug/Release.xcconfig, setup.sh가 생성)에서 값을 채우도록 한다.
            settings: .settings(
                configurations: [
                    .debug(
                        name: "Debug",
                        settings: [
                            "CODE_SIGN_IDENTITY": "$(CODE_SIGN_IDENTITY)",
                            // Firebase/GoogleUtilities가 카테고리(NSData+gul_dataByGzippingData 등)로 추가하는
                            // 메서드는 -ObjC 없이 정적 링크하면 런타임에 unrecognized selector로 죽는다.
                            "OTHER_LDFLAGS": ["$(inherited)", "-ObjC"],
                        ],
                        xcconfig: .relativeToRoot("Projects/ChungBazi/Configurations/Debug.xcconfig")
                    ),
                    .release(
                        name: "Release",
                        settings: [
                            "CODE_SIGN_IDENTITY": "$(CODE_SIGN_IDENTITY)",
                            "OTHER_LDFLAGS": ["$(inherited)", "-ObjC"],
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

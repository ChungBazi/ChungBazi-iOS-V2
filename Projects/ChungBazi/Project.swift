import ProjectDescription
import ProjectDescriptionHelpers

/// 마케팅 버전. Xcode Cloud에서는 릴리즈 태그가 주입된다.
let marketingVersion = Environment.marketingVersion.getString(default: "2.0.2")

/// 빌드 번호. Xcode Cloud에서는 `CI_BUILD_NUMBER`가 주입된다.
let buildNumber = Environment.buildNumber.getString(default: "1")

let project = Project.project(
    name: BaziModule.ChungBazi.name,
    targets: [
        .target(
            name: BaziModule.ChungBazi.name,
            product: .app,
            // Debug는 별도 앱(.dev)으로 설치되어 스토어 앱과 Keychain·UserDefaults가 격리된다.
            bundleId: "\(Project.bundleID)$(BUNDLE_ID_SUFFIX)",
            infoPlist: .extendingDefault(with: [
                "BASE_URL": .string("$(BASE_URL)"),
                "KAKAO_NATIVE_APP_KEY": .string("$(KAKAO_NATIVE_APP_KEY)"),
                "AMPLITUDE_API_KEY": .string("$(AMPLITUDE_API_KEY)"),
                "APP_URL_SCHEME": .string("$(APP_URL_SCHEME)"),
                // 앱 기본 언어(한국어) — VoiceOver가 한글 라벨/텍스트를 한국어 음성으로 읽도록 기본 지역을 명시한다.
                "CFBundleDevelopmentRegion": .string("ko"),
                "CFBundleLocalizations": .array([.string("ko")]),
                // 앱 표시 이름 / 마케팅 버전
                "CFBundleDisplayName": .string("$(APP_DISPLAY_NAME)"),
                "CFBundleName": .string("$(APP_DISPLAY_NAME)"),
                "CFBundleShortVersionString": .string(marketingVersion),
                "CFBundleVersion": .string(buildNumber),
                "ITSAppUsesNonExemptEncryption": .boolean(false),
                // 다크모드 미지원 — 시스템 설정과 무관하게 앱 전체를 라이트모드로 고정한다.
                "UIUserInterfaceStyle": .string("Light"),
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
                    // 캘린더 이벤트/앱 딥링크용 커스텀 스킴({앱 스킴}://policy/{id}).
                    .dictionary([
                        "CFBundleURLName": .string("$(PRODUCT_BUNDLE_IDENTIFIER).deeplink"),
                        "CFBundleURLSchemes": .array([.string("$(APP_URL_SCHEME)")]),
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
            scripts: [
                // 빌드 구성에 맞는 GoogleService-Info.plist를 앱 번들에 복사한다(Debug: dev, Release: 운영).
                // Crashlytics 스크립트가 번들의 plist를 읽으므로 그보다 먼저 실행한다.
                .post(
                    script: """
                    SOURCE="${SRCROOT}/Configurations/Firebase/${CONFIGURATION}/GoogleService-Info.plist"
                    if [ ! -f "$SOURCE" ]; then
                      echo "error: $SOURCE 가 없습니다 (docs/ENVIRONMENT_GUIDELINES.md 참고)"; exit 1
                    fi
                    cp "$SOURCE" "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/GoogleService-Info.plist"
                    """,
                    name: "Copy GoogleService-Info.plist",
                    basedOnDependencyAnalysis: false
                ),
                // Crashlytics 심볼리케이션: 빌드 후 dSYM 업로드. 후보 경로를 탐색하며,
                // Debug는 실패해도 경고만, Release는 심볼리케이션 누락 방지를 위해 실패 시 빌드를 실패시킨다.
                .post(
                    script: """
                    RUN_SCRIPT=""
                    CANDIDATE_A="${BUILD_DIR%/Build/*}/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/run"
                    CANDIDATE_B="${SRCROOT}/../../Tuist/.build/checkouts/firebase-ios-sdk/Crashlytics/run"
                    if [ -f "$CANDIDATE_A" ]; then RUN_SCRIPT="$CANDIDATE_A"; fi
                    if [ -z "$RUN_SCRIPT" ] && [ -f "$CANDIDATE_B" ]; then RUN_SCRIPT="$CANDIDATE_B"; fi
                    if [ -n "$RUN_SCRIPT" ]; then
                      if ! "$RUN_SCRIPT"; then
                        if [ "$CONFIGURATION" = "Release" ]; then
                          echo "error: Crashlytics dSYM 업로드 실패 (Release는 심볼리케이션 누락을 허용하지 않음)"; exit 1
                        fi
                        echo "warning: Crashlytics dSYM 업로드 실패(무시)"
                      fi
                    elif [ "$CONFIGURATION" = "Release" ]; then
                      echo "error: Crashlytics run 스크립트를 찾지 못했습니다 (Release)"; exit 1
                    else
                      echo "warning: Crashlytics run 스크립트를 찾지 못해 dSYM 업로드를 건너뜁니다"
                    fi
                    """,
                    name: "Crashlytics Upload Symbols",
                    inputPaths: [
                        "$(DWARF_DSYM_FOLDER_PATH)/$(DWARF_DSYM_FILE_NAME)",
                        "$(BUILT_PRODUCTS_DIR)/$(INFOPLIST_PATH)",
                    ],
                    basedOnDependencyAnalysis: false
                ),
            ],
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
                .external(.FirebaseCrashlytics),
                .external(.FirebaseRemoteConfig),
                .external(.AmplitudeSwift),
            ],
            // CODE_SIGN_IDENTITY는 팀/개발자마다 다른 인증서 이름을 쓸 수 있어서 소스에 고정하지 않고
            // 각자의 xcconfig(Debug/Release.xcconfig, setup.sh가 생성)에서 값을 채우도록 한다.
            settings: .settings(
                configurations: [
                    .debug(
                        name: "Debug",
                        settings: [
                            "BUNDLE_ID_SUFFIX": ".dev",
                            "APP_DISPLAY_NAME": "청바지 Dev",
                            "APP_URL_SCHEME": "chungbazi-dev",
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
                            "BUNDLE_ID_SUFFIX": "",
                            "APP_DISPLAY_NAME": "청바지",
                            "APP_URL_SCHEME": "chungbazi",
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

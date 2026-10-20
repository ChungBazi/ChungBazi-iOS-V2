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
                .external(.KakaoSDKCommon),
                .external(.KakaoSDKAuth),
                .external(.KakaoSDKUser),
                .external(.KakaoSDKShare),
                .external(.KakaoSDKTemplate),
                .external(.FirebaseMessaging),
                .external(.FirebaseRemoteConfig),
            ]
        ),
        .tests(
            name: BaziModule.BaziData.name,
            dependencies: [
                .target(name: BaziModule.BaziData.name),
                .domain(),
            ]
        ),
    ]
)

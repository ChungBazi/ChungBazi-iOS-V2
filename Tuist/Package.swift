// swift-tools-version: 6.0
import PackageDescription

#if TUIST
import ProjectDescription
import ProjectDescriptionHelpers

let packageSettings = PackageSettings(
    productTypes: [:]
)
#endif

let package = Package(
    name: "ChungBazi",
    dependencies: [
        .package(url: "https://github.com/Moya/Moya.git", exact: "15.0.3"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "1.26.0"),
        .package(url: "https://github.com/kakao/kakao-ios-sdk.git", exact: "2.28.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", exact: "12.17.0"),
    ]
)

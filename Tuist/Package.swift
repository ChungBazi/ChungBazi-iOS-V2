// swift-tools-version: 5.9
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
    ]
)

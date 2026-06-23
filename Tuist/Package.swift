// swift-tools-version: 5.9
import PackageDescription

#if TUIST
import ProjectDescription
import ProjectDescriptionHelpers

let packageSettings = PackageSettings(
    productTypes: [
        // "SomeLibrary": .staticFramework,
    ]
)
#endif

let package = Package(
    name: "ChungBazi",
    dependencies: [
        // .package(url: "https://github.com/example/example", from: "1.0.0"),
    ]
)

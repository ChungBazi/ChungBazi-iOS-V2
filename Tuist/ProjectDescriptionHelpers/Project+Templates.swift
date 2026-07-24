import ProjectDescription

// MARK: - Global Config

extension Project {
    public static let bundleID = "com.yeonho.chungbazi"
    public static let iOSVersion = "17.0"
    public static let product: Product = .staticFramework
}

// MARK: - Project Factory

extension Project {
    public static let swiftVersionSettings: SettingsDictionary = [
        "SWIFT_VERSION": "6.0",
        // TCA @Reducer enum(Path/Destination)이 CaseReducerState 합성 시 MainActor 격리와
        // 충돌하는 알려진 문제(pointfreeco/swift-composable-architecture#3768)가 있어 명시적으로 고정.
        "SWIFT_DEFAULT_ACTOR_ISOLATION": "nonisolated",
    ]

    public static func project(
        name: String,
        targets: [Target] = [],
        schemes: [Scheme] = [],
        additionalFiles: [FileElement] = []
    ) -> Project {
        Project(
            name: name,
            settings: .settings(base: swiftVersionSettings),
            targets: targets,
            schemes: schemes,
            additionalFiles: additionalFiles
        )
    }
}

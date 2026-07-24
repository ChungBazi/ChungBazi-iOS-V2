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

import ProjectDescription

// MARK: - Global Config

extension Project {
    public static let bundleID = "com.yeonho.chungbazi"
    public static let iOSVersion = "16.0"
    public static let product: Product = .staticFramework
}

// MARK: - Project Factory

extension Project {
    public static func project(
        name: String,
        targets: [Target] = [],
        schemes: [Scheme] = [],
        additionalFiles: [FileElement] = []
    ) -> Project {
        Project(
            name: name,
            targets: targets,
            schemes: schemes,
            additionalFiles: additionalFiles
        )
    }
}

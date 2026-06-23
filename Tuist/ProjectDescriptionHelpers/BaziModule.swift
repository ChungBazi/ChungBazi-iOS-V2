import ProjectDescription

// MARK: - BaziModule

public enum BaziModule: String, CaseIterable {
    case ChungBazi
    case BaziPresentation
    case BaziDomain
    case BaziData
    case BaziNetwork
    case BaziStorage
    case BaziDesign
    case BaziCore
}

// MARK: - Module Properties

public extension BaziModule {

    var name: String { rawValue }

    var bundleId: String {
        Project.bundleID + "." + rawValue.lowercased()
    }

    var path: ProjectDescription.Path {
        .relativeToRoot("Projects/\(rawValue)")
    }

    var dependency: TargetDependency {
        .project(target: rawValue, path: path)
    }
}

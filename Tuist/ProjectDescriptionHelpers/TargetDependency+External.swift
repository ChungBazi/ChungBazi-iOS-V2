import ProjectDescription

public enum External: String {
    case Moya
}

extension TargetDependency {
    public static func external(_ dependency: External) -> TargetDependency {
        .external(name: dependency.rawValue)
    }
}

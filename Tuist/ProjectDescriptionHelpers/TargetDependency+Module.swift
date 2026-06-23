import ProjectDescription

// MARK: - Core

extension TargetDependency {
    public static func core() -> TargetDependency {
        BaziModule.BaziCore.dependency
    }
}

// MARK: - Design

extension TargetDependency {
    public static func design() -> TargetDependency {
        BaziModule.BaziDesign.dependency
    }
}

// MARK: - Network

extension TargetDependency {
    public static func network() -> TargetDependency {
        BaziModule.BaziNetwork.dependency
    }
}

// MARK: - Storage

extension TargetDependency {
    public static func storage() -> TargetDependency {
        BaziModule.BaziStorage.dependency
    }
}

// MARK: - Data

extension TargetDependency {
    public static func data() -> TargetDependency {
        BaziModule.BaziData.dependency
    }
}

// MARK: - Domain

extension TargetDependency {
    public static func domain() -> TargetDependency {
        BaziModule.BaziDomain.dependency
    }
}

// MARK: - Presentation

extension TargetDependency {
    public static func presentation() -> TargetDependency {
        BaziModule.BaziPresentation.dependency
    }
}

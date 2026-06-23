import ProjectDescription
import ProjectDescriptionHelpers

let workspace = Workspace(
    name: "ChungBazi",
    projects: BaziModule.allCases.map {
        .relativeToRoot("Projects/\($0.rawValue)")
    },
    fileHeaderTemplate: "Copyright © 2026 ChungBazi. All rights reserved"
)

// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// "x.y.z" 시맨틱 버전 비교. 자릿수가 다르면 0으로 패딩해 비교한다.
/// 형식이 잘못되면(`init?`) nil을 반환한다.
public struct SemanticVersion: Comparable, Sendable {

    public let components: [Int]

    public init?(_ string: String) {
        let parts = string.split(separator: ".", omittingEmptySubsequences: false).map { Int($0) }
        guard !parts.isEmpty, parts.allSatisfy({ $0 != nil }) else { return nil }
        self.components = parts.compactMap { $0 }
    }

    public static func < (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        let count = max(lhs.components.count, rhs.components.count)
        for index in 0..<count {
            let left = index < lhs.components.count ? lhs.components[index] : 0
            let right = index < rhs.components.count ? rhs.components[index] : 0
            if left != right { return left < right }
        }
        return false
    }
}

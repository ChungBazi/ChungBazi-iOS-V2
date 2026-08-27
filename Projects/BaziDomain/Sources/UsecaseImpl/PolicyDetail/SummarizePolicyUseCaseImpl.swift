// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct SummarizePolicyUseCaseImpl: SummarizePolicyUseCase {

    private let summarizer: PolicySummarizer

    public init(summarizer: PolicySummarizer) {
        self.summarizer = summarizer
    }

    public func isAvailable() -> Bool {
        summarizer.isAvailable()
    }

    public func summarize(_ supportContent: String) async -> String? {
        await summarizer.summarize(supportContent)
    }
}

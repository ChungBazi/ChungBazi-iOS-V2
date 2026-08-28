// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziDomain

#if canImport(FoundationModels)
import FoundationModels
#endif

/// Apple Intelligence 온디바이스 모델(FoundationModels) 기반 요약기.
/// iOS 26+ & Apple Intelligence 지원 기기에서만 동작하고, 그 외/실패 시 nil을 반환한다.
public struct DefaultPolicySummarizer: PolicySummarizer {

    public init() {}

    public func isAvailable() -> Bool {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            if case .available = SystemLanguageModel.default.availability { return true }
        }
        return false
        #else
        return false
        #endif
    }

    public func summarize(_ text: String) async -> String? {
        #if canImport(FoundationModels)
        guard #available(iOS 26.0, *) else { return nil }
        return await Self.summarizeWithFoundationModels(text)
        #else
        return nil
        #endif
    }
}

#if canImport(FoundationModels)
extension DefaultPolicySummarizer {

    @available(iOS 26.0, *)
    private static func summarizeWithFoundationModels(_ text: String) async -> String? {
        let model = SystemLanguageModel.default
        guard case .available = model.availability else { return nil }

        let instructions = """
        당신은 청년 정책을 쉽게 풀어 설명하는 요약 도우미예요.
        주어진 '지원 내용'을 읽고, 사용자가 한눈에 이해하도록 핵심만 자연스럽게 요약해요.

        규칙:
        - 공백 포함 300자를 넘기지 않아요.
        - 모든 문장을 '해요체'로 끝맺어요. (예: ~해요, ~있어요, ~돼요)
        - 어떤 정책인지, 누구에게, 어떤 혜택을 주는지를 중심으로 정리해요.
        - '지원 금액'·'지원 기간'·'신청 방법'처럼 항목이 있어도 값이 '없음'·'미정'·'해당 없음'이면 그 항목은 언급하지 않아요.
        - 원문에 없는 내용은 지어내지 않고, 불확실하면 생략해요.
        - 항목 이름(지원 대상, 지원 내용 등)이나 불릿을 그대로 나열하지 말고, 이어지는 문장으로 풀어써요.
        - 마크다운·불릿·이모지·머리말 없이 자연스러운 문단으로만 써요.
        - "요약하면", "이 정책은" 같은 군더더기 없이 요약 내용만 출력해요.
        """

        let session = LanguageModelSession(instructions: instructions)
        do {
            let response = try await session.respond(to: "다음 지원 내용을 요약해줘.\n\n\(text)")
            let cleaned = Self.stripMarkdownEscapes(response.content)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            // 공백만 남으면 요약 실패로 간주 → 뒷면은 원문(supportContent) fallback
            return cleaned.isEmpty ? nil : cleaned
        } catch {
            return nil
        }
    }

    /// 모델이 마크다운 특수문자를 이스케이프(\~, \*, \. 등)해 내보내는 것을 평문으로 되돌린다.
    /// (요약을 마크다운이 아닌 평문 Text로 렌더링하므로 백슬래시가 그대로 보이는 문제 방지)
    static func stripMarkdownEscapes(_ text: String) -> String {
        text.replacingOccurrences(
            of: #"\\([^A-Za-z0-9\s])"#,
            with: "$1",
            options: .regularExpression
        )
    }
}
#endif

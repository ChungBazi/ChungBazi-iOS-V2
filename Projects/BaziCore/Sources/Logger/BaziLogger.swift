// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation
import OSLog

/// OSLog `category` 값. Console.app 필터링 축으로 쓰인다.
public enum LogCategory: String, Sendable {
    case general    // 분류 안 되는 일반 로그
    case network    // API 요청 / 응답
    case auth       // 로그인, 토큰 갱신, 강제 로그아웃
    case storage    // Keychain, UserDefaults 읽기/쓰기
    case ui         // Reducer / Store 상태, Action
    case lifecycle  // 앱 시작, 백그라운드, 포그라운드
}

/// 앱 전역 로거의 네임스페이스 프로토콜.
///
/// enum 하나를 conform 시켜 로거를 만든다. 대부분은 BaziCore 가 제공하는 ``Log`` 를 그대로 쓴다.
///
/// ```swift
/// import BaziCore
///
/// Log.debug("홈 데이터 로드 완료")
/// Log.error("토큰 갱신 실패", category: .auth)
/// // 콘솔: 🔴 [HomeFeature.swift:42] reduce(into:action:) - 토큰 갱신 실패
/// ```
///
/// ## 모듈 전용 로거
///
/// 특정 모듈을 별도 subsystem 으로 분리하려면 한 줄이면 된다.
///
/// ```swift
/// enum Log: BaziLogger { static let subsystem = "com.yeonho.chungbazi.network" }
/// ```
///
/// ## 실행 시간 측정
///
/// ```swift
/// let policies = try await Log.measure("홈 정책 조회") {
///     try await homePoliciesUseCase.execute()
/// }
/// // ⏱ [HomeFeature.swift:88] reduce(into:action:) - 홈 정책 조회 - 12.34ms
/// ```
///
/// ## 레벨과 빌드
///
/// - `debug` / `info` / `warn`: Debug 빌드 전용. Release 에선 no-op(문자열 평가조차 안 함).
/// - `error` / `critical`: 항상 기록. Release 에선 메시지를 해시 마스킹한다.
///
/// - Important: 토큰 값 자체를 메시지에 넣지 말 것. Release 마스킹은 최후 방어선일 뿐이다.
public protocol BaziLogger {
    static var subsystem: String { get }
    static var defaultCategory: LogCategory { get }
}

public extension BaziLogger {
    static var defaultCategory: LogCategory { .general }
}

// MARK: - Level Methods

public extension BaziLogger {
    /// 상세 디버그 로그. Debug 빌드 전용.
    static func debug(_ message: @autoclosure () -> String, category: LogCategory? = nil,
                      file: String = #fileID, function: String = #function, line: Int = #line) {
        #if DEBUG
        emit(.debug, "⚪️", message(), category ?? defaultCategory, file, function, line)
        #endif
    }

    /// 일반 정보 로그. Debug 빌드 전용.
    static func info(_ message: @autoclosure () -> String, category: LogCategory? = nil,
                     file: String = #fileID, function: String = #function, line: Int = #line) {
        #if DEBUG
        emit(.info, "🔵", message(), category ?? defaultCategory, file, function, line)
        #endif
    }

    /// 경고 로그. Debug 빌드 전용.
    static func warn(_ message: @autoclosure () -> String, category: LogCategory? = nil,
                     file: String = #fileID, function: String = #function, line: Int = #line) {
        #if DEBUG
        emit(.default, "🟡", message(), category ?? defaultCategory, file, function, line)
        #endif
    }

    /// 에러 로그. 항상 기록되며 Release 에선 마스킹된다.
    static func error(_ message: @autoclosure () -> String, category: LogCategory? = nil,
                      file: String = #fileID, function: String = #function, line: Int = #line) {
        emit(.error, "🔴", message(), category ?? defaultCategory, file, function, line)
    }

    /// 치명적 에러 로그. 항상 기록되며 Release 에선 마스킹된다.
    static func critical(_ message: @autoclosure () -> String, category: LogCategory? = nil,
                         file: String = #fileID, function: String = #function, line: Int = #line) {
        emit(.fault, "🟣", message(), category ?? defaultCategory, file, function, line)
    }
}

// MARK: - Measure

public extension BaziLogger {
    /// 동기 블록의 실행 시간을 `⏱ … - 12.34ms` 로 로깅한다. Release 에선 측정 없이 실행만 한다.
    @discardableResult
    static func measure<T>(_ label: String, category: LogCategory? = nil,
                           file: String = #fileID, function: String = #function, line: Int = #line,
                           _ work: () throws -> T) rethrows -> T {
        #if DEBUG
        let start = ContinuousClock().now
        defer {
            let ms = start.duration(to: ContinuousClock().now).milliseconds
            emit(.debug, "⏱", "\(label) - \(String(format: "%.2f", ms))ms",
                 category ?? defaultCategory, file, function, line)
        }
        #endif
        return try work()
    }

    /// `measure` 의 async 버전.
    @discardableResult
    static func measure<T>(_ label: String, category: LogCategory? = nil,
                           file: String = #fileID, function: String = #function, line: Int = #line,
                           _ work: () async throws -> T) async rethrows -> T {
        #if DEBUG
        let start = ContinuousClock().now
        defer {
            let ms = start.duration(to: ContinuousClock().now).milliseconds
            emit(.debug, "⏱", "\(label) - \(String(format: "%.2f", ms))ms",
                 category ?? defaultCategory, file, function, line)
        }
        #endif
        return try await work()
    }
}

// MARK: - Pipeline

private extension BaziLogger {
    static func emit(_ type: OSLogType, _ symbol: String, _ message: @autoclosure () -> String,
                     _ category: LogCategory, _ file: String, _ function: String, _ line: Int) {
        let fileName = (file as NSString).lastPathComponent
        let text = "\(symbol) [\(fileName):\(line)] \(function) - \(message())"
        let logger = Logger(subsystem: subsystem, category: category.rawValue)
        #if DEBUG
        logger.log(level: type, "\(text, privacy: .public)")
        #else
        logger.log(level: type, "\(text, privacy: .private(mask: .hash))")
        #endif
    }
}

private extension Duration {
    var milliseconds: Double {
        let c = components
        return Double(c.seconds) * 1_000 + Double(c.attoseconds) * 1e-15
    }
}

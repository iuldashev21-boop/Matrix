import Foundation
import os.log

/// Centralized error logging for the app
/// Logs to Console.app and stores recent errors for debugging
enum ErrorLogger {

    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "MatrixHabit", category: "Error")

    /// Recent errors stored in memory for debugging (last 50)
    private static var recentErrors: [(Date, String)] = []
    private static let maxStoredErrors = 50
    private static let lock = NSLock()

    // MARK: - Logging Methods

    /// Log a SwiftData save failure
    static func logSaveFailure(_ error: Error, context: String = "Unknown") {
        log(error, operation: "SwiftData Save", context: context)
    }

    /// Log a SwiftData fetch failure
    static func logFetchFailure(_ error: Error, context: String = "Unknown") {
        log(error, operation: "SwiftData Fetch", context: context)
    }

    /// Log a JSON encoding failure
    static func logEncodingFailure(_ error: Error, context: String = "Unknown") {
        log(error, operation: "JSON Encode", context: context)
    }

    /// Log a JSON decoding failure
    static func logDecodingFailure(_ error: Error, context: String = "Unknown") {
        log(error, operation: "JSON Decode", context: context)
    }

    /// General error logging
    static func log(_ error: Error, operation: String, context: String) {
        let message = "[\(operation)] \(context): \(error.localizedDescription)"

        // Log to system console (visible in Console.app)
        logger.error("\(message, privacy: .public)")

        // Store in memory for debugging
        lock.lock()
        recentErrors.append((Date(), message))
        if recentErrors.count > maxStoredErrors {
            recentErrors.removeFirst()
        }
        lock.unlock()

        #if DEBUG
        print("❌ ERROR: \(message)")
        #endif
    }

    // MARK: - Debug Helpers

    /// Get recent errors for debugging UI (if needed later)
    static func getRecentErrors() -> [(Date, String)] {
        lock.lock()
        defer { lock.unlock() }
        return recentErrors
    }

    /// Clear stored errors
    static func clearErrors() {
        lock.lock()
        recentErrors.removeAll()
        lock.unlock()
    }
}

// MARK: - Safe Operations

extension ErrorLogger {

    /// Safely perform a throwing operation with logging
    /// Returns nil on failure instead of crashing
    static func attempt<T>(_ operation: String, context: String = "", work: () throws -> T) -> T? {
        do {
            return try work()
        } catch {
            log(error, operation: operation, context: context)
            return nil
        }
    }

    /// Safely perform a throwing operation, returning a default value on failure
    static func attempt<T>(_ operation: String, context: String = "", default defaultValue: T, work: () throws -> T) -> T {
        do {
            return try work()
        } catch {
            log(error, operation: operation, context: context)
            return defaultValue
        }
    }
}

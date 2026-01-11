import Foundation
import SwiftData
@testable import MatrixHabit

// MARK: - Test Helpers

/// Creates an in-memory SwiftData container for testing
@MainActor
func makeTestContainer() throws -> ModelContainer {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    return try ModelContainer(
        for: Power.self, Agent.self, CheckIn.self, Achievement.self,
        configurations: config
    )
}

/// Helper to create CheckIn instances for testing
/// Uses dates relative to today for predictable test behavior
enum TestCheckInFactory {

    /// Creates a CheckIn for N days ago
    /// - Parameters:
    ///   - daysAgo: Number of days before today (0 = today)
    ///   - isSuccess: Whether the check-in was successful
    /// - Returns: A CheckIn instance
    static func checkIn(daysAgo: Int, isSuccess: Bool = true) -> CheckIn {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let date = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
        return CheckIn(date: date, isSuccess: isSuccess)
    }

    /// Creates a series of consecutive successful check-ins
    /// - Parameters:
    ///   - count: Number of check-ins to create
    ///   - startingDaysAgo: First check-in's days ago (default 0 = today)
    /// - Returns: Array of CheckIn instances
    static func consecutiveStreak(count: Int, startingDaysAgo: Int = 0) -> [CheckIn] {
        return (0..<count).map { offset in
            checkIn(daysAgo: startingDaysAgo + offset, isSuccess: true)
        }
    }

    /// Creates a streak with a gap
    /// - Parameters:
    ///   - beforeGap: Days of streak before the gap
    ///   - gapDays: Number of missed days
    ///   - afterGap: Days of streak after the gap
    /// - Returns: Array of CheckIn instances with a gap
    static func streakWithGap(beforeGap: Int, gapDays: Int, afterGap: Int) -> [CheckIn] {
        var checkIns: [CheckIn] = []

        // Recent streak (before gap, starting from today)
        for i in 0..<beforeGap {
            checkIns.append(checkIn(daysAgo: i, isSuccess: true))
        }

        // Older streak (after gap)
        let olderStart = beforeGap + gapDays
        for i in 0..<afterGap {
            checkIns.append(checkIn(daysAgo: olderStart + i, isSuccess: true))
        }

        return checkIns
    }
}

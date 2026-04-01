import XCTest
@testable import MatrixHabit

final class StreakCalculatorTests: XCTestCase {

    // MARK: - calculateStreak Tests

    func test_calculateStreak_withNoCheckIns_returnsZero() {
        let checkIns: [CheckIn] = []

        let streak = StreakCalculator.calculateStreak(for: checkIns)

        XCTAssertEqual(streak, 0)
    }

    func test_calculateStreak_withOnlyFailedCheckIns_returnsZero() {
        let checkIns = [
            TestCheckInFactory.checkIn(daysAgo: 0, isSuccess: false),
            TestCheckInFactory.checkIn(daysAgo: 1, isSuccess: false),
        ]

        let streak = StreakCalculator.calculateStreak(for: checkIns)

        XCTAssertEqual(streak, 0)
    }

    func test_calculateStreak_withTodayOnly_returnsOne() {
        let checkIns = [
            TestCheckInFactory.checkIn(daysAgo: 0, isSuccess: true)
        ]

        let streak = StreakCalculator.calculateStreak(for: checkIns)

        XCTAssertEqual(streak, 1)
    }

    func test_calculateStreak_withYesterdayOnly_returnsOne() {
        let checkIns = [
            TestCheckInFactory.checkIn(daysAgo: 1, isSuccess: true)
        ]

        let streak = StreakCalculator.calculateStreak(for: checkIns)

        XCTAssertEqual(streak, 1)
    }

    func test_calculateStreak_withTwoDaysAgo_returnsZero() {
        // Streak is broken if most recent check-in is more than 1 day ago
        let checkIns = [
            TestCheckInFactory.checkIn(daysAgo: 2, isSuccess: true)
        ]

        let streak = StreakCalculator.calculateStreak(for: checkIns)

        XCTAssertEqual(streak, 0)
    }

    func test_calculateStreak_withConsecutiveDays_returnsCorrectCount() {
        let checkIns = TestCheckInFactory.consecutiveStreak(count: 7, startingDaysAgo: 0)

        let streak = StreakCalculator.calculateStreak(for: checkIns)

        XCTAssertEqual(streak, 7)
    }

    func test_calculateStreak_startingFromYesterday_returnsCorrectCount() {
        // User hasn't checked in today yet, but has 5 consecutive days ending yesterday
        let checkIns = TestCheckInFactory.consecutiveStreak(count: 5, startingDaysAgo: 1)

        let streak = StreakCalculator.calculateStreak(for: checkIns)

        XCTAssertEqual(streak, 5)
    }

    func test_calculateStreak_withGap_returnsOnlyRecentStreak() {
        // 3 days recent, 2 day gap, 5 days old
        let checkIns = TestCheckInFactory.streakWithGap(beforeGap: 3, gapDays: 2, afterGap: 5)

        let streak = StreakCalculator.calculateStreak(for: checkIns)

        XCTAssertEqual(streak, 3, "Should only count the recent streak, not include days after the gap")
    }

    func test_calculateStreak_withMixedSuccessFailure_onlyCountsSuccess() {
        let checkIns = [
            TestCheckInFactory.checkIn(daysAgo: 0, isSuccess: true),
            TestCheckInFactory.checkIn(daysAgo: 1, isSuccess: false), // This breaks the streak
            TestCheckInFactory.checkIn(daysAgo: 2, isSuccess: true),
        ]

        let streak = StreakCalculator.calculateStreak(for: checkIns)

        XCTAssertEqual(streak, 1, "Failed day should break the streak")
    }

    func test_calculateStreak_with66Days_returnsFullProtocol() {
        let checkIns = TestCheckInFactory.consecutiveStreak(count: 66, startingDaysAgo: 0)

        let streak = StreakCalculator.calculateStreak(for: checkIns)

        XCTAssertEqual(streak, 66, "Should handle full 66-day protocol")
    }

    // MARK: - calculateLongestStreak Tests

    func test_calculateLongestStreak_withNoCheckIns_returnsZero() {
        let checkIns: [CheckIn] = []

        let longest = StreakCalculator.calculateLongestStreak(for: checkIns)

        XCTAssertEqual(longest, 0)
    }

    func test_calculateLongestStreak_withSingleCheckIn_returnsOne() {
        let checkIns = [
            TestCheckInFactory.checkIn(daysAgo: 5, isSuccess: true)
        ]

        let longest = StreakCalculator.calculateLongestStreak(for: checkIns)

        XCTAssertEqual(longest, 1)
    }

    func test_calculateLongestStreak_findsLongestNotCurrent() {
        // Current streak: 3 days, but had a 10-day streak before
        var checkIns: [CheckIn] = []

        // Old 10-day streak (20-11 days ago)
        for i in 11...20 {
            checkIns.append(TestCheckInFactory.checkIn(daysAgo: i, isSuccess: true))
        }

        // Gap of 8 days (3-10 days ago)

        // Current 3-day streak (0-2 days ago)
        for i in 0...2 {
            checkIns.append(TestCheckInFactory.checkIn(daysAgo: i, isSuccess: true))
        }

        let longest = StreakCalculator.calculateLongestStreak(for: checkIns)

        XCTAssertEqual(longest, 10, "Should find the longest historical streak")
    }

    func test_calculateLongestStreak_ignoresFailedCheckIns() {
        let checkIns = [
            TestCheckInFactory.checkIn(daysAgo: 0, isSuccess: true),
            TestCheckInFactory.checkIn(daysAgo: 1, isSuccess: true),
            TestCheckInFactory.checkIn(daysAgo: 2, isSuccess: false),
            TestCheckInFactory.checkIn(daysAgo: 3, isSuccess: true),
            TestCheckInFactory.checkIn(daysAgo: 4, isSuccess: true),
            TestCheckInFactory.checkIn(daysAgo: 5, isSuccess: true),
        ]

        let longest = StreakCalculator.calculateLongestStreak(for: checkIns)

        XCTAssertEqual(longest, 3, "Longest consecutive success streak is 3 days (days 3-5)")
    }

    func test_calculateLongestStreak_handlesDuplicateDates() {
        // Multiple check-ins on same day should count as 1
        let checkIns = [
            TestCheckInFactory.checkIn(daysAgo: 0, isSuccess: true),
            TestCheckInFactory.checkIn(daysAgo: 0, isSuccess: true), // Duplicate
            TestCheckInFactory.checkIn(daysAgo: 1, isSuccess: true),
        ]

        let longest = StreakCalculator.calculateLongestStreak(for: checkIns)

        XCTAssertEqual(longest, 2, "Duplicate dates should not inflate streak")
    }

    // MARK: - calculateStreak Duplicate Dedup

    func test_calculateStreak_handlesDuplicateDates() {
        let checkIns = [
            TestCheckInFactory.checkIn(daysAgo: 0, isSuccess: true),
            TestCheckInFactory.checkIn(daysAgo: 0, isSuccess: true), // Duplicate
            TestCheckInFactory.checkIn(daysAgo: 1, isSuccess: true),
            TestCheckInFactory.checkIn(daysAgo: 1, isSuccess: true), // Duplicate
            TestCheckInFactory.checkIn(daysAgo: 2, isSuccess: true),
        ]

        let streak = StreakCalculator.calculateStreak(for: checkIns)

        XCTAssertEqual(streak, 3, "Duplicate dates should not inflate current streak")
    }
}

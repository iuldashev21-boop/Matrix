import XCTest
@testable import MatrixHabit

final class PowerModelTests: XCTestCase {

    // MARK: - Initialization Tests

    func test_init_setsDefaultValues() {
        let power = Power(name: "Test Power")

        XCTAssertEqual(power.name, "Test Power")
        XCTAssertEqual(power.icon, "bolt")
        XCTAssertEqual(power.targetDays, 66)
        XCTAssertFalse(power.isUnlocked)
        XCTAssertNil(power.unlockedAt)
        XCTAssertEqual(power.scheduledDays, [1, 2, 3, 4, 5, 6, 7])
        XCTAssertTrue(power.checkIns.isEmpty)
    }

    func test_init_withCustomIcon() {
        let power = Power(name: "Exercise", icon: "figure.run")

        XCTAssertEqual(power.icon, "figure.run")
    }

    func test_init_withCustomSchedule() {
        let power = Power(name: "Weekday Power", scheduledDays: [2, 3, 4, 5, 6])

        XCTAssertEqual(power.scheduledDays, [2, 3, 4, 5, 6])
    }

    // MARK: - isScheduledToday Tests

    func test_isScheduledToday_withAllDays_returnsTrue() {
        let power = Power(name: "Daily", scheduledDays: [1, 2, 3, 4, 5, 6, 7])

        XCTAssertTrue(power.isScheduledToday)
    }

    func test_isScheduledToday_withEmptySchedule_returnsTrue() {
        let power = Power(name: "Daily", scheduledDays: [])

        XCTAssertTrue(power.isScheduledToday)
    }

    // MARK: - isScheduled(on:) Tests

    func test_isScheduled_onScheduledDay_returnsTrue() {
        // Monday = weekday 2
        let power = Power(name: "Weekdays", scheduledDays: [2, 3, 4, 5, 6])
        let monday = createDate(weekday: 2)

        XCTAssertTrue(power.isScheduled(on: monday))
    }

    func test_isScheduled_onUnscheduledDay_returnsFalse() {
        // Sunday = weekday 1
        let power = Power(name: "Weekdays", scheduledDays: [2, 3, 4, 5, 6])
        let sunday = createDate(weekday: 1)

        XCTAssertFalse(power.isScheduled(on: sunday))
    }

    // MARK: - currentStreak Tests

    func test_currentStreak_withNoCheckIns_returnsZero() {
        let power = Power(name: "Test")

        XCTAssertEqual(power.currentStreak, 0)
    }

    func test_currentStreak_withTodayCheckIn_returnsOne() {
        let power = Power(name: "Test")
        power.checkIns = [TestCheckInFactory.checkIn(daysAgo: 0)]

        XCTAssertEqual(power.currentStreak, 1)
    }

    func test_currentStreak_withConsecutiveDays_returnsCorrectCount() {
        let power = Power(name: "Test")
        power.checkIns = TestCheckInFactory.consecutiveStreak(count: 5, startingDaysAgo: 0)

        XCTAssertEqual(power.currentStreak, 5)
    }

    // MARK: - longestStreak Tests

    func test_longestStreak_findsHistoricalMax() {
        let power = Power(name: "Test")
        // Old 10-day streak, then gap, then current 3-day streak
        var checkIns: [CheckIn] = []
        for i in 0...2 { checkIns.append(TestCheckInFactory.checkIn(daysAgo: i)) }
        for i in 11...20 { checkIns.append(TestCheckInFactory.checkIn(daysAgo: i)) }
        power.checkIns = checkIns

        XCTAssertEqual(power.longestStreak, 10)
    }

    // MARK: - completedToday Tests

    func test_completedToday_withNoCheckIns_returnsFalse() {
        let power = Power(name: "Test")

        XCTAssertFalse(power.completedToday)
    }

    func test_completedToday_withTodaySuccess_returnsTrue() {
        let power = Power(name: "Test")
        power.checkIns = [TestCheckInFactory.checkIn(daysAgo: 0, isSuccess: true)]

        XCTAssertTrue(power.completedToday)
    }

    func test_completedToday_withTodayFailure_returnsFalse() {
        let power = Power(name: "Test")
        power.checkIns = [TestCheckInFactory.checkIn(daysAgo: 0, isSuccess: false)]

        XCTAssertFalse(power.completedToday)
    }

    func test_completedToday_withYesterdayOnly_returnsFalse() {
        let power = Power(name: "Test")
        power.checkIns = [TestCheckInFactory.checkIn(daysAgo: 1, isSuccess: true)]

        XCTAssertFalse(power.completedToday)
    }

    // MARK: - progressPercent Tests

    func test_progressPercent_atZero_returnsZero() {
        let power = Power(name: "Test")

        XCTAssertEqual(power.progressPercent, 0)
    }

    func test_progressPercent_atHalfway_returnsFifty() {
        let power = Power(name: "Test")
        power.checkIns = TestCheckInFactory.consecutiveStreak(count: 33, startingDaysAgo: 0)

        XCTAssertEqual(power.progressPercent, 50, accuracy: 1)
    }

    func test_progressPercent_atComplete_returnsHundred() {
        let power = Power(name: "Test")
        power.checkIns = TestCheckInFactory.consecutiveStreak(count: 66, startingDaysAgo: 0)

        XCTAssertEqual(power.progressPercent, 100, accuracy: 0.1)
    }

    // MARK: - daysRemaining Tests

    func test_daysRemaining_atStart_returns66() {
        let power = Power(name: "Test")

        XCTAssertEqual(power.daysRemaining, 66)
    }

    func test_daysRemaining_atHalfway_returns33() {
        let power = Power(name: "Test")
        power.checkIns = TestCheckInFactory.consecutiveStreak(count: 33, startingDaysAgo: 0)

        XCTAssertEqual(power.daysRemaining, 33)
    }

    func test_daysRemaining_atComplete_returnsZero() {
        let power = Power(name: "Test")
        power.checkIns = TestCheckInFactory.consecutiveStreak(count: 66, startingDaysAgo: 0)

        XCTAssertEqual(power.daysRemaining, 0)
    }

    func test_daysRemaining_beyondTarget_returnsZero() {
        let power = Power(name: "Test")
        power.checkIns = TestCheckInFactory.consecutiveStreak(count: 100, startingDaysAgo: 0)

        XCTAssertEqual(power.daysRemaining, 0)
    }

    // MARK: - checkForUnlock Tests

    func test_checkForUnlock_belowTarget_doesNotUnlock() {
        let power = Power(name: "Test")
        power.checkIns = TestCheckInFactory.consecutiveStreak(count: 65, startingDaysAgo: 0)

        power.checkForUnlock()

        XCTAssertFalse(power.isUnlocked)
        XCTAssertNil(power.unlockedAt)
    }

    func test_checkForUnlock_atTarget_unlocks() {
        let power = Power(name: "Test")
        power.checkIns = TestCheckInFactory.consecutiveStreak(count: 66, startingDaysAgo: 0)

        power.checkForUnlock()

        XCTAssertTrue(power.isUnlocked)
        XCTAssertNotNil(power.unlockedAt)
    }

    func test_checkForUnlock_alreadyUnlocked_doesNotChangeDate() {
        let power = Power(name: "Test")
        power.checkIns = TestCheckInFactory.consecutiveStreak(count: 66, startingDaysAgo: 0)
        power.checkForUnlock()
        let originalDate = power.unlockedAt

        // Call again
        power.checkForUnlock()

        XCTAssertEqual(power.unlockedAt, originalDate)
    }

    // MARK: - needsRecovery Tests

    func test_needsRecovery_withNoHistory_returnsFalse() {
        let power = Power(name: "Test")

        XCTAssertFalse(power.needsRecovery)
    }

    func test_needsRecovery_completedToday_returnsFalse() {
        let power = Power(name: "Test")
        power.checkIns = TestCheckInFactory.consecutiveStreak(count: 5, startingDaysAgo: 0)

        XCTAssertFalse(power.needsRecovery)
    }

    func test_needsRecovery_missedYesterdayWithPriorStreak_returnsTrue() {
        let power = Power(name: "Test")
        // Has check-ins from 2+ days ago but not yesterday
        power.checkIns = [
            TestCheckInFactory.checkIn(daysAgo: 2, isSuccess: true),
            TestCheckInFactory.checkIn(daysAgo: 3, isSuccess: true)
        ]

        XCTAssertTrue(power.needsRecovery)
    }

    // MARK: - touch Tests

    func test_touch_updatesUpdatedAt() {
        let power = Power(name: "Test")
        // Set updatedAt to a known past date to avoid timing dependency
        power.updatedAt = Date.distantPast
        power.touch()

        XCTAssertGreaterThan(power.updatedAt, Date.distantPast)
    }

    // MARK: - Helpers

    private func createDate(weekday: Int) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        components.weekday = weekday
        return calendar.date(from: components) ?? Date()
    }
}

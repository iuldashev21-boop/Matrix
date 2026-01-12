import XCTest
@testable import MatrixHabit

final class AgentModelTests: XCTestCase {

    // MARK: - Initialization Tests

    func test_init_setsDefaultValues() {
        let agent = Agent(name: "Test Agent")

        XCTAssertEqual(agent.name, "Test Agent")
        XCTAssertEqual(agent.icon, "xmark.shield")
        XCTAssertEqual(agent.targetDays, 66)
        XCTAssertFalse(agent.isDefeated)
        XCTAssertNil(agent.defeatedAt)
        XCTAssertEqual(agent.scheduledDays, [1, 2, 3, 4, 5, 6, 7])
        XCTAssertTrue(agent.checkIns.isEmpty)
    }

    func test_init_withCustomIcon() {
        let agent = Agent(name: "Social Media", icon: "iphone")

        XCTAssertEqual(agent.icon, "iphone")
    }

    func test_init_withCustomSchedule() {
        let agent = Agent(name: "Weekend Agent", scheduledDays: [1, 7])

        XCTAssertEqual(agent.scheduledDays, [1, 7])
    }

    // MARK: - isScheduledToday Tests

    func test_isScheduledToday_withAllDays_returnsTrue() {
        let agent = Agent(name: "Daily", scheduledDays: [1, 2, 3, 4, 5, 6, 7])

        XCTAssertTrue(agent.isScheduledToday)
    }

    func test_isScheduledToday_withEmptySchedule_returnsTrue() {
        let agent = Agent(name: "Daily", scheduledDays: [])

        XCTAssertTrue(agent.isScheduledToday)
    }

    // MARK: - isScheduled(on:) Tests

    func test_isScheduled_onScheduledDay_returnsTrue() {
        let agent = Agent(name: "Weekend", scheduledDays: [1, 7])
        let sunday = createDate(weekday: 1)

        XCTAssertTrue(agent.isScheduled(on: sunday))
    }

    func test_isScheduled_onUnscheduledDay_returnsFalse() {
        let agent = Agent(name: "Weekend", scheduledDays: [1, 7])
        let wednesday = createDate(weekday: 4)

        XCTAssertFalse(agent.isScheduled(on: wednesday))
    }

    // MARK: - currentStreak Tests

    func test_currentStreak_withNoCheckIns_returnsZero() {
        let agent = Agent(name: "Test")

        XCTAssertEqual(agent.currentStreak, 0)
    }

    func test_currentStreak_withTodayResisted_returnsOne() {
        let agent = Agent(name: "Test")
        agent.checkIns = [TestCheckInFactory.checkIn(daysAgo: 0, isSuccess: true)]

        XCTAssertEqual(agent.currentStreak, 1)
    }

    func test_currentStreak_withConsecutiveResistance_returnsCorrectCount() {
        let agent = Agent(name: "Test")
        agent.checkIns = TestCheckInFactory.consecutiveStreak(count: 7, startingDaysAgo: 0)

        XCTAssertEqual(agent.currentStreak, 7)
    }

    // MARK: - longestStreak Tests

    func test_longestStreak_findsHistoricalMax() {
        let agent = Agent(name: "Test")
        var checkIns: [CheckIn] = []
        for i in 0...2 { checkIns.append(TestCheckInFactory.checkIn(daysAgo: i)) }
        for i in 11...25 { checkIns.append(TestCheckInFactory.checkIn(daysAgo: i)) }
        agent.checkIns = checkIns

        XCTAssertEqual(agent.longestStreak, 15)
    }

    // MARK: - resistedToday Tests

    func test_resistedToday_withNoCheckIns_returnsFalse() {
        let agent = Agent(name: "Test")

        XCTAssertFalse(agent.resistedToday)
    }

    func test_resistedToday_withTodaySuccess_returnsTrue() {
        let agent = Agent(name: "Test")
        agent.checkIns = [TestCheckInFactory.checkIn(daysAgo: 0, isSuccess: true)]

        XCTAssertTrue(agent.resistedToday)
    }

    func test_resistedToday_withTodayRelapse_returnsFalse() {
        let agent = Agent(name: "Test")
        agent.checkIns = [TestCheckInFactory.checkIn(daysAgo: 0, isSuccess: false)]

        XCTAssertFalse(agent.resistedToday)
    }

    // MARK: - relapsedToday Tests

    func test_relapsedToday_withNoCheckIns_returnsFalse() {
        let agent = Agent(name: "Test")

        XCTAssertFalse(agent.relapsedToday)
    }

    func test_relapsedToday_withTodayRelapse_returnsTrue() {
        let agent = Agent(name: "Test")
        agent.checkIns = [TestCheckInFactory.checkIn(daysAgo: 0, isSuccess: false)]

        XCTAssertTrue(agent.relapsedToday)
    }

    func test_relapsedToday_withTodayResisted_returnsFalse() {
        let agent = Agent(name: "Test")
        agent.checkIns = [TestCheckInFactory.checkIn(daysAgo: 0, isSuccess: true)]

        XCTAssertFalse(agent.relapsedToday)
    }

    // MARK: - progressPercent Tests

    func test_progressPercent_atZero_returnsZero() {
        let agent = Agent(name: "Test")

        XCTAssertEqual(agent.progressPercent, 0)
    }

    func test_progressPercent_atHalfway_returnsFifty() {
        let agent = Agent(name: "Test")
        agent.checkIns = TestCheckInFactory.consecutiveStreak(count: 33, startingDaysAgo: 0)

        XCTAssertEqual(agent.progressPercent, 50, accuracy: 1)
    }

    func test_progressPercent_atDefeated_returnsHundred() {
        let agent = Agent(name: "Test")
        agent.checkIns = TestCheckInFactory.consecutiveStreak(count: 66, startingDaysAgo: 0)

        XCTAssertEqual(agent.progressPercent, 100, accuracy: 0.1)
    }

    // MARK: - daysRemaining Tests

    func test_daysRemaining_atStart_returns66() {
        let agent = Agent(name: "Test")

        XCTAssertEqual(agent.daysRemaining, 66)
    }

    func test_daysRemaining_halfway_returns33() {
        let agent = Agent(name: "Test")
        agent.checkIns = TestCheckInFactory.consecutiveStreak(count: 33, startingDaysAgo: 0)

        XCTAssertEqual(agent.daysRemaining, 33)
    }

    func test_daysRemaining_atDefeated_returnsZero() {
        let agent = Agent(name: "Test")
        agent.checkIns = TestCheckInFactory.consecutiveStreak(count: 66, startingDaysAgo: 0)

        XCTAssertEqual(agent.daysRemaining, 0)
    }

    // MARK: - totalRelapses Tests

    func test_totalRelapses_withNoRelapses_returnsZero() {
        let agent = Agent(name: "Test")
        agent.checkIns = TestCheckInFactory.consecutiveStreak(count: 5, startingDaysAgo: 0)

        XCTAssertEqual(agent.totalRelapses, 0)
    }

    func test_totalRelapses_withMixedCheckIns_countsOnlyFailures() {
        let agent = Agent(name: "Test")
        agent.checkIns = [
            TestCheckInFactory.checkIn(daysAgo: 0, isSuccess: true),
            TestCheckInFactory.checkIn(daysAgo: 1, isSuccess: false),
            TestCheckInFactory.checkIn(daysAgo: 2, isSuccess: true),
            TestCheckInFactory.checkIn(daysAgo: 3, isSuccess: false),
            TestCheckInFactory.checkIn(daysAgo: 4, isSuccess: false)
        ]

        XCTAssertEqual(agent.totalRelapses, 3)
    }

    // MARK: - checkForDefeat Tests

    func test_checkForDefeat_belowTarget_doesNotDefeat() {
        let agent = Agent(name: "Test")
        agent.checkIns = TestCheckInFactory.consecutiveStreak(count: 65, startingDaysAgo: 0)

        agent.checkForDefeat()

        XCTAssertFalse(agent.isDefeated)
        XCTAssertNil(agent.defeatedAt)
    }

    func test_checkForDefeat_atTarget_defeats() {
        let agent = Agent(name: "Test")
        agent.checkIns = TestCheckInFactory.consecutiveStreak(count: 66, startingDaysAgo: 0)

        agent.checkForDefeat()

        XCTAssertTrue(agent.isDefeated)
        XCTAssertNotNil(agent.defeatedAt)
    }

    func test_checkForDefeat_alreadyDefeated_doesNotChangeDate() {
        let agent = Agent(name: "Test")
        agent.checkIns = TestCheckInFactory.consecutiveStreak(count: 66, startingDaysAgo: 0)
        agent.checkForDefeat()
        let originalDate = agent.defeatedAt

        agent.checkForDefeat()

        XCTAssertEqual(agent.defeatedAt, originalDate)
    }

    // MARK: - needsRecovery Tests

    func test_needsRecovery_withNoHistory_returnsFalse() {
        let agent = Agent(name: "Test")

        XCTAssertFalse(agent.needsRecovery)
    }

    func test_needsRecovery_resistedToday_returnsFalse() {
        let agent = Agent(name: "Test")
        agent.checkIns = TestCheckInFactory.consecutiveStreak(count: 5, startingDaysAgo: 0)

        XCTAssertFalse(agent.needsRecovery)
    }

    func test_needsRecovery_missedYesterdayWithPriorStreak_returnsTrue() {
        let agent = Agent(name: "Test")
        agent.checkIns = [
            TestCheckInFactory.checkIn(daysAgo: 2, isSuccess: true),
            TestCheckInFactory.checkIn(daysAgo: 3, isSuccess: true)
        ]

        XCTAssertTrue(agent.needsRecovery)
    }

    // MARK: - touch Tests

    func test_touch_updatesUpdatedAt() {
        let agent = Agent(name: "Test")
        let originalDate = agent.updatedAt

        Thread.sleep(forTimeInterval: 0.01)
        agent.touch()

        XCTAssertGreaterThan(agent.updatedAt, originalDate)
    }

    // MARK: - Helpers

    private func createDate(weekday: Int) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        components.weekday = weekday
        return calendar.date(from: components) ?? Date()
    }
}

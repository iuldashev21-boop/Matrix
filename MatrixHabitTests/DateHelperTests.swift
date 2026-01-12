import XCTest
@testable import MatrixHabit

final class DateHelperTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Ensure fresh cache for each test
        DateHelper.invalidateCache()
    }

    // MARK: - today Tests

    func test_today_returnsStartOfDay() {
        let today = DateHelper.today
        let calendar = Calendar.current

        let components = calendar.dateComponents([.hour, .minute, .second], from: today)

        XCTAssertEqual(components.hour, 0)
        XCTAssertEqual(components.minute, 0)
        XCTAssertEqual(components.second, 0)
    }

    func test_today_matchesCalendarStartOfDay() {
        let today = DateHelper.today
        let calendar = Calendar.current
        let expected = calendar.startOfDay(for: Date())

        XCTAssertEqual(today, expected)
    }

    func test_today_isCachedWithinDuration() {
        let first = DateHelper.today
        let second = DateHelper.today

        XCTAssertEqual(first, second)
    }

    // MARK: - yesterday Tests

    func test_yesterday_isOneDayBeforeToday() {
        let today = DateHelper.today
        let yesterday = DateHelper.yesterday
        let calendar = Calendar.current

        let daysDiff = calendar.dateComponents([.day], from: yesterday, to: today).day

        XCTAssertEqual(daysDiff, 1)
    }

    func test_yesterday_returnsStartOfDay() {
        let yesterday = DateHelper.yesterday
        let calendar = Calendar.current

        let components = calendar.dateComponents([.hour, .minute, .second], from: yesterday)

        XCTAssertEqual(components.hour, 0)
        XCTAssertEqual(components.minute, 0)
        XCTAssertEqual(components.second, 0)
    }

    // MARK: - currentHour Tests

    func test_currentHour_isValidHour() {
        let hour = DateHelper.currentHour

        XCTAssertGreaterThanOrEqual(hour, 0)
        XCTAssertLessThan(hour, 24)
    }

    func test_currentHour_matchesCurrentTime() {
        let hour = DateHelper.currentHour
        let calendarHour = Calendar.current.component(.hour, from: Date())

        // Allow 1 hour difference in case test runs at hour boundary
        XCTAssertTrue(abs(hour - calendarHour) <= 1)
    }

    // MARK: - isToday Tests

    func test_isToday_withTodayDate_returnsTrue() {
        let result = DateHelper.isToday(Date())

        XCTAssertTrue(result)
    }

    func test_isToday_withYesterdayDate_returnsFalse() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!

        let result = DateHelper.isToday(yesterday)

        XCTAssertFalse(result)
    }

    func test_isToday_withTomorrowDate_returnsFalse() {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!

        let result = DateHelper.isToday(tomorrow)

        XCTAssertFalse(result)
    }

    func test_isToday_withLaterTimeToday_returnsTrue() {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = 23
        components.minute = 59
        let laterToday = Calendar.current.date(from: components)!

        let result = DateHelper.isToday(laterToday)

        XCTAssertTrue(result)
    }

    // MARK: - isYesterday Tests

    func test_isYesterday_withYesterdayDate_returnsTrue() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!

        let result = DateHelper.isYesterday(yesterday)

        XCTAssertTrue(result)
    }

    func test_isYesterday_withTodayDate_returnsFalse() {
        let result = DateHelper.isYesterday(Date())

        XCTAssertFalse(result)
    }

    func test_isYesterday_withTwoDaysAgo_returnsFalse() {
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date())!

        let result = DateHelper.isYesterday(twoDaysAgo)

        XCTAssertFalse(result)
    }

    // MARK: - isBeforeYesterday Tests

    func test_isBeforeYesterday_withTwoDaysAgo_returnsTrue() {
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date())!

        let result = DateHelper.isBeforeYesterday(twoDaysAgo)

        XCTAssertTrue(result)
    }

    func test_isBeforeYesterday_withYesterday_returnsFalse() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!

        let result = DateHelper.isBeforeYesterday(yesterday)

        XCTAssertFalse(result)
    }

    func test_isBeforeYesterday_withToday_returnsFalse() {
        let result = DateHelper.isBeforeYesterday(Date())

        XCTAssertFalse(result)
    }

    func test_isBeforeYesterday_withWeekAgo_returnsTrue() {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!

        let result = DateHelper.isBeforeYesterday(weekAgo)

        XCTAssertTrue(result)
    }

    // MARK: - invalidateCache Tests

    func test_invalidateCache_refreshesValues() {
        _ = DateHelper.today // Prime the cache
        DateHelper.invalidateCache()

        // After invalidation, next access should still work
        let today = DateHelper.today
        let calendar = Calendar.current
        let expected = calendar.startOfDay(for: Date())

        XCTAssertEqual(today, expected)
    }

    // MARK: - DateHelpers (daysBetween) Tests

    func test_daysBetween_sameDays_returnsZero() {
        let date = Date()

        let result = DateHelpers.daysBetween(date, date)

        XCTAssertEqual(result, 0)
    }

    func test_daysBetween_consecutiveDays_returnsOne() {
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!

        let result = DateHelpers.daysBetween(today, tomorrow)

        XCTAssertEqual(result, 1)
    }

    func test_daysBetween_weekApart_returnsSeven() {
        let today = Date()
        let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: today)!

        let result = DateHelpers.daysBetween(today, nextWeek)

        XCTAssertEqual(result, 7)
    }

    func test_daysBetween_reversedDates_returnsNegative() {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!

        let result = DateHelpers.daysBetween(today, yesterday)

        XCTAssertEqual(result, -1)
    }

    func test_daysBetween_ignoresTimeComponent() {
        let calendar = Calendar.current
        var morningComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        morningComponents.hour = 6
        let morning = calendar.date(from: morningComponents)!

        var eveningComponents = morningComponents
        eveningComponents.hour = 22
        let evening = calendar.date(from: eveningComponents)!

        let result = DateHelpers.daysBetween(morning, evening)

        XCTAssertEqual(result, 0)
    }
}

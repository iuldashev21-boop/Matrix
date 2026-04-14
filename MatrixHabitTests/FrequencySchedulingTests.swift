import XCTest
@testable import MatrixHabit

/// Tests for habit frequency scheduling (non-daily habits)
final class FrequencySchedulingTests: XCTestCase {

    // MARK: - StreakCalculator with Scheduled Days

    func test_streak_withWeekdaysOnly_skipsWeekends() {
        // Weekdays only: Mon-Fri (2-6)
        let scheduledDays = [2, 3, 4, 5, 6]

        // Create check-ins for weekdays only
        let checkIns = createWeekdayCheckIns(count: 5)

        let streak = StreakCalculator.calculateStreak(for: checkIns, scheduledDays: scheduledDays)

        // Should count all weekday check-ins
        XCTAssertEqual(streak, 5)
    }

    func test_streak_withWeekendsOnly_skipsWeekdays() {
        // Weekends only: Sat-Sun (1, 7)
        let scheduledDays = [1, 7]

        // Create check-ins for last two weekends
        let checkIns = createWeekendCheckIns(weekendsBack: 2)

        let streak = StreakCalculator.calculateStreak(for: checkIns, scheduledDays: scheduledDays)

        XCTAssertGreaterThanOrEqual(streak, 2)
    }

    func test_streak_withMondayWednesdayFriday_countsCorrectly() {
        // M/W/F schedule (2, 4, 6)
        let scheduledDays = [2, 4, 6]
        let checkIns = createMWFCheckIns(weeksBack: 2)

        let streak = StreakCalculator.calculateStreak(for: checkIns, scheduledDays: scheduledDays)

        // Should count all M/W/F check-ins as consecutive
        XCTAssertGreaterThanOrEqual(streak, 3)
    }

    func test_streak_withSingleDaySchedule_countsWeeklyStreak() {
        // Only Sundays (1)
        let scheduledDays = [1]
        let checkIns = createSundayCheckIns(weeksBack: 4)

        let streak = StreakCalculator.calculateStreak(for: checkIns, scheduledDays: scheduledDays)

        XCTAssertEqual(streak, 4)
    }

    func test_streak_missedScheduledDay_breaksStreak() {
        // Weekdays only: Mon–Fri (2–6)
        let scheduledDays = [2, 3, 4, 5, 6]

        // Anchor to a fixed Friday so days 0–4 are all known weekdays:
        //   i=0 → Friday (6), i=1 → Thursday (5), i=2 → Wednesday (4),
        //   i=3 → Tuesday (3) [SKIPPED — the gap], i=4 → Monday (2)
        let calendar = Calendar.current
        var fridayComponents = DateComponents()
        fridayComponents.weekday = 6 // Friday
        fridayComponents.weekOfYear = calendar.component(.weekOfYear, from: Date())
        fridayComponents.yearForWeekOfYear = calendar.component(.yearForWeekOfYear, from: Date())
        guard let friday = calendar.date(from: fridayComponents).map({ calendar.startOfDay(for: $0) }),
              friday <= calendar.startOfDay(for: Date()) else {
            // If this week's Friday is in the future, step back one week
            var comps = fridayComponents
            comps.weekOfYear = (fridayComponents.weekOfYear ?? 1) - 1
            guard let prevFriday = calendar.date(from: comps).map({ calendar.startOfDay(for: $0) }) else { return }
            var checkIns2: [CheckIn] = []
            for i in 0..<5 {
                guard let date = calendar.date(byAdding: .day, value: -i, to: prevFriday) else { continue }
                if i == 3 { continue } // skip Tuesday — guaranteed weekday gap
                checkIns2.append(CheckIn(date: date, isSuccess: true))
            }
            let streak2 = StreakCalculator.calculateStreak(for: checkIns2, scheduledDays: scheduledDays)
            XCTAssertLessThan(streak2, 4)
            return
        }

        var checkIns: [CheckIn] = []
        for i in 0..<5 {
            guard let date = calendar.date(byAdding: .day, value: -i, to: friday) else { continue }
            if i == 3 { continue } // skip Tuesday — guaranteed weekday gap
            checkIns.append(CheckIn(date: date, isSuccess: true))
        }

        let streak = StreakCalculator.calculateStreak(for: checkIns, scheduledDays: scheduledDays)

        // Streak should be broken by the missed Tuesday
        XCTAssertLessThan(streak, 4)
    }

    func test_longestStreak_withScheduledDays_respectsSchedule() {
        // Weekdays only
        let scheduledDays = [2, 3, 4, 5, 6]
        let checkIns = createWeekdayCheckIns(count: 10)

        let longest = StreakCalculator.calculateLongestStreak(for: checkIns, scheduledDays: scheduledDays)

        XCTAssertGreaterThanOrEqual(longest, 5)
    }

    func test_emptyScheduledDays_treatedAsDaily() {
        let checkIns = TestCheckInFactory.consecutiveStreak(count: 7, startingDaysAgo: 0)

        let streakEmpty = StreakCalculator.calculateStreak(for: checkIns, scheduledDays: [])
        let streakFull = StreakCalculator.calculateStreak(for: checkIns, scheduledDays: [1, 2, 3, 4, 5, 6, 7])

        XCTAssertEqual(streakEmpty, streakFull)
    }

    func test_allSevenDays_sameAsDaily() {
        let checkIns = TestCheckInFactory.consecutiveStreak(count: 10, startingDaysAgo: 0)

        let streakDaily = StreakCalculator.calculateStreak(for: checkIns, scheduledDays: [])
        let streakAllDays = StreakCalculator.calculateStreak(for: checkIns, scheduledDays: [1, 2, 3, 4, 5, 6, 7])

        XCTAssertEqual(streakDaily, streakAllDays)
    }

    // MARK: - Power/Agent isScheduledToday Tests

    func test_power_isScheduledToday_matchesCurrentWeekday() {
        let calendar = Calendar.current
        let todayWeekday = calendar.component(.weekday, from: Date())

        let powerScheduled = Power(name: "Test", scheduledDays: [todayWeekday])
        let powerNotScheduled = Power(name: "Test", scheduledDays: [(todayWeekday % 7) + 1])

        XCTAssertTrue(powerScheduled.isScheduledToday)
        XCTAssertFalse(powerNotScheduled.isScheduledToday)
    }

    func test_agent_isScheduledToday_matchesCurrentWeekday() {
        let calendar = Calendar.current
        let todayWeekday = calendar.component(.weekday, from: Date())

        let agentScheduled = Agent(name: "Test", scheduledDays: [todayWeekday])
        let agentNotScheduled = Agent(name: "Test", scheduledDays: [(todayWeekday % 7) + 1])

        XCTAssertTrue(agentScheduled.isScheduledToday)
        XCTAssertFalse(agentNotScheduled.isScheduledToday)
    }

    // MARK: - Power/Agent isScheduled(on:) Tests

    func test_power_isScheduled_onSpecificDate() {
        let power = Power(name: "Weekdays", scheduledDays: [2, 3, 4, 5, 6])

        let monday = createDate(weekday: 2)
        let saturday = createDate(weekday: 7)

        XCTAssertTrue(power.isScheduled(on: monday))
        XCTAssertFalse(power.isScheduled(on: saturday))
    }

    func test_agent_isScheduled_onSpecificDate() {
        let agent = Agent(name: "Weekend", scheduledDays: [1, 7])

        let sunday = createDate(weekday: 1)
        let wednesday = createDate(weekday: 4)

        XCTAssertTrue(agent.isScheduled(on: sunday))
        XCTAssertFalse(agent.isScheduled(on: wednesday))
    }

    // MARK: - Edge Cases

    func test_streak_noCheckInsOnScheduledDays_returnsZero() {
        // Only Mondays scheduled
        let scheduledDays = [2]

        // Check-ins only on Sundays (not scheduled)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var checkIns: [CheckIn] = []

        for i in 0..<10 {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            let weekday = calendar.component(.weekday, from: date)
            if weekday == 1 { // Sunday only
                checkIns.append(CheckIn(date: date, isSuccess: true))
            }
        }

        let streak = StreakCalculator.calculateStreak(for: checkIns, scheduledDays: scheduledDays)

        // No check-ins on scheduled day means streak is 0
        XCTAssertEqual(streak, 0)
    }

    func test_streak_singleScheduledDay_multipleWeeks() {
        // Only Wednesdays
        let scheduledDays = [4]
        let checkIns = createWednesdayCheckIns(weeksBack: 3)

        let streak = StreakCalculator.calculateStreak(for: checkIns, scheduledDays: scheduledDays)

        XCTAssertGreaterThanOrEqual(streak, 2)
    }

    // MARK: - Helpers

    private func createWeekdayCheckIns(count: Int) -> [CheckIn] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var checkIns: [CheckIn] = []
        var added = 0
        var daysBack = 0

        while added < count && daysBack < 30 {
            guard let date = calendar.date(byAdding: .day, value: -daysBack, to: today) else {
                daysBack += 1
                continue
            }
            let weekday = calendar.component(.weekday, from: date)
            // Weekdays are 2-6 (Mon-Fri)
            if weekday >= 2 && weekday <= 6 {
                checkIns.append(CheckIn(date: date, isSuccess: true))
                added += 1
            }
            daysBack += 1
        }

        return checkIns
    }

    private func createWeekendCheckIns(weekendsBack: Int) -> [CheckIn] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var checkIns: [CheckIn] = []

        for i in 0..<(weekendsBack * 7) {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            let weekday = calendar.component(.weekday, from: date)
            // Weekends are 1 (Sun) and 7 (Sat)
            if weekday == 1 || weekday == 7 {
                checkIns.append(CheckIn(date: date, isSuccess: true))
            }
        }

        return checkIns
    }

    private func createMWFCheckIns(weeksBack: Int) -> [CheckIn] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var checkIns: [CheckIn] = []

        for i in 0..<(weeksBack * 7) {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            let weekday = calendar.component(.weekday, from: date)
            // M/W/F are 2, 4, 6
            if weekday == 2 || weekday == 4 || weekday == 6 {
                checkIns.append(CheckIn(date: date, isSuccess: true))
            }
        }

        return checkIns
    }

    private func createSundayCheckIns(weeksBack: Int) -> [CheckIn] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var checkIns: [CheckIn] = []

        // Find last Sunday
        var currentDate = today
        while calendar.component(.weekday, from: currentDate) != 1 {
            guard let prev = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
            currentDate = prev
        }

        // Add check-ins for previous Sundays
        for week in 0..<weeksBack {
            guard let date = calendar.date(byAdding: .day, value: -(week * 7), to: currentDate) else { continue }
            checkIns.append(CheckIn(date: date, isSuccess: true))
        }

        return checkIns
    }

    private func createWednesdayCheckIns(weeksBack: Int) -> [CheckIn] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var checkIns: [CheckIn] = []

        // Find last Wednesday
        var currentDate = today
        while calendar.component(.weekday, from: currentDate) != 4 {
            guard let prev = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
            currentDate = prev
        }

        // Add check-ins for previous Wednesdays
        for week in 0..<weeksBack {
            guard let date = calendar.date(byAdding: .day, value: -(week * 7), to: currentDate) else { continue }
            checkIns.append(CheckIn(date: date, isSuccess: true))
        }

        return checkIns
    }

    private func createDate(weekday: Int) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        components.weekday = weekday
        return calendar.date(from: components) ?? Date()
    }
}

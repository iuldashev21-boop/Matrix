import Foundation

enum StreakCalculator {
    /// Calculates the current streak from today/yesterday backwards
    /// - Parameters:
    ///   - checkIns: Array of check-ins for a habit
    ///   - scheduledDays: Days of week habit is scheduled (1=Sun...7=Sat). Empty = daily.
    /// - Returns: Number of consecutive successful scheduled days
    static func calculateStreak(for checkIns: [CheckIn], scheduledDays: [Int] = []) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Helper to check if a date is scheduled
        let isScheduled: (Date) -> Bool = { date in
            if scheduledDays.isEmpty || scheduledDays.count == 7 { return true }
            let weekday = calendar.component(.weekday, from: date)
            return scheduledDays.contains(weekday)
        }

        // Sort by date descending, only successful check-ins
        let sorted = checkIns
            .filter { $0.isSuccess }
            .sorted { $0.date > $1.date }

        guard let mostRecent = sorted.first else { return 0 }

        let mostRecentDay = calendar.startOfDay(for: mostRecent.date)

        // Find the last scheduled day (today or before)
        var lastScheduledDay = today
        while !isScheduled(lastScheduledDay) {
            guard let prev = calendar.date(byAdding: .day, value: -1, to: lastScheduledDay) else { return 0 }
            lastScheduledDay = prev
        }

        // Check if most recent check-in is on the last scheduled day or the one before
        let daysDiff = calendar.dateComponents([.day], from: mostRecentDay, to: lastScheduledDay).day ?? 0

        // Find how many scheduled days are between mostRecent and lastScheduledDay
        var scheduledDaysMissed = 0
        var checkDate = lastScheduledDay
        while checkDate > mostRecentDay {
            if isScheduled(checkDate) {
                scheduledDaysMissed += 1
            }
            guard let prev = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = prev
        }

        // If missed more than 1 scheduled day, streak is broken
        if scheduledDaysMissed > 1 { return 0 }

        var streak = 0

        // Build set of check-in dates for O(1) lookup
        let checkInDates = Set(sorted.map { calendar.startOfDay(for: $0.date) })

        // Walk backwards from mostRecentDay
        var currentDate = mostRecentDay
        let maxLookback = 365 * 3 // Safety limit

        for _ in 0..<maxLookback {
            if isScheduled(currentDate) {
                if checkInDates.contains(currentDate) {
                    streak += 1
                } else {
                    // Missed a scheduled day - streak breaks
                    break
                }
            }
            // Move to previous day (skip non-scheduled days automatically)
            guard let prev = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
            currentDate = prev
        }

        return streak
    }

    /// Calculates the longest streak ever achieved
    /// - Parameters:
    ///   - checkIns: Array of check-ins for a habit
    ///   - scheduledDays: Days of week habit is scheduled (1=Sun...7=Sat). Empty = daily.
    /// - Returns: Highest consecutive scheduled day count
    static func calculateLongestStreak(for checkIns: [CheckIn], scheduledDays: [Int] = []) -> Int {
        let calendar = Calendar.current

        // Helper to check if a date is scheduled
        let isScheduled: (Date) -> Bool = { date in
            if scheduledDays.isEmpty || scheduledDays.count == 7 { return true }
            let weekday = calendar.component(.weekday, from: date)
            return scheduledDays.contains(weekday)
        }

        // Sort by date ascending, only successful check-ins
        let sorted = checkIns
            .filter { $0.isSuccess }
            .sorted { $0.date < $1.date }

        guard !sorted.isEmpty else { return 0 }

        // Build set of check-in dates for O(1) lookup
        let checkInDates = Set(sorted.map { calendar.startOfDay(for: $0.date) })

        var longestStreak = 1
        var currentStreak = 1
        var previousDate = calendar.startOfDay(for: sorted[0].date)

        for i in 1..<sorted.count {
            let currentDate = calendar.startOfDay(for: sorted[i].date)

            // Count scheduled days between previousDate and currentDate (exclusive of both)
            var missedScheduledDays = 0
            var checkDate = previousDate
            guard var nextDay = calendar.date(byAdding: .day, value: 1, to: checkDate) else { continue }

            while nextDay < currentDate {
                if isScheduled(nextDay) {
                    if !checkInDates.contains(nextDay) {
                        missedScheduledDays += 1
                    }
                }
                guard let next = calendar.date(byAdding: .day, value: 1, to: nextDay) else { break }
                nextDay = next
            }

            if missedScheduledDays == 0 {
                // No scheduled days missed - streak continues
                currentStreak += 1
                longestStreak = max(longestStreak, currentStreak)
            } else {
                // Missed scheduled day(s) - reset streak
                currentStreak = 1
            }

            previousDate = currentDate
        }

        return longestStreak
    }
}


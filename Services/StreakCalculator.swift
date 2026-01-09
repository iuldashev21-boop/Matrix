import Foundation

enum StreakCalculator {
    /// Calculates the current streak from today/yesterday backwards
    /// - Parameter checkIns: Array of check-ins for a habit
    /// - Returns: Number of consecutive successful days
    static func calculateStreak(for checkIns: [CheckIn]) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Sort by date descending, only successful check-ins
        let sorted = checkIns
            .filter { $0.isSuccess }
            .sorted { $0.date > $1.date }

        guard let mostRecent = sorted.first else { return 0 }

        let mostRecentDay = calendar.startOfDay(for: mostRecent.date)

        // Check if most recent is today or yesterday
        let daysDiff = calendar.dateComponents([.day], from: mostRecentDay, to: today).day ?? 0

        // If gap is more than 1 day, streak is broken
        if daysDiff > 1 { return 0 }

        var streak = 0
        var expectedDate: Date
        if daysDiff == 0 {
            expectedDate = today
        } else {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else { return 0 }
            expectedDate = yesterday
        }

        for checkIn in sorted {
            let checkInDay = calendar.startOfDay(for: checkIn.date)

            if checkInDay == expectedDate {
                streak += 1
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: expectedDate) else { break }
                expectedDate = previousDay
            } else if checkInDay < expectedDate {
                // Gap found, streak breaks
                break
            }
            // If checkInDay > expectedDate, skip (shouldn't happen with sorted desc)
        }

        return streak
    }

    /// Calculates the longest streak ever achieved
    /// - Parameter checkIns: Array of check-ins for a habit
    /// - Returns: Highest consecutive day count
    static func calculateLongestStreak(for checkIns: [CheckIn]) -> Int {
        let calendar = Calendar.current

        // Sort by date ascending, only successful check-ins
        let sorted = checkIns
            .filter { $0.isSuccess }
            .sorted { $0.date < $1.date }

        guard !sorted.isEmpty else { return 0 }

        var longestStreak = 1
        var currentStreak = 1
        var previousDate = calendar.startOfDay(for: sorted[0].date)

        for i in 1..<sorted.count {
            let currentDate = calendar.startOfDay(for: sorted[i].date)
            let daysDiff = calendar.dateComponents([.day], from: previousDate, to: currentDate).day ?? 0

            if daysDiff == 1 {
                // Consecutive day
                currentStreak += 1
                longestStreak = max(longestStreak, currentStreak)
            } else if daysDiff > 1 {
                // Gap found, reset streak
                currentStreak = 1
            }
            // daysDiff == 0 means same day, skip

            previousDate = currentDate
        }

        return longestStreak
    }
}

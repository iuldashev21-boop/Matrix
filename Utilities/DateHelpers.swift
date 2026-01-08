import Foundation

enum DateHelpers {
    /// Returns the start of day (midnight) for a given date
    static func startOfDay(for date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }

    /// Returns today's date at midnight
    static var today: Date {
        startOfDay(for: Date())
    }

    /// Returns yesterday's date at midnight
    static var yesterday: Date {
        Calendar.current.date(byAdding: .day, value: -1, to: today)!
    }

    /// Checks if two dates are on the same calendar day
    static func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        Calendar.current.isDate(date1, inSameDayAs: date2)
    }

    /// Checks if a date is today
    static func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }

    /// Checks if a date is yesterday
    static func isYesterday(_ date: Date) -> Bool {
        Calendar.current.isDateInYesterday(date)
    }

    /// Returns the number of days between two dates
    static func daysBetween(_ start: Date, _ end: Date) -> Int {
        let calendar = Calendar.current
        let startDay = calendar.startOfDay(for: start)
        let endDay = calendar.startOfDay(for: end)
        return calendar.dateComponents([.day], from: startDay, to: endDay).day ?? 0
    }

    /// Formats a date as "Day X of Y"
    static func formatProgress(currentDay: Int, targetDays: Int) -> String {
        "DAY \(currentDay) OF \(targetDays)"
    }

    /// Formats a date for display (e.g., "Jan 7, 2026")
    static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    /// Formats a date for export (ISO 8601)
    static func formatISO(_ date: Date) -> String {
        ISO8601DateFormatter().string(from: date)
    }

    /// Returns an array of dates for the last N days (including today)
    static func lastDays(_ count: Int) -> [Date] {
        (0..<count).compactMap { offset in
            Calendar.current.date(byAdding: .day, value: -offset, to: today)
        }
    }

    /// Returns all dates from a start date to today
    static func dateRange(from startDate: Date) -> [Date] {
        var dates: [Date] = []
        var currentDate = startOfDay(for: startDate)
        let endDate = today

        while currentDate <= endDate {
            dates.append(currentDate)
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }

        return dates
    }
}

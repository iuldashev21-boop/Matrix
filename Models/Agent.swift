import Foundation
import SwiftData

@Model
final class Agent {
    var id: UUID
    var name: String
    var icon: String
    var createdAt: Date
    var updatedAt: Date
    var targetDays: Int
    var isDefeated: Bool
    var defeatedAt: Date?

    /// Days of week habit is scheduled (1=Sun, 2=Mon, 3=Tue, 4=Wed, 5=Thu, 6=Fri, 7=Sat)
    /// Empty array or all days = daily habit
    var scheduledDays: [Int]

    @Relationship(deleteRule: .cascade, inverse: \CheckIn.agent)
    var checkIns: [CheckIn]

    init(name: String, icon: String = "xmark.shield", scheduledDays: [Int] = [1, 2, 3, 4, 5, 6, 7]) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.createdAt = Date()
        self.updatedAt = Date()
        self.targetDays = Theme.habitFormationDays
        self.isDefeated = false
        self.defeatedAt = nil
        self.scheduledDays = scheduledDays
        self.checkIns = []
    }

    /// Check if today is a scheduled day for this habit
    var isScheduledToday: Bool {
        let weekday = Calendar.current.component(.weekday, from: DateHelper.today)
        return scheduledDays.isEmpty || scheduledDays.contains(weekday)
    }

    /// Check if a specific date is scheduled
    func isScheduled(on date: Date) -> Bool {
        let weekday = Calendar.current.component(.weekday, from: date)
        return scheduledDays.isEmpty || scheduledDays.contains(weekday)
    }

    /// Call this whenever the model is modified to track changes for sync
    func touch() {
        self.updatedAt = Date()
    }

    // MARK: - Computed Properties

    var currentStreak: Int {
        StreakCalculator.calculateStreak(for: checkIns, scheduledDays: scheduledDays)
    }

    var longestStreak: Int {
        StreakCalculator.calculateLongestStreak(for: checkIns, scheduledDays: scheduledDays)
    }

    var resistedToday: Bool {
        let today = DateHelper.today
        return checkIns.contains { Calendar.current.startOfDay(for: $0.date) == today && $0.isSuccess }
    }

    var relapsedToday: Bool {
        let today = DateHelper.today
        return checkIns.contains { Calendar.current.startOfDay(for: $0.date) == today && !$0.isSuccess }
    }

    var progressPercent: Double {
        guard targetDays > 0 else { return 0 }
        return Double(currentStreak) / Double(targetDays) * 100
    }

    var daysRemaining: Int {
        max(0, targetDays - currentStreak)
    }

    var totalRelapses: Int {
        checkIns.filter { !$0.isSuccess }.count
    }

    var needsRecovery: Bool {
        // Check if missed yesterday but had a streak before
        let calendar = Calendar.current
        let yesterday = DateHelper.yesterday

        // Single pass through checkIns
        var hasYesterdayCheckIn = false
        var hasPreviousStreak = false

        for checkIn in checkIns {
            let checkInDay = calendar.startOfDay(for: checkIn.date)
            if checkInDay == yesterday {
                hasYesterdayCheckIn = true
            } else if checkInDay < yesterday && checkIn.isSuccess {
                hasPreviousStreak = true
            }
            // Early exit if both conditions found
            if hasYesterdayCheckIn && hasPreviousStreak { break }
        }

        return !hasYesterdayCheckIn && hasPreviousStreak && !resistedToday
    }

    // MARK: - Methods

    func checkForDefeat() {
        if currentStreak >= targetDays && !isDefeated {
            isDefeated = true
            defeatedAt = Date()
            touch()
        }
    }
}


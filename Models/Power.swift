import Foundation
import SwiftData

@Model
final class Power {
    var id: UUID
    var name: String
    var icon: String
    var createdAt: Date
    var updatedAt: Date
    var targetDays: Int
    var isUnlocked: Bool
    var unlockedAt: Date?

    /// Days of week habit is scheduled (1=Sun, 2=Mon, 3=Tue, 4=Wed, 5=Thu, 6=Fri, 7=Sat)
    /// Empty array or all days = daily habit
    var scheduledDays: [Int]

    @Relationship(deleteRule: .cascade, inverse: \CheckIn.power)
    var checkIns: [CheckIn]

    init(name: String, icon: String = "bolt", scheduledDays: [Int] = [1, 2, 3, 4, 5, 6, 7]) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.createdAt = Date()
        self.updatedAt = Date()
        self.targetDays = Theme.habitFormationDays
        self.isUnlocked = false
        self.unlockedAt = nil
        self.scheduledDays = scheduledDays
        self.checkIns = []
    }

    /// Check if today is a scheduled day for this habit
    var isScheduledToday: Bool {
        let weekday = Calendar.current.component(.weekday, from: Date())
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

    var completedToday: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return checkIns.contains { Calendar.current.startOfDay(for: $0.date) == today && $0.isSuccess }
    }

    var progressPercent: Double {
        Double(currentStreak) / Double(targetDays) * 100
    }

    var daysRemaining: Int {
        max(0, targetDays - currentStreak)
    }

    var needsRecovery: Bool {
        // Check if missed yesterday but had a streak before
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else { return false }

        // Has check-in for yesterday?
        let hasYesterdayCheckIn = checkIns.contains {
            calendar.startOfDay(for: $0.date) == yesterday
        }

        // Has any previous check-ins (had a streak)?
        let hasPreviousStreak = checkIns.contains {
            calendar.startOfDay(for: $0.date) < yesterday && $0.isSuccess
        }

        return !hasYesterdayCheckIn && hasPreviousStreak && !completedToday
    }

    // MARK: - Methods

    func checkForUnlock() {
        if currentStreak >= targetDays && !isUnlocked {
            isUnlocked = true
            unlockedAt = Date()
            touch()
        }
    }
}


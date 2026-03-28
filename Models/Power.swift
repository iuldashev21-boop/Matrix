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
    var isPremiumLocked: Bool

    /// Days of week habit is scheduled (1=Sun, 2=Mon, 3=Tue, 4=Wed, 5=Thu, 6=Fri, 7=Sat)
    /// Empty array or all days = daily habit
    var scheduledDays: [Int]

    @Relationship(deleteRule: .cascade, inverse: \CheckIn.power)
    var checkIns: [CheckIn]

    init(name: String, icon: String = "bolt", scheduledDays: [Int] = [1, 2, 3, 4, 5, 6, 7], isPremiumLocked: Bool = false) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.createdAt = Date()
        self.updatedAt = Date()
        self.targetDays = Theme.habitFormationDays
        self.isUnlocked = false
        self.unlockedAt = nil
        self.isPremiumLocked = isPremiumLocked
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

    var completedToday: Bool {
        let today = DateHelper.today
        return checkIns.contains { Calendar.current.startOfDay(for: $0.date) == today && $0.isSuccess }
    }

    var progressPercent: Double {
        Double(currentStreak) / Double(targetDays) * 100
    }

    var daysRemaining: Int {
        max(0, targetDays - currentStreak)
    }

    var needsRecovery: Bool {
        let calendar = Calendar.current

        // Find the last scheduled day before today
        var lastScheduled = DateHelper.yesterday
        for _ in 0..<7 {
            if isScheduled(on: lastScheduled) { break }
            guard let prev = calendar.date(byAdding: .day, value: -1, to: lastScheduled) else { return false }
            lastScheduled = prev
        }

        // If last scheduled day is not yesterday (rest day gap), no recovery needed
        guard isScheduled(on: lastScheduled) else { return false }

        let hasLastScheduledCheckIn = checkIns.contains {
            calendar.startOfDay(for: $0.date) == lastScheduled
        }

        let hasPreviousStreak = checkIns.contains {
            calendar.startOfDay(for: $0.date) < lastScheduled && $0.isSuccess
        }

        return !hasLastScheduledCheckIn && hasPreviousStreak && !completedToday
    }

    // MARK: - Methods

    @discardableResult
    func checkForUnlock() -> Bool {
        if currentStreak >= targetDays && !isUnlocked {
            isUnlocked = true
            unlockedAt = Date()
            touch()
            return true
        }
        return false
    }
}


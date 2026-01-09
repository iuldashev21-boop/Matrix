import Foundation
import SwiftData

@Model
final class Power {
    var id: UUID
    var name: String
    var icon: String
    var createdAt: Date
    var targetDays: Int
    var isUnlocked: Bool
    var unlockedAt: Date?

    @Relationship(deleteRule: .cascade, inverse: \CheckIn.power)
    var checkIns: [CheckIn]

    init(name: String, icon: String = "bolt") {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.createdAt = Date()
        self.targetDays = Theme.habitFormationDays
        self.isUnlocked = false
        self.unlockedAt = nil
        self.checkIns = []
    }

    // MARK: - Computed Properties

    var currentStreak: Int {
        StreakCalculator.calculateStreak(for: checkIns)
    }

    var longestStreak: Int {
        StreakCalculator.calculateLongestStreak(for: checkIns)
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
        }
    }
}

import Foundation
import SwiftData
import SwiftUI

@MainActor
class AchievementManager: ObservableObject {
    @Published var recentlyUnlocked: AchievementDefinition? = nil
    @Published var showUnlockAnimation: Bool = false

    private var modelContext: ModelContext?

    func setContext(_ context: ModelContext) {
        self.modelContext = context
    }

    // MARK: - Check if Achievement is Unlocked

    func isUnlocked(_ achievementId: String) -> Bool {
        guard let context = modelContext else { return false }
        let descriptor = FetchDescriptor<Achievement>(
            predicate: #Predicate { $0.id == achievementId }
        )
        let results = (try? context.fetch(descriptor)) ?? []
        return !results.isEmpty
    }

    // MARK: - Unlock Achievement

    func unlock(_ achievementId: String) {
        guard let context = modelContext else { return }
        guard !isUnlocked(achievementId) else { return }

        let achievement = Achievement(id: achievementId)
        context.insert(achievement)
        try? context.save()

        // Award XP
        if let definition = AchievementLibrary.definition(for: achievementId) {
            UserProfile.addXP(definition.rarity.xpReward)

            // Show notification
            recentlyUnlocked = definition
            showUnlockAnimation = true

            // Haptic feedback
            UINotificationFeedbackGenerator().notificationOccurred(.success)

            // Auto-hide after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.showUnlockAnimation = false
                self.recentlyUnlocked = nil
            }
        }
    }

    // MARK: - Get All Unlocked

    func getUnlockedAchievements() -> [Achievement] {
        guard let context = modelContext else { return [] }
        let descriptor = FetchDescriptor<Achievement>(
            sortBy: [SortDescriptor(\.unlockedAt, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func getUnlockedCount() -> Int {
        getUnlockedAchievements().count
    }

    // MARK: - Check Achievements After Check-In

    func checkAchievementsAfterCheckIn(
        powers: [Power],
        agents: [Agent],
        totalCheckIns: Int
    ) {
        // First signal
        if totalCheckIns == 1 {
            unlock("log_first")
        }

        // Time-based achievements
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 8 {
            unlock("early_bird")
        }
        if hour >= 22 {
            unlock("night_owl")
        }

        // Weekend warrior
        let weekday = Calendar.current.component(.weekday, from: Date())
        if weekday == 1 || weekday == 7 {
            // Check if logged on both weekend days this week
            checkWeekendWarrior(powers: powers, agents: agents)
        }

        // Streak achievements
        let allHabits: [any HabitProtocol] = powers + agents
        for habit in allHabits {
            checkStreakAchievements(streak: habit.currentStreak)
        }

        // Agent-specific: 5-day resistance
        for agent in agents {
            if agent.currentStreak >= 5 {
                unlock("agent_resisted_5")
            }
        }

        // Daily consistency
        let completedToday = powers.filter { $0.completedToday }.count +
                            agents.filter { $0.resistedToday }.count
        let totalHabits = powers.count + agents.count

        if completedToday >= 3 {
            unlock("log_3_day")
        }

        if totalHabits > 0 && completedToday == totalHabits {
            unlock("log_all_day")
        }

        // Total check-ins milestones
        if totalCheckIns >= 50 {
            unlock("total_checkins_50")
        }
        if totalCheckIns >= 100 {
            unlock("total_checkins_100")
        }
        if totalCheckIns >= 365 {
            unlock("total_checkins_365")
        }

        // Perfect week check
        checkPerfectWeek(powers: powers, agents: agents)
    }

    // MARK: - Streak Achievements

    private func checkStreakAchievements(streak: Int) {
        if streak >= 1 { unlock("streak_1") }
        if streak >= 3 { unlock("streak_3") }
        if streak >= 7 { unlock("streak_7") }
        if streak >= 14 { unlock("streak_14") }
        if streak >= 21 { unlock("streak_21") }
        if streak >= 30 { unlock("streak_30") }
        if streak >= Theme.habitFormationDays { unlock("streak_66") }
    }

    // MARK: - Special Achievements

    func checkComebackAchievement(hadBrokenStreak: Bool) {
        if hadBrokenStreak {
            unlock("comeback")
        }
    }

    func checkWhiteRabbitAchievement() {
        unlock("white_rabbit")
    }

    func checkFirstHackAchievement() {
        unlock("first_hack")
    }

    func checkFirstAgentAchievement() {
        unlock("first_agent")
    }

    func checkDeleteHabitAchievement() {
        unlock("delete_habit")
    }

    // MARK: - Weekend Warrior Check

    private func checkWeekendWarrior(powers: [Power], agents: [Agent]) {
        let calendar = Calendar.current
        let today = Date()

        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) else { return }

        guard let saturday = calendar.date(byAdding: .day, value: 6, to: weekStart),
              let sunday = calendar.date(byAdding: .day, value: 7, to: weekStart) else { return }

        var saturdayLogged = false
        var sundayLogged = false

        for power in powers {
            for checkIn in power.checkIns {
                if calendar.isDate(checkIn.date, inSameDayAs: saturday) {
                    saturdayLogged = true
                }
                if calendar.isDate(checkIn.date, inSameDayAs: sunday) {
                    sundayLogged = true
                }
            }
        }

        for agent in agents {
            for checkIn in agent.checkIns {
                if calendar.isDate(checkIn.date, inSameDayAs: saturday) {
                    saturdayLogged = true
                }
                if calendar.isDate(checkIn.date, inSameDayAs: sunday) {
                    sundayLogged = true
                }
            }
        }

        if saturdayLogged && sundayLogged {
            unlock("weekend_warrior")
        }
    }

    // MARK: - Perfect Week Check

    private func checkPerfectWeek(powers: [Power], agents: [Agent]) {
        let calendar = Calendar.current
        let today = Date()

        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) else { return }

        let totalHabits = powers.count + agents.count
        guard totalHabits > 0 else { return }

        // Check each day of the week
        for dayOffset in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) else { continue }

            // Skip future days
            if day > today { return }

            var completedOnDay = 0

            for power in powers {
                if power.checkIns.contains(where: { calendar.isDate($0.date, inSameDayAs: day) }) {
                    completedOnDay += 1
                }
            }

            for agent in agents {
                if agent.checkIns.contains(where: { calendar.isDate($0.date, inSameDayAs: day) }) {
                    completedOnDay += 1
                }
            }

            // If any day is incomplete, no perfect week
            if completedOnDay < totalHabits {
                return
            }
        }

        // All days complete!
        unlock("perfect_week")
    }
}

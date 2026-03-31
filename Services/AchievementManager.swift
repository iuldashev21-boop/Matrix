import Foundation
import SwiftData
import SwiftUI

@MainActor
class AchievementManager: ObservableObject {
    @Published var recentlyUnlocked: AchievementDefinition? = nil
    @Published var showUnlockAnimation: Bool = false

    private var modelContext: ModelContext?
    private var unlockedCache: Set<String>?

    func setContext(_ context: ModelContext) {
        self.modelContext = context
    }

    private func loadUnlockedCache() {
        guard let context = modelContext else { return }
        let descriptor = FetchDescriptor<Achievement>()
        do {
            let all = try context.fetch(descriptor)
            unlockedCache = Set(all.map { $0.id })
        } catch {
            ErrorLogger.logFetchFailure(error, context: "AchievementManager.loadUnlockedCache")
            unlockedCache = nil
        }
    }

    // MARK: - Check if Achievement is Unlocked

    func isUnlocked(_ achievementId: String) -> Bool {
        if let cache = unlockedCache {
            return cache.contains(achievementId)
        }
        guard let context = modelContext else { return false }
        let descriptor = FetchDescriptor<Achievement>(
            predicate: #Predicate { $0.id == achievementId }
        )
        do {
            let results = try context.fetch(descriptor)
            return !results.isEmpty
        } catch {
            ErrorLogger.logFetchFailure(error, context: "AchievementManager.isUnlocked(\(achievementId))")
            return false
        }
    }

    // MARK: - Unlock Achievement

    func unlock(_ achievementId: String) {
        guard let context = modelContext else { return }
        guard !isUnlocked(achievementId) else { return }

        let achievement = Achievement(id: achievementId)
        context.insert(achievement)
        unlockedCache?.insert(achievementId)
        do {
            try context.save()
        } catch {
            ErrorLogger.logSaveFailure(error, context: "AchievementManager.unlock(\(achievementId))")
        }

        // Award XP
        if let definition = AchievementLibrary.definition(for: achievementId) {
            UserProfile.addXP(definition.rarity.xpReward)

            // Show notification
            recentlyUnlocked = definition
            showUnlockAnimation = true

            // Haptic feedback
            UINotificationFeedbackGenerator().notificationOccurred(.success)

            // Auto-hide after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                self?.showUnlockAnimation = false
                self?.recentlyUnlocked = nil
            }
        }
    }

    // MARK: - Get All Unlocked

    func getUnlockedAchievements() -> [Achievement] {
        guard let context = modelContext else { return [] }
        let descriptor = FetchDescriptor<Achievement>(
            sortBy: [SortDescriptor(\.unlockedAt, order: .reverse)]
        )
        do {
            return try context.fetch(descriptor)
        } catch {
            ErrorLogger.logFetchFailure(error, context: "AchievementManager.getUnlockedAchievements")
            return []
        }
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
        loadUnlockedCache()

        // First signal
        if totalCheckIns == 1 {
            unlock("log_first")
        }

        // Time-based achievements (uses device local time)
        let hour = DateHelper.currentHour
        if hour < 8 {
            unlock("early_bird")
        }
        if hour >= 22 {
            unlock("night_owl")
        }

        // Weekend warrior
        let weekday = Calendar.current.component(.weekday, from: DateHelper.today)
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
        guard !isUnlocked("weekend_warrior") else { return }
        let calendar = Calendar.current
        let today = DateHelper.today

        // Find this week's Saturday (weekday 7) and Sunday (weekday 1)
        // using weekday component — works regardless of locale's firstWeekday
        let todayWeekday = calendar.component(.weekday, from: today)
        let daysToSaturday = (7 - todayWeekday + 7) % 7  // 7 = Saturday
        let daysToSunday = (1 - todayWeekday + 7) % 7     // 1 = Sunday

        guard let saturday = calendar.date(byAdding: .day, value: daysToSaturday == 0 ? 0 : daysToSaturday - 7, to: today),
              let sunday = calendar.date(byAdding: .day, value: daysToSunday == 0 ? 0 : daysToSunday - 7, to: today) else { return }

        // Only check days that have already passed
        let checkSaturday = saturday <= today
        let checkSunday = sunday <= today
        guard checkSaturday || checkSunday else { return }

        var saturdayLogged = !checkSaturday  // skip if future
        var sundayLogged = !checkSunday

        let allCheckIns = powers.flatMap(\.checkIns) + agents.flatMap(\.checkIns)
        for checkIn in allCheckIns {
            if !saturdayLogged && calendar.isDate(checkIn.date, inSameDayAs: saturday) {
                saturdayLogged = true
            }
            if !sundayLogged && calendar.isDate(checkIn.date, inSameDayAs: sunday) {
                sundayLogged = true
            }
            if saturdayLogged && sundayLogged { break }
        }

        if saturdayLogged && sundayLogged {
            unlock("weekend_warrior")
        }
    }

    // MARK: - Perfect Week Check

    private func checkPerfectWeek(powers: [Power], agents: [Agent]) {
        guard !isUnlocked("perfect_week") else { return }
        let calendar = Calendar.current
        let today = DateHelper.today

        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) else { return }
        guard !powers.isEmpty || !agents.isEmpty else { return }

        // Check each day of the week up to today
        for dayOffset in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) else { continue }
            if day > today { break }

            // Only count habits scheduled on this specific day
            for power in powers where power.isScheduled(on: day) {
                let completed = power.checkIns.contains { calendar.isDate($0.date, inSameDayAs: day) }
                if !completed { return }
            }

            for agent in agents where agent.isScheduled(on: day) {
                let completed = agent.checkIns.contains { calendar.isDate($0.date, inSameDayAs: day) }
                if !completed { return }
            }
        }

        unlock("perfect_week")
    }
}


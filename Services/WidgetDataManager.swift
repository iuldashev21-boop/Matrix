import Foundation
import WidgetKit

enum WidgetDataManager {
    static let appGroupID = "group.com.construct.MatrixHabit"
    private static let widgetDataKey = "com.matrixhabit.widget.data"

    struct HabitSnapshot: Codable {
        let id: String
        let name: String
        let icon: String
        let streak: Int
        let completedToday: Bool
        let isPower: Bool
    }

    struct WidgetData: Codable {
        let habits: [HabitSnapshot]
        let totalStreak: Int
        let completedToday: Int
        let totalScheduledToday: Int
        let lastUpdated: Date
    }

    static func update(
        powers: [(id: String, name: String, icon: String, streak: Int, completedToday: Bool, isScheduledToday: Bool)],
        agents: [(id: String, name: String, icon: String, streak: Int, completedToday: Bool, isScheduledToday: Bool)]
    ) {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupID) else { return }

        var snapshots: [HabitSnapshot] = []
        var totalStreak = 0
        var completedCount = 0
        var scheduledCount = 0

        for p in powers {
            snapshots.append(HabitSnapshot(id: p.id, name: p.name, icon: p.icon, streak: p.streak, completedToday: p.completedToday, isPower: true))
            totalStreak += p.streak
            if p.isScheduledToday {
                scheduledCount += 1
                if p.completedToday { completedCount += 1 }
            }
        }

        for a in agents {
            snapshots.append(HabitSnapshot(id: a.id, name: a.name, icon: a.icon, streak: a.streak, completedToday: a.completedToday, isPower: false))
            totalStreak += a.streak
            if a.isScheduledToday {
                scheduledCount += 1
                if a.completedToday { completedCount += 1 }
            }
        }

        let data = WidgetData(
            habits: snapshots,
            totalStreak: totalStreak,
            completedToday: completedCount,
            totalScheduledToday: scheduledCount,
            lastUpdated: Date()
        )

        if let encoded = try? JSONEncoder().encode(data) {
            sharedDefaults.set(encoded, forKey: widgetDataKey)
        }

        WidgetCenter.shared.reloadAllTimelines()
    }

    static func readWidgetData() -> WidgetData? {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupID),
              let data = sharedDefaults.data(forKey: widgetDataKey),
              let widgetData = try? JSONDecoder().decode(WidgetData.self, from: data) else {
            return nil
        }
        return widgetData
    }

    // MARK: - Pending Check-Ins

    struct PendingCheckIn: Codable {
        let habitId: String
        let habitName: String
        let isPower: Bool
        let date: Date
    }

    private static let pendingCheckInsKey = "com.matrixhabit.widget.pendingCheckins"

    static func addPendingCheckIn(_ checkIn: PendingCheckIn) {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupID) else { return }

        var pending = readPendingCheckIns()

        let calendar = Calendar.current
        let isDuplicate = pending.contains { existing in
            existing.habitId == checkIn.habitId
                && calendar.isDate(existing.date, inSameDayAs: checkIn.date)
        }

        guard !isDuplicate else { return }

        pending.append(checkIn)
        if let encoded = try? JSONEncoder().encode(pending) {
            sharedDefaults.set(encoded, forKey: pendingCheckInsKey)
        }
    }

    static func readPendingCheckIns() -> [PendingCheckIn] {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupID),
              let data = sharedDefaults.data(forKey: pendingCheckInsKey),
              let pending = try? JSONDecoder().decode([PendingCheckIn].self, from: data) else {
            return []
        }
        return pending
    }

    static func clearPendingCheckIns() {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupID) else { return }
        sharedDefaults.removeObject(forKey: pendingCheckInsKey)
    }

    static func markHabitCompleted(habitId: String) {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupID),
              let data = sharedDefaults.data(forKey: widgetDataKey),
              var widgetData = try? JSONDecoder().decode(WidgetData.self, from: data) else {
            return
        }

        var updatedHabits = widgetData.habits
        var additionalCompleted = 0

        for i in updatedHabits.indices {
            if updatedHabits[i].id == habitId && !updatedHabits[i].completedToday {
                updatedHabits[i] = HabitSnapshot(
                    id: updatedHabits[i].id,
                    name: updatedHabits[i].name,
                    icon: updatedHabits[i].icon,
                    streak: updatedHabits[i].streak,
                    completedToday: true,
                    isPower: updatedHabits[i].isPower
                )
                additionalCompleted += 1
            }
        }

        widgetData = WidgetData(
            habits: updatedHabits,
            totalStreak: widgetData.totalStreak,
            completedToday: widgetData.completedToday + additionalCompleted,
            totalScheduledToday: widgetData.totalScheduledToday,
            lastUpdated: widgetData.lastUpdated
        )

        if let encoded = try? JSONEncoder().encode(widgetData) {
            sharedDefaults.set(encoded, forKey: widgetDataKey)
        }
    }
}

import Foundation
import WidgetKit

enum WidgetDataManager {
    static let appGroupID = "group.com.construct.MatrixHabit"
    private static let widgetDataKey = "com.matrixhabit.widget.data"

    struct HabitSnapshot: Codable {
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
        powers: [(name: String, icon: String, streak: Int, completedToday: Bool, isScheduledToday: Bool)],
        agents: [(name: String, icon: String, streak: Int, completedToday: Bool, isScheduledToday: Bool)]
    ) {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupID) else { return }

        var snapshots: [HabitSnapshot] = []
        var totalStreak = 0
        var completedCount = 0
        var scheduledCount = 0

        for p in powers {
            snapshots.append(HabitSnapshot(name: p.name, icon: p.icon, streak: p.streak, completedToday: p.completedToday, isPower: true))
            totalStreak += p.streak
            if p.isScheduledToday {
                scheduledCount += 1
                if p.completedToday { completedCount += 1 }
            }
        }

        for a in agents {
            snapshots.append(HabitSnapshot(name: a.name, icon: a.icon, streak: a.streak, completedToday: a.completedToday, isPower: false))
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
}

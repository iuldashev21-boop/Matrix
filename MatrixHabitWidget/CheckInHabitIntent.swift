import AppIntents
import Foundation
import WidgetKit

struct CheckInHabitIntent: AppIntent {
    static var title: LocalizedStringResource = "Check In Habit"
    static var description = IntentDescription("Mark a habit as complete for today")

    @Parameter(title: "Habit ID")
    var habitId: String

    @Parameter(title: "Habit Name")
    var habitName: String

    @Parameter(title: "Is Power")
    var isPower: Bool

    init() {
        self.habitId = ""
        self.habitName = ""
        self.isPower = true
    }

    init(habitId: String, habitName: String, isPower: Bool) {
        self.habitId = habitId
        self.habitName = habitName
        self.isPower = isPower
    }

    func perform() async throws -> some IntentResult {
        let appGroupID = "group.com.construct.MatrixHabit"
        let pendingKey = "com.matrixhabit.widget.pendingCheckins"
        let widgetDataKey = "com.matrixhabit.widget.data"

        guard let sharedDefaults = UserDefaults(suiteName: appGroupID) else {
            return .result()
        }

        // 1. Add pending check-in
        let pending = PendingEntry(
            habitId: habitId,
            habitName: habitName,
            isPower: isPower,
            date: Calendar.current.startOfDay(for: Date())
        )

        var existingPending: [PendingEntry] = []
        if let data = sharedDefaults.data(forKey: pendingKey),
           let decoded = try? JSONDecoder().decode([PendingEntry].self, from: data) {
            existingPending = decoded
        }

        // Deduplicate by habit ID + date
        let isDuplicate = existingPending.contains {
            $0.habitId == pending.habitId &&
            Calendar.current.startOfDay(for: $0.date) == Calendar.current.startOfDay(for: pending.date)
        }
        guard !isDuplicate else { return .result() }

        existingPending.append(pending)
        if let encoded = try? JSONEncoder().encode(existingPending) {
            sharedDefaults.set(encoded, forKey: pendingKey)
        }

        // 2. Optimistically update widget data
        if let widgetRaw = sharedDefaults.data(forKey: widgetDataKey),
           var widgetData = try? JSONDecoder().decode(WidgetDataSnapshot.self, from: widgetRaw) {

            widgetData.habits = widgetData.habits.map { habit in
                if habit.id == habitId && !habit.completedToday {
                    return HabitEntry(
                        id: habit.id,
                        name: habit.name,
                        icon: habit.icon,
                        streak: habit.streak,
                        completedToday: true,
                        isPower: habit.isPower
                    )
                }
                return habit
            }
            widgetData.completedToday = widgetData.habits.filter(\.completedToday).count
            widgetData.lastUpdated = Date()

            if let encoded = try? JSONEncoder().encode(widgetData) {
                sharedDefaults.set(encoded, forKey: widgetDataKey)
            }
        }

        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

// MARK: - Local Codable types (self-contained, no cross-target dependency)

private struct PendingEntry: Codable {
    let habitId: String
    let habitName: String
    let isPower: Bool
    let date: Date
}

private struct HabitEntry: Codable {
    let id: String
    let name: String
    let icon: String
    let streak: Int
    var completedToday: Bool
    let isPower: Bool
}

private struct WidgetDataSnapshot: Codable {
    var habits: [HabitEntry]
    let totalStreak: Int
    var completedToday: Int
    let totalScheduledToday: Int
    var lastUpdated: Date
}

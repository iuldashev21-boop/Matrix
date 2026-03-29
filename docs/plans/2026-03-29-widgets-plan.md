# Lock Screen Widgets + Interactive Check-In — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add 3 lock screen widget variants (circular, rectangular, inline) and upgrade the medium widget with tap-to-check-in via AppIntents.

**Architecture:** Widget check-ins write pending entries to shared UserDefaults via App Groups. Main app syncs pending check-ins to SwiftData on foreground. Lock screen widgets are display-only (iOS limitation). All widget views read from the existing `WidgetHabitData` structure.

**Tech Stack:** WidgetKit, AppIntents, SwiftUI, UserDefaults (App Group: `group.com.construct.MatrixHabit`)

---

## Task 1: Add Pending Check-In Storage to WidgetDataManager

**Files:**
- Modify: `Services/WidgetDataManager.swift`

**Step 1: Add PendingCheckIn struct and read/write/clear methods**

Add the following below the existing `readWidgetData()` method in `Services/WidgetDataManager.swift`:

```swift
// MARK: - Pending Check-Ins (written by widget, consumed by main app)

private static let pendingCheckInsKey = "com.matrixhabit.widget.pendingCheckins"

struct PendingCheckIn: Codable {
    let habitName: String
    let isPower: Bool
    let date: Date
}

static func addPendingCheckIn(_ pending: PendingCheckIn) {
    guard let sharedDefaults = UserDefaults(suiteName: appGroupID) else { return }
    var existing = readPendingCheckIns()

    // Deduplicate by name + date (same habit, same day)
    let checkDate = Calendar.current.startOfDay(for: pending.date)
    let isDuplicate = existing.contains {
        $0.habitName == pending.habitName && Calendar.current.startOfDay(for: $0.date) == checkDate
    }
    guard !isDuplicate else { return }

    existing.append(pending)
    if let encoded = try? JSONEncoder().encode(existing) {
        sharedDefaults.set(encoded, forKey: pendingCheckInsKey)
    }
}

static func readPendingCheckIns() -> [PendingCheckIn] {
    guard let sharedDefaults = UserDefaults(suiteName: appGroupID),
          let data = sharedDefaults.data(forKey: pendingCheckInsKey),
          let decoded = try? JSONDecoder().decode([PendingCheckIn].self, from: data) else {
        return []
    }
    return decoded
}

static func clearPendingCheckIns() {
    guard let sharedDefaults = UserDefaults(suiteName: appGroupID) else { return }
    sharedDefaults.removeObject(forKey: pendingCheckInsKey)
}
```

**Step 2: Add method to optimistically update widget data snapshot**

Add below the pending check-in methods:

```swift
static func markHabitCompleted(habitName: String) {
    guard let sharedDefaults = UserDefaults(suiteName: appGroupID),
          let data = sharedDefaults.data(forKey: widgetDataKey),
          var widgetData = try? JSONDecoder().decode(WidgetData.self, from: data) else {
        return
    }

    let updatedHabits = widgetData.habits.map { habit -> HabitSnapshot in
        if habit.name == habitName && !habit.completedToday {
            return HabitSnapshot(
                name: habit.name,
                icon: habit.icon,
                streak: habit.streak,
                completedToday: true,
                isPower: habit.isPower
            )
        }
        return habit
    }

    let newCompleted = updatedHabits.filter(\.completedToday).count
    let widgetUpdate = WidgetData(
        habits: updatedHabits,
        totalStreak: widgetData.totalStreak,
        completedToday: newCompleted,
        totalScheduledToday: widgetData.totalScheduledToday,
        lastUpdated: Date()
    )

    if let encoded = try? JSONEncoder().encode(widgetUpdate) {
        sharedDefaults.set(encoded, forKey: widgetDataKey)
    }
}
```

**Note:** The `widgetDataKey` property needs to change from `private` to `fileprivate` or the `markHabitCompleted` method should be inside the enum (which it is). No access change needed since both are inside `WidgetDataManager`.

**Step 3: Build to verify**

Run: XcodeBuildMCP `build_sim` with scheme MatrixHabit
Expected: BUILD SUCCEEDED

**Step 4: Commit**

```bash
git add Services/WidgetDataManager.swift
git commit -m "feat(widget): add pending check-in storage to WidgetDataManager"
```

---

## Task 2: Create CheckInHabitIntent (AppIntents)

**Files:**
- Create: `MatrixHabitWidget/CheckInHabitIntent.swift` (added to BOTH targets)

**Step 1: Create the AppIntent file**

Create `MatrixHabitWidget/CheckInHabitIntent.swift`:

```swift
import AppIntents
import Foundation
import WidgetKit

struct CheckInHabitIntent: AppIntent {
    static var title: LocalizedStringResource = "Check In Habit"
    static var description = IntentDescription("Mark a habit as complete for today")

    @Parameter(title: "Habit Name")
    var habitName: String

    @Parameter(title: "Is Power")
    var isPower: Bool

    init() {
        self.habitName = ""
        self.isPower = true
    }

    init(habitName: String, isPower: Bool) {
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
            habitName: habitName,
            isPower: isPower,
            date: Calendar.current.startOfDay(for: Date())
        )

        var existingPending: [PendingEntry] = []
        if let data = sharedDefaults.data(forKey: pendingKey),
           let decoded = try? JSONDecoder().decode([PendingEntry].self, from: data) {
            existingPending = decoded
        }

        // Deduplicate
        let isDuplicate = existingPending.contains {
            $0.habitName == pending.habitName &&
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
                if habit.name == habitName && !habit.completedToday {
                    return HabitEntry(
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

        return .result()
    }
}

// MARK: - Local Codable types (self-contained, no cross-target dependency)

private struct PendingEntry: Codable {
    let habitName: String
    let isPower: Bool
    let date: Date
}

private struct HabitEntry: Codable {
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
```

**Step 2: Add file to BOTH Xcode targets**

In Xcode project (or via pbxproj manipulation):
- Add `CheckInHabitIntent.swift` to **MatrixHabit** target (main app)
- Add `CheckInHabitIntent.swift` to **MatrixHabitWidgetExtension** target

This is critical because AppIntents must be compiled in both processes. The file lives in `MatrixHabitWidget/` but is included in both targets via Target Membership.

**Step 3: Build to verify**

Run: XcodeBuildMCP `build_sim` with scheme MatrixHabit
Expected: BUILD SUCCEEDED

**Step 4: Commit**

```bash
git add MatrixHabitWidget/CheckInHabitIntent.swift MatrixHabit.xcodeproj/project.pbxproj
git commit -m "feat(widget): add CheckInHabitIntent for interactive widget check-in"
```

---

## Task 3: Add Lock Screen Widget Views

**Files:**
- Create: `MatrixHabitWidget/LockScreenWidgets.swift` (widget target only)

**Step 1: Create the lock screen views file**

Create `MatrixHabitWidget/LockScreenWidgets.swift`:

```swift
import SwiftUI
import WidgetKit

// MARK: - Accessory Circular (Progress Ring)

struct CircularWidgetView: View {
    let data: WidgetHabitData?

    var body: some View {
        if let data = data, data.totalScheduledToday > 0 {
            Gauge(
                value: Double(data.completedToday),
                in: 0...Double(data.totalScheduledToday)
            ) {
                Text("") // required but not shown
            } currentValueLabel: {
                Text("\(data.completedToday)/\(data.totalScheduledToday)")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
            }
            .gaugeStyle(.accessoryCircularCapacity)
        } else {
            Gauge(value: 0, in: 0...1) {
                Text("")
            } currentValueLabel: {
                Text("--")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
            }
            .gaugeStyle(.accessoryCircularCapacity)
        }
    }
}

// MARK: - Accessory Rectangular (Terminal Habit List)

struct RectangularWidgetView: View {
    let data: WidgetHabitData?

    var body: some View {
        if let data = data, !data.habits.isEmpty {
            let scheduled = data.habits.filter { !$0.completedToday }
                .sorted { $0.streak > $1.streak }
            let completed = data.habits.filter(\.completedToday)
                .sorted { $0.streak > $1.streak }

            VStack(alignment: .leading, spacing: 2) {
                if scheduled.isEmpty {
                    // All done — show top completed
                    ForEach(Array(completed.prefix(2).enumerated()), id: \.offset) { _, habit in
                        habitRow(habit, done: true)
                    }
                    Text("ALL CLEAR")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                } else {
                    // Show top uncompleted
                    ForEach(Array(scheduled.prefix(2).enumerated()), id: \.offset) { _, habit in
                        habitRow(habit, done: false)
                    }
                    let remaining = data.totalScheduledToday - data.completedToday
                    Text("\(remaining) REMAINING")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
            }
        } else {
            VStack(alignment: .leading, spacing: 2) {
                Text("> MATRIX")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                Text("LOAD PROGRAM")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func habitRow(_ habit: HabitSnapshot, done: Bool) -> some View {
        HStack(spacing: 4) {
            Text(done ? "+" : ">")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
            Text(habit.name.uppercased())
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .lineLimit(1)
            Spacer()
            Text("\(habit.streak)d")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
        }
    }
}

// MARK: - Accessory Inline (Single Line)

struct InlineWidgetView: View {
    let data: WidgetHabitData?

    var body: some View {
        if let data = data, data.totalScheduledToday > 0 {
            if data.completedToday >= data.totalScheduledToday {
                Label("ALL SIGNALS ACTIVE", systemImage: "bolt.fill")
            } else {
                Label("\(data.completedToday)/\(data.totalScheduledToday) COMPLETE", systemImage: "bolt.fill")
            }
            .font(.system(size: 12, design: .monospaced))
        } else {
            Label("MATRIX", systemImage: "bolt.fill")
                .font(.system(size: 12, design: .monospaced))
        }
    }
}
```

**Step 2: Add file to widget target in Xcode project**

Add `LockScreenWidgets.swift` to the **MatrixHabitWidgetExtension** target only (not main app).

**Step 3: Build to verify**

Run: XcodeBuildMCP `build_sim` with scheme MatrixHabit
Expected: BUILD SUCCEEDED

**Step 4: Commit**

```bash
git add MatrixHabitWidget/LockScreenWidgets.swift MatrixHabit.xcodeproj/project.pbxproj
git commit -m "feat(widget): add lock screen widget views (circular, rectangular, inline)"
```

---

## Task 4: Wire Lock Screen Widgets + Interactive Medium Widget into Main Widget File

**Files:**
- Modify: `MatrixHabitWidget/MatrixHabitWidget.swift`

**Step 1: Add lock screen families to supportedFamilies**

In `MatrixHabitWidget`, change the `.supportedFamilies` line:

```swift
// OLD:
.supportedFamilies([.systemSmall, .systemMedium])

// NEW:
.supportedFamilies([
    .systemSmall,
    .systemMedium,
    .accessoryCircular,
    .accessoryRectangular,
    .accessoryInline
])
```

**Step 2: Add lock screen views to the WidgetEntryView switch**

Replace the `WidgetEntryView` body:

```swift
struct WidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: MatrixHabitEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(data: entry.data)
        case .systemMedium:
            MediumWidgetView(data: entry.data)
        case .accessoryCircular:
            CircularWidgetView(data: entry.data)
        case .accessoryRectangular:
            RectangularWidgetView(data: entry.data)
        case .accessoryInline:
            InlineWidgetView(data: entry.data)
        default:
            SmallWidgetView(data: entry.data)
        }
    }
}
```

**Step 3: Add interactive Button(intent:) to MediumWidgetView habit rows**

In `MediumWidgetView`, replace the habit row `ForEach` block (the right side habit list):

```swift
// Right side: habit list (top 4)
VStack(alignment: .leading, spacing: 6) {
    ForEach(Array(data.habits.sorted(by: { $0.streak > $1.streak }).prefix(4).enumerated()), id: \.offset) { _, habit in
        HStack(spacing: 6) {
            if habit.completedToday {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 11))
                    .foregroundColor(matrixGreen)
            } else {
                Button(intent: CheckInHabitIntent(habitName: habit.name, isPower: habit.isPower)) {
                    Image(systemName: "circle")
                        .font(.system(size: 11))
                        .foregroundColor(mediumGray)
                }
                .buttonStyle(.plain)
            }

            Text(habit.name.uppercased())
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(habit.completedToday ? .white : mediumGray)
                .lineLimit(1)

            Spacer()

            Text("\(habit.streak)d")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(matrixGreen)
        }
    }
    Spacer()
}
```

**Step 4: Optimize timeline refresh to midnight**

In `MatrixHabitTimelineProvider.getTimeline`, replace the refresh policy:

```swift
// OLD:
let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!

// NEW:
let tomorrow = Calendar.current.startOfDay(
    for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!
)
let nextUpdate = tomorrow
```

**Step 5: Build to verify**

Run: XcodeBuildMCP `build_sim` with scheme MatrixHabit
Expected: BUILD SUCCEEDED

**Step 6: Commit**

```bash
git add MatrixHabitWidget/MatrixHabitWidget.swift MatrixHabit.xcodeproj/project.pbxproj
git commit -m "feat(widget): wire lock screen widgets + interactive check-in to medium widget"
```

---

## Task 5: Create WidgetSyncService (Main App)

**Files:**
- Create: `Services/WidgetSyncService.swift` (main app target only)

**Step 1: Create the sync service**

Create `Services/WidgetSyncService.swift`:

```swift
import Foundation
import SwiftData
import WidgetKit

enum WidgetSyncService {

    /// Processes pending check-ins written by the widget extension.
    /// Call this when the app enters foreground.
    @MainActor
    static func syncPendingCheckIns(context: ModelContext) {
        let pending = WidgetDataManager.readPendingCheckIns()
        guard !pending.isEmpty else { return }

        // Fetch all habits once
        let allPowers = (try? context.fetch(FetchDescriptor<Power>())) ?? []
        let allAgents = (try? context.fetch(FetchDescriptor<Agent>())) ?? []

        for entry in pending {
            if entry.isPower {
                guard let power = allPowers.first(where: { $0.name == entry.habitName }) else { continue }
                CheckInService.recordPowerCheckIn(
                    power: power,
                    date: entry.date,
                    context: context
                )
            } else {
                guard let agent = allAgents.first(where: { $0.name == entry.habitName }) else { continue }
                CheckInService.recordAgentResistance(
                    agent: agent,
                    date: entry.date,
                    context: context
                )
            }
        }

        // Clear pending regardless of individual success/failure
        // (duplicates are handled by CheckInService returning .duplicateCheckIn)
        WidgetDataManager.clearPendingCheckIns()
    }
}
```

**Step 2: Add file to main app target in Xcode project**

Add `WidgetSyncService.swift` to the **MatrixHabit** target only (not widget).

**Step 3: Build to verify**

Run: XcodeBuildMCP `build_sim` with scheme MatrixHabit
Expected: BUILD SUCCEEDED

**Step 4: Commit**

```bash
git add Services/WidgetSyncService.swift MatrixHabit.xcodeproj/project.pbxproj
git commit -m "feat(widget): add WidgetSyncService to process pending widget check-ins"
```

---

## Task 6: Wire WidgetSyncService into App Lifecycle

**Files:**
- Modify: `MatrixHabitApp.swift`

**Step 1: Add sync call to scenePhase .active handler**

In `MatrixHabitApp.swift`, find the `.onChange(of: scenePhase)` block (around line 55-62). Add the sync call inside the `if newPhase == .active` block:

```swift
// CURRENT (line 55-62):
.onChange(of: scenePhase) { _, newPhase in
    if newPhase == .active {
        DateHelper.invalidateCache()
        Task { @MainActor in
            NotificationManager.shared.clearBadge()
        }
    }
}

// NEW:
.onChange(of: scenePhase) { _, newPhase in
    if newPhase == .active {
        DateHelper.invalidateCache()
        Task { @MainActor in
            NotificationManager.shared.clearBadge()
            if let context = container.mainContext as? ModelContext {
                WidgetSyncService.syncPendingCheckIns(context: context)
            }
        }
    }
}
```

**Note:** `container` is the `sharedModelContainer` already unwrapped by the `if let container = sharedModelContainer` guard. `container.mainContext` is directly a `ModelContext`, so the cast is unnecessary. Simplified:

```swift
.onChange(of: scenePhase) { _, newPhase in
    if newPhase == .active {
        DateHelper.invalidateCache()
        Task { @MainActor in
            NotificationManager.shared.clearBadge()
            WidgetSyncService.syncPendingCheckIns(context: container.mainContext)
        }
    }
}
```

**Step 2: Build to verify**

Run: XcodeBuildMCP `build_sim` with scheme MatrixHabit
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add MatrixHabitApp.swift
git commit -m "feat(widget): sync pending widget check-ins on app foreground"
```

---

## Task 7: Add Lock Screen Widget Previews

**Files:**
- Modify: `MatrixHabitWidget/MatrixHabitWidget.swift`

**Step 1: Add preview blocks for lock screen widgets**

Add at the bottom of `MatrixHabitWidget.swift`, below the existing `#Preview`:

```swift
#Preview(as: .systemMedium) {
    MatrixHabitWidget()
} timeline: {
    MatrixHabitEntry(date: Date(), data: WidgetHabitData(
        habits: [
            HabitSnapshot(name: "Lock In", icon: "brain", streak: 32, completedToday: true, isPower: true),
            HabitSnapshot(name: "Combat Prep", icon: "dumbbell.fill", streak: 21, completedToday: false, isPower: true),
            HabitSnapshot(name: "Doomscrolling", icon: "iphone.slash", streak: 14, completedToday: false, isPower: false),
            HabitSnapshot(name: "Deep Sleep", icon: "moon.zzz.fill", streak: 7, completedToday: true, isPower: true)
        ],
        totalStreak: 74,
        completedToday: 2,
        totalScheduledToday: 4,
        lastUpdated: Date()
    ))
}

#Preview(as: .accessoryCircular) {
    MatrixHabitWidget()
} timeline: {
    MatrixHabitEntry(date: Date(), data: WidgetHabitData(
        habits: [
            HabitSnapshot(name: "Lock In", icon: "brain", streak: 32, completedToday: true, isPower: true),
            HabitSnapshot(name: "Combat Prep", icon: "dumbbell.fill", streak: 21, completedToday: false, isPower: true)
        ],
        totalStreak: 53,
        completedToday: 1,
        totalScheduledToday: 3,
        lastUpdated: Date()
    ))
}

#Preview(as: .accessoryRectangular) {
    MatrixHabitWidget()
} timeline: {
    MatrixHabitEntry(date: Date(), data: WidgetHabitData(
        habits: [
            HabitSnapshot(name: "Lock In", icon: "brain", streak: 32, completedToday: false, isPower: true),
            HabitSnapshot(name: "Combat Prep", icon: "dumbbell.fill", streak: 21, completedToday: false, isPower: true),
            HabitSnapshot(name: "Doomscrolling", icon: "iphone.slash", streak: 14, completedToday: true, isPower: false)
        ],
        totalStreak: 67,
        completedToday: 1,
        totalScheduledToday: 3,
        lastUpdated: Date()
    ))
}
```

**Step 2: Build to verify**

Run: XcodeBuildMCP `build_sim` with scheme MatrixHabit
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add MatrixHabitWidget/MatrixHabitWidget.swift
git commit -m "feat(widget): add lock screen and medium widget previews"
```

---

## Summary

| Task | What | Files | Commit |
|------|------|-------|--------|
| 1 | Pending check-in storage | `WidgetDataManager.swift` | `feat(widget): add pending check-in storage` |
| 2 | CheckInHabitIntent | `CheckInHabitIntent.swift` (new, both targets) | `feat(widget): add CheckInHabitIntent` |
| 3 | Lock screen views | `LockScreenWidgets.swift` (new, widget target) | `feat(widget): add lock screen widget views` |
| 4 | Wire everything into main widget | `MatrixHabitWidget.swift` | `feat(widget): wire lock screen + interactive` |
| 5 | Widget sync service | `WidgetSyncService.swift` (new, app target) | `feat(widget): add WidgetSyncService` |
| 6 | App lifecycle integration | `MatrixHabitApp.swift` | `feat(widget): sync on app foreground` |
| 7 | Previews | `MatrixHabitWidget.swift` | `feat(widget): add previews` |

**Total: 3 new files, 3 modified files, 7 commits**

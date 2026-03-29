# Lock Screen Widgets + Interactive Check-In — Design

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add 3 lock screen widget variants and upgrade the existing medium widget with tap-to-check-in interactivity.

**Architecture:** AppIntent writes pending check-ins to shared UserDefaults via App Groups. Main app syncs to SwiftData on foreground. No SwiftData in widget process.

**Tech Stack:** WidgetKit, AppIntents, SwiftUI, UserDefaults (App Groups)

---

## Feature 1: Lock Screen Widgets

### accessoryCircular — Progress Ring
- Circular `Gauge` with `.accessoryCircularCapacity` style
- Shows `X/Y` daily completion inside the ring
- Ring fills proportionally
- Empty state: "—" with empty ring
- Tap opens app to Command Center

### accessoryRectangular — Terminal Habit List
- Monospaced, uppercase, `>` prefix for terminal aesthetic
- Shows top 2 uncompleted habits with streak count
- Bottom line: remaining count or "ALL CLEAR"
- If all complete: top 2 completed with checkmarks

### accessoryInline — Single Line
- `bolt.fill` SF Symbol + "X/Y COMPLETE"
- If all done: "ALL SIGNALS ACTIVE"

**All lock screen widgets are monochrome** — iOS controls tinting.

---

## Feature 2: Interactive Medium Widget

### Check-In Flow
1. User taps circle icon on habit row
2. `CheckInHabitIntent` fires in widget extension process
3. Intent writes pending check-in to `com.matrixhabit.widget.pendingCheckins` in shared UserDefaults
4. Intent updates widget data snapshot (marks habit `completedToday = true`, increments count)
5. Widget auto-reloads — shows green checkmark

### Pending Check-In Format
```json
[
  { "habitName": "Lock In", "isPower": true, "date": "2026-03-29T00:00:00Z" }
]
```

### Main App Sync (on foreground)
1. Read pending check-ins from shared UserDefaults
2. For each: find matching Power/Agent by name → call CheckInService
3. Clear pending list
4. XP/achievements/widget refresh — normal flow

### Edge Cases
| Scenario | Behavior |
|----------|----------|
| Already completed today | Button disabled (checkmark, not tappable) |
| Not scheduled today | Not shown in widget |
| No widget data yet | "LOAD PROGRAM" empty state |
| Multiple taps before app opens | Deduplicated by name+date on sync |
| App opened days later | Pending entries carry their date |

---

## Architecture

### Files to Create
| File | Target | Purpose |
|------|--------|---------|
| `MatrixHabitWidget/LockScreenWidgets.swift` | Widget | 3 accessory widget views |
| `MatrixHabitWidget/CheckInHabitIntent.swift` | Both | AppIntent for widget check-in |
| `Services/WidgetSyncService.swift` | Main App | Syncs pending check-ins to SwiftData |

### Files to Modify
| File | Change |
|------|--------|
| `MatrixHabitWidget/MatrixHabitWidget.swift` | Add accessory families to supportedFamilies. Add lock screen views to switch. Add Button(intent:) to medium widget rows. |
| `Services/WidgetDataManager.swift` | Add pending check-in read/write/clear methods |
| `MatrixHabitApp.swift` | Call WidgetSyncService on .active scene phase |

### Data Flow
```
Widget tap → CheckInHabitIntent.perform()
  → Write to UserDefaults["pendingCheckins"]
  → Update UserDefaults["widget.data"]
  → Widget auto-reloads

App foreground → WidgetSyncService.syncPendingCheckIns()
  → Read pending from UserDefaults
  → CheckInService.record* for each
  → Clear pending
  → Normal XP/achievement flow
```

### Constraints
- Zero external dependencies
- No SwiftData in widget process
- CheckInHabitIntent.swift shared across both targets
- Existing App Group: `group.com.construct.MatrixHabit`

---

## Not in Scope
- Large widget
- Small widget progress ring enhancement
- Live Activities
- Deep link URL scheme
- StandBy mode optimization

---

*Approved 2026-03-29*

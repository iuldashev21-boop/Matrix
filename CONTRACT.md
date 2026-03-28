# MatrixHabit Bug Fix Contract

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this contract task-by-task.

**Goal:** Fix all discovered bugs, inconsistencies, and illogical behavior in MatrixHabit.

**Root cause cluster:** Most issues stem from **three independent check-in code paths** that diverged over time, plus **scheduled-day logic not applied uniformly**.

---

## CRITICAL (Data Correctness)

### C1: `needsRecovery` ignores scheduled days — false EMP recovery prompts on rest days

**Files:** `Models/Power.swift:77-93`, `Models/Agent.swift:87-108`

**Bug:** `needsRecovery` checks if yesterday had a check-in, but doesn't check if yesterday was a scheduled day. Users with Mon/Wed/Fri habits get false "needs recovery" prompts every Tue/Thu/Sat.

**Fix:** Add scheduled-day check — if yesterday wasn't scheduled, skip the recovery check. Walk back to find the last scheduled day before yesterday, check if THAT day has a check-in.

---

### C2: `CommandCenterView.submitAllHabits()` bypasses CheckInService entirely

**Files:** `Views/CommandCenterView.swift:279-349`

**Bug:** Dashboard "Submit All" creates check-ins directly, skipping:
- EMP token awards at milestones
- Widget data refresh (`WidgetCenter.shared.reloadAllTimelines()`)
- Achievement checks
- Proper duplicate prevention

**Fix:** Replace the inline implementation with a call to `CheckInService.submitAllHabits()`. Pass back the XP earned for UI feedback.

---

### C3: `DialInView` XP formula differs from `CheckInService`

**Files:** `Views/DialInView.swift:457,524`, `Services/CheckInService.swift:293-305`

**Bug:** Two different XP formulas:
- DialInView: 10 base + `streak * 5` at milestones (day 7 = 45 XP, day 66 = 340 XP)
- CheckInService: 10 base + 50 flat at milestones (day 7 = 60 XP, day 66 = 60 XP)

**Fix:** DialInView should use CheckInService for the check-in. The celebration UI can remain in DialInView but XP/EMP awards must come from the single source of truth.

---

### C4: Construct (sidequests) not behind paywall

**Files:** `Views/CommandCenterView.swift:680-693`

**Bug:** User request — The Construct section with all 4 sidequests is free. Should be locked behind Red Pill.

**Fix:** Wrap the Construct section tap/expand with a paywall check. If not premium, show paywall instead of expanding.

---

## HIGH (Significant UX Issues)

### H1: Dual UserDefaults keys for user name — reset doesn't clear dashboard name

**Files:** `Utilities/UserProfile.swift:9` (`"operativeName"`), `Utilities/UserDefaultsKeys.swift:9` (`"operatorName"`), `Views/AwakeningView.swift:530`, `Views/ZionMainframeView.swift:638-665`

**Bug:** Onboarding saves to `"operatorName"`, dashboard reads `"operatorName"`, but UserProfile stores/resets `"operativeName"`. After reset, `UserProfile.reset()` clears `"operativeName"` but NOT `"operatorName"` — so the dashboard still shows the old name after factory reset.

**Fix:** Unify to one key. `UserProfile` should use `"operatorName"`. AwakeningView should set via `UserProfile.operativeName`. Reset should clear the unified key.

---

### H2: Reset doesn't clear `hasSeenPostOnboardingPaywall`

**Files:** `ContentView.swift` (`@AppStorage("hasSeenPostOnboardingPaywall")`), `Views/ZionMainframeView.swift:638-665`

**Bug:** After factory reset + re-onboarding, the post-onboarding paywall never shows again.

**Fix:** Add `UserDefaults.standard.removeObject(forKey: "hasSeenPostOnboardingPaywall")` to `resetAllData()`.

---

### H3: `todayCompletedCount` vs `agentsCompletedCount` semantic mismatch

**Files:** `Views/CommandCenterView.swift:93-99`

**Bug:** `agentsCompletedCount` counts resisted OR relapsed (any interaction). `todayCompletedCount` only counts resisted (successful). Progress bar and system status can show different completion states.

**Fix:** Use consistent definition. `todayCompletedCount` should include relapsed agents since they've been "addressed" for the day.

---

### H4: DialInView "+10 XP" display is hardcoded

**Files:** `Views/DialInView.swift` (search for `+10 XP`)

**Bug:** Always shows "+10 XP" feedback after check-in, even when milestone bonus gives more.

**Fix:** Show actual XP earned from CheckInService result.

---

## MEDIUM (Consistency Issues)

### M1: `daysActiveCount` calculated differently in two views

**Files:** `Views/CommandCenterView.swift:111-114`, `Views/SignalAnalysisView.swift` (search for `daysActiveCount`)

**Bug:** CommandCenterView counts unique check-in dates. SignalAnalysisView counts calendar days since first check-in. Same label, different numbers.

**Fix:** Both should use unique check-in dates (the CommandCenterView approach is correct).

---

### M2: EMPRecoveryView uses raw date calculation instead of DateHelper

**Files:** `Views/EMPRecoveryView.swift:377`

**Bug:** Uses `Calendar.current.date(byAdding:)` directly instead of `DateHelper.yesterday`. Could produce different "yesterday" than the rest of the app at midnight.

**Fix:** Replace with `DateHelper.yesterday`.

---

### M3: Widget data not refreshed from Submit All path

**Files:** `Views/CommandCenterView.swift:279-349`

**Bug:** Submit All doesn't call `WidgetCenter.shared.reloadAllTimelines()`.

**Fix:** Resolved by C2 (switching to CheckInService).

---

### M4: SidequestManager uses different UserDefaults keys than UserDefaultsKeys enum

**Files:** `Utilities/SidequestManager.swift:29-38`, `Utilities/UserDefaultsKeys.swift:21-26`

**Bug:** SidequestManager defines its own key strings (`"sidequest_oracleUsesToday"`) while UserDefaultsKeys has different ones (`"sidequest_oracle_uses"`). Dead code — UserDefaultsKeys sidequest keys are never used.

**Fix:** Remove unused sidequest keys from UserDefaultsKeys or align them with SidequestManager.

---

## LOW (Edge Cases / Polish)

### L1: No model-level duplicate check-in prevention

**Bug:** Duplicates prevented only at service/UI level, not data model level. Possible via race conditions.

**Fix:** Defer — consolidating to CheckInService (C2, C3) reduces this risk sufficiently.

---

### L2: 66-day count = streak-days not calendar-days for non-daily habits

**Bug:** A Mon/Wed/Fri habit takes ~22 weeks (154 calendar days) to reach "66 days". May surprise users.

**Fix:** Defer — this is a design choice, not a bug. Document it.

---

## Execution Order

1. **H1** — Unify name keys (foundation fix, affects reset)
2. **C1** — Fix `needsRecovery` scheduled-day logic
3. **C3** — Wire DialInView through CheckInService (fixes XP + H4)
4. **C2** — Wire Submit All through CheckInService (fixes M3)
5. **H2** — Fix reset to clear all AppStorage keys
6. **H3** — Fix completion count consistency
7. **M1** — Fix daysActiveCount consistency
8. **M2** — Fix EMPRecoveryView date usage
9. **M4** — Clean up dead UserDefaultsKeys
10. **C4** — Lock Construct behind paywall
11. **Build & verify**

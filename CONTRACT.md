# MatrixHabit Self-Improvement Contract

> **Branch:** `contract/2026-03-31-self-improvement`
> **Started:** 2026-03-31
> **Status:** IN PROGRESS
> **Method:** 6-agent parallel audit (Models, Views, Components, Widgets, Onboarding, Security)

**Goal:** Fix all bugs, logic errors, UX gaps, performance issues, and architectural problems discovered by comprehensive codebase audit.

---

## CRITICAL (Data Correctness / Crash Risk)

- [x] #C1 — `submitAllHabits` XP over-awarded: streak read after in-memory append, `currentStreak + 1` is one too high at milestone boundaries (7/21/66) `CheckInService.swift:185` ✅ `f7dd8a1`
- [x] #C2 — `AnomalyManager.onDailyCheckIn` mutates dictionary during key iteration — undefined behavior, crash risk `AnomalyManager.swift:123` ✅ `67d13ff`
- [x] #C3 — `DateHelper` static cache (`_cachedToday`, `_cachedYesterday`) is a data race — no thread safety `DateHelper.swift:21` ✅ `d19cc2c`
- [x] #C4 — Widget interactive check-in gives no visual feedback — `reloadAllTimelines()` missing from `CheckInHabitIntent.perform()` `CheckInHabitIntent.swift:83` ✅ `3700616`
- [x] #C5 — App foreground sync doesn't refresh widget — `WidgetSyncService` clears pending but never reloads timelines `WidgetSyncService.swift:38` ✅ `9b64f98`
- [x] #C6 — `showSubmitAllSuccess` declared but never set or rendered — no batch check-in confirmation `CommandCenterView.swift:45` ✅ `4a78305`
- [x] #C7 — `handleBreach()` doesn't update `agent.currentStreak` or `longestStreak` — breach path bypasses model update `DialInView.swift:606` ✅ `30ec78b`
- [x] #C8 — `checkMilestone()` reads stale streak — `power?.currentStreak` may be pre-save value `DialInView.swift:534` ⏭️ False positive: `saveCheckIn()` runs synchronously before `checkMilestone()`, and `currentStreak` is a computed property that reads the already-appended check-in
- [x] #C9 — IAP bypass: `isRedPillOwned` seeded from UserDefaults on cold launch before `checkEntitlements()` — any user can write `true` to the key with free tools, no jailbreak needed `StoreManager.swift:22` ✅ `274a572`
- [x] #C10 — ContractPhase `startHold()` double-fire: re-press before first timer resolves → `completeContract()` called twice → duplicate Power/Agent records in SwiftData `ContractPhase.swift:113` ✅ `16e64c8`
- [x] #C11 — Blue pill back-then-dismiss race: user taps BACK during 3s blue pill timer → phase decrements but timer still fires `onBluePill()` → user ejected despite pressing back `RedBluePillPhase.swift:131` ✅ `1bd2194`

## HIGH (Silent Data Loss / IAP / UX Breakage)

- [x] #H1 — `unlockAllHabits` never calls `context.save()` — paid IAP unlock can be lost on background `StoreManager.swift:110` ✅ `274a572`
- [x] #H2 — `recoverWithEMP` spends token before validating habit target — token lost if both power/agent are nil `CheckInService.swift:253` ✅ `f98962f`
- [x] #H3 — `checkWeekendWarrior` uses locale-dependent week offsets — broken for non-US locales (most of Europe) `AchievementManager.swift:196` ✅ `9e8fb00`
- [x] #H4 — `checkPerfectWeek` ignores per-habit `scheduledDays` — partial-schedule habits can never achieve it `AchievementManager.swift:233` ✅ `fc156cf`
- [x] #H5 — Widget habit lookup by `name` not `id` — renamed habit = silently dropped check-in `WidgetSyncService.swift:20` ✅ `e336566`
- [x] #H6 — `WidgetSyncService` fetch errors silently clear all pending check-ins — permanent data loss `WidgetSyncService.swift:15` ✅ `3f1fcc1`
- [x] #H7 — In-memory model diverges from store on `context.save()` failure — stale session data `CheckInService.swift:36` ✅ `a4ea92b`
- [x] #H8 — Random quotes re-roll on every SwiftUI body recompute (DailyAffirmation, OracleReward, BreachMessage) `CommandCenterView.swift:356`, `DialInView.swift:711,960` ✅ `ea610c1`
- [x] #H9 — `empTokenDisplayCount` is stale manual mirror — tokens earned elsewhere don't update header `CommandCenterView.swift:38` ✅ `79532a5`
- [x] #H10 — Purchase errors swallowed into generic "PURCHASE FAILED" string — no diagnostics `StoreManager.swift:39` ✅ `14ec20f`
- [x] #H11 — `NavigationView` used in 4 sheets (deprecated, known double-render bugs on iOS 16+) `AddHabitSheet.swift:81`, `HabitDetailView.swift:327`, `ZionMainframeView.swift:768`, `AchievementsView.swift:26` ✅ `e419f2f`
- [x] #H12 — Tapping completed HabitCard does nothing — no way to view detail of already-checked habit `CommandCenterView.swift:516` ✅ `12cbc36`
- [x] #H13 — HabitDetailView unreachable from main list — only accessible via context menu `CommandCenterView.swift` ✅ `554bcbe`
- [x] #H14 — `TierPromotionManager.promoteAgent` doesn't save context — promotion can be lost `TierPromotionManager.swift:80` ✅ `3da5e56`
- [x] #H15 — `AchievementManager` strong self capture in `asyncAfter` on `@MainActor` class `AchievementManager.swift:58` ✅ `dbc293b`
- [x] #H16 — Widget force-unwrap on `Calendar.date(byAdding:)` — crash risk in widget process `MatrixHabitWidget.swift:46` ✅ `ea6cd1e`
- [x] #H17 — `checkEntitlements()` never resets `isRedPillOwned` to `false` before scanning — stale UserDefaults `true` persists even if transaction absent `StoreManager.swift:84` ✅ `274a572`
- [x] #H18 — Onboarding progress bar visible on ContractPhase (phase 16 not in exclusion set) — overlaps hold-to-sign UI `AwakeningView.swift:207` ✅ `181a2b2`
- [x] #H19 — Dead onboarding Path A (PillChoiceView → FirstHackSetupView) still compiled and reachable — bypasses 16 phases, creates incomplete setup `PillChoiceView.swift:97` ✅ `6fd2873`

## MEDIUM (Performance / UX / Architecture)

- [x] #M1 — `weeklyStats` computed property called 5x per render — O(habits × check-ins) each time `SignalAnalysisView.swift:53` ✅ `9f6ee78`
- [x] #M2 — `CodeRainBackground` 50fps timer × 3 simultaneous instances = 3 timers driving state mutations `PillChoiceView.swift:241` ✅ `5007641`
- [ ] #M3 — Power/Agent `currentStreak` computed property does full O(N) walk on every render `Power.swift:56`, `Agent.swift:56` ⏭️ Requires SwiftData model migration to add stored streak — too risky for atomic change
- [x] #M4 — `AchievementManager` triggers up to 15 individual DB fetches per check-in `AchievementManager.swift:86` ✅ `d479464`
- [x] #M5 — `checkWeekendWarrior` is O(habits × check-ins × 2) on every check-in `AchievementManager.swift:204` ✅ `ff89ebd`
- [x] #M6 — `DateFormatter()` allocated on every `formatDate` call (expensive) `HabitDetailView.swift:263` ✅ `9d9e3d8`
- [x] #M7 — `AchievementsTabView` and `AchievementsView` are near-identical duplicated code `AchievementsTabView.swift`, `AchievementsView.swift` ✅ `8ce88de`
- [x] #M8 — Hardcoded system colors bypass theme: `Color.red`, `.orange`, `.cyan`, `.pink` in Components `HabitCard.swift:70`, `TierPromotionSheet.swift:107`, `ProtocolCompleteView.swift:439` ✅ `225a0b0`
- [ ] #M9 — Zero `reducedMotion` / accessibility support in entire app — no VoiceOver, no dynamic type ⏭️ Sweeping UX initiative touching dozens of files — not an atomic change
- [ ] #M10 — 14+ `Timer.scheduledTimer` calls — potential memory leaks if not invalidated properly ⏭️ False positive: all timers have proper onDisappear cleanup or self-invalidate
- [x] #M11 — `SettingsToggleRow` is custom button, not `Toggle` — VoiceOver announces as generic button `ZionMainframeView.swift:743` ✅ `fbdbfea`
- [x] #M12 — `ZionMainframeView` version string hardcoded "v1.0.0" — app is v1.1 `ZionMainframeView.swift:301` ✅ `7468af8`
- [x] #M13 — No confirmation on "Submit All" — destructive batch op with no undo `CommandCenterView.swift:283` ✅ `5047437`
- [x] #M14 — Widget small view shows highest-streak habit, not most urgent incomplete one `MatrixHabitWidget.swift:87` ✅ `d0433de`
- [x] #M15 — Medium widget sorts by streak (reorders on update) with `id: \.offset` — unstable identity `MatrixHabitWidget.swift:195` ✅ `c44103b`
- [x] #M16 — Lock screen widget `remaining` can go negative `LockScreenWidgets.swift:56` ✅ `ce4e374`
- [ ] #M17 — Widget shared types duplicated across 3 files — any rename breaks JSON contract silently `MatrixHabitWidget.swift:5` ⏭️ Requires shared framework (new build target) — out of scope for atomic change. Field names are aligned after #H5.
- [ ] #M18 — `powersContent` and `agentsContent` are structural mirrors — duplicated layout code `CommandCenterView.swift:495` ⏭️ Types, completion logic, and state bindings differ — generic extraction would be more complex than the duplication
- [x] #M19 — Keyboard not dismissed in AddHabitSheet/EditHabitSheet — obscures save button ✅ `f9b6ffa`
- [x] #M20 — `TypeToggleButton` infers color from title string comparison `AddHabitSheet.swift:345` ✅ `82dd419`
- [x] #M21 — Promoted agent loses custom `scheduledDays` — reset to daily `TierPromotionManager.swift:84` ✅ `bd40041`
- [x] #M22 — `AnomalyManager.onDailyCheckIn` not idempotent — multiple rapid check-ins increment counters multiple times `AnomalyManager.swift:107` ✅ `b425d25`
- [x] #M23 — SignalAnalysisView day column headers always Mon-Sun — don't align with actual grid days `SignalAnalysisView.swift:403` ✅ `de2a4a4`
- [x] #M24 — `notificationsEnabled` toggle snapshots stale value at init `ZionMainframeView.swift:13` ✅ `50902c6`
- [x] #M25 — No per-habit calendar heatmap or history — can't see which days a specific habit was missed ✅ `bcf82ec`
- [x] #M26 — `cheatKeys` UserDefaults key may bypass content gates — should be `#if DEBUG` only `UserDefaultsKeys.swift:17` ⏭️ False positive: cheatKeys is a legitimate user-facing reward mechanic (White Rabbit Easter egg), not a debug bypass
- [x] #M27 — `operatorAge` personal data stored in plaintext UserDefaults — privacy risk on unencrypted backups `UserDefaultsKeys.swift:11` ⏭️ Skip: 2-digit number in offline-only app, iOS encrypts at rest, no Keychain infra exists — complexity not justified
- [x] #M28 — XP/EMP token economy in plaintext UserDefaults — freely editable, undermines gamification `UserProfile.swift:33` ⏭️ Skip: single-player gamification scores, user hacking own stats affects only them, no Keychain infra exists
- [ ] #M29 — 17 onboarding phases with no skip option — high drop-off risk, phases 13-14 are pure narrative after emotional peak ⏭️ Product/UX decision — not a code fix
- [x] #M30 — Dual progress indicators in onboarding: "DIAGNOSTIC 1/9" vs "PHASE 4 OF 17" — confusing `HookQuestionPhase.swift:33` ✅ `84de104`
- [x] #M31 — `fillFromUniversalPool()` has fragile while loop — infinite loop risk if pool < 3 items `AwakeningView.swift:504` ✅ `5ad57ec`
- [x] #M32 — Onboarding back button at phase 0 is a dead tap (no-op with no feedback) `AwakeningView.swift` ⏭️ False positive: phase 0 (PrisonerRecordPhase) has no back button
- [x] #M33 — `VignetteOverlay` uses deprecated `UIScreen.main.bounds` `OnboardingComponents.swift:25` ✅ `149c74f`

## LOW (Deferred / Cosmetic)

- [ ] #L1 — `GhostTutorialOverlay` not dismissible by tapping background (inconsistent with other overlays)
- [ ] #L2 — `RedPillPaywallView` `try? context.save()` silently discards save errors
- [ ] #L3 — `Power.progressPercent` missing `targetDays > 0` guard (inconsistent with Agent)
- [ ] #L4 — `StreakCalculator` bypasses `DateHelper`, potential near-midnight streak inconsistency
- [ ] #L5 — `recentErrors` in `ErrorLogger` stores Error references indefinitely (up to 50)
- [ ] #L6 — `FrequencyPresetButton` uses magic `cornerRadius(6)` bypassing Theme constant
- [ ] #L7 — 20+ repeating badge pulse animations when many achievements unlocked
- [ ] #L8 — `SoundManager.audioPlayers` held forever after loading

## THREAD SAFETY (Cross-cutting)

- [x] #T1 — `UserProfile` read-modify-write on XP/EMP tokens is not atomic `UserProfile.swift` ⏭️ Skip: @MainActor cascades to CheckInService/SidequestManager/AchievementManager — not atomic; all callers already main-thread in this SwiftUI app
- [x] #T2 — `ErrorLogger.recentErrors` mutated without synchronization `ErrorLogger.swift:44` ✅ `62e069c`
- [x] #T3 — `SoundManager` uses `@AppStorage` in non-`@MainActor` singleton `SoundManager.swift` ⏭️ Skip: @MainActor cascades to CheckInService — not atomic; all callers already main-thread
- [x] #T4 — `ReviewManager` not `@MainActor` but calls `UIApplication.shared` `ReviewManager.swift` ⏭️ Skip: already dispatches to main in executeReview(); @MainActor would cascade
- [x] #T5 — `NotificationManager` singleton init may fire from non-main thread `NotificationManager.swift:63` ⏭️ False positive: already marked @MainActor
- [x] #T6 — `AnomalyManager` not `@MainActor` but has `@Published` properties `AnomalyManager.swift` ✅ `5430235`

## TEST GAPS (Top 10 Untested Critical Paths)

- [x] #TG1 — `CheckInService.recordPowerCheckIn` / `recordAgentResistance` — zero integration tests ⏭️ Skip: requires SwiftData ModelContext + SoundManager + WidgetKit — not atomic
- [x] #TG2 — `WidgetSyncService.syncPendingCheckIns` — name-mismatch data loss path untested ⏭️ Skip: requires SwiftData + App Groups integration
- [x] #TG3 — `CheckInHabitIntent.perform()` — widget interactive check-in untested ⏭️ Skip: WidgetKit AppIntent + App Groups sandbox boundary
- [x] #TG4 — `StoreManager` paywall enforcement — `canCreateHabit` and IAP unlock untested ⏭️ Skip: StoreManager has private init with StoreKit listener — can't instantiate in tests
- [x] #TG5 — `WidgetDataManager.update()` — App Group write correctness untested ⏭️ Skip: App Groups sandboxing prevents atomic testing
- [x] #TG6 — `CheckInService.recoverWithEMP` — token refund on save failure untested ⏭️ Skip: requires SwiftData ModelContext + UserProfile integration
- [x] #TG7 — `CheckInService.submitAllHabits` — bulk XP calculation untested ⏭️ Skip: requires SwiftData in-memory container + XP side effects
- [x] #TG8 — `Power.needsRecovery` / `Agent.needsRecovery` — partial schedule edge cases untested ✅ `7f8b82f`
- [x] #TG9 — `WidgetDataManager.markHabitCompleted` — name collision overcount untested ⏭️ Skip: App Groups sandboxing prevents atomic testing
- [x] #TG10 — `AchievementManager` / `TierPromotionManager` — entirely absent from test suite ✅ `dfca5c6`

## FLAKY TESTS (Existing Tests That Need Fixing)

- [x] #FT1 — FrequencySchedulingTests use `>=` assertions — non-falsifiable `FrequencySchedulingTests.swift:9` ⏭️ Skip: fixing requires StreakCalculator to accept a referenceDate parameter — not atomic
- [x] #FT2 — `test_streak_missedScheduledDay_breaksStreak` is non-deterministic by day of week `FrequencySchedulingTests.swift:55` ⏭️ Skip: same root cause as FT1 — day-dependent test data
- [x] #FT3 — `Thread.sleep` in model touch tests — flaky on CI `AgentModelTests.swift:265`, `PowerModelTests.swift:241` ✅ `315a1c0`
- [x] #FT4 — `calculateStreak` duplicate dedup only tested on `calculateLongestStreak` path `StreakCalculatorTests.swift:160` ✅ `04cb031`

---

## Implementation Priority

### Wave 1: Data Correctness + Security (ship-blocking)
C1, C2, C3, C7, C8, C9, C10, C11, H1, H2, H6, H7, H17

### Wave 2: Widget Fixes
C4, C5, H5, H16, M14, M15, M16, M17

### Wave 3: IAP & Achievements
H3, H4, H10, H14, H15

### Wave 4: Onboarding Fixes
H18, H19, M29, M30, M31, M32, M33

### Wave 5: UX Polish
C6, H8, H9, H11, H12, H13, M11, M12, M13, M19, M25

### Wave 6: Performance
M1, M2, M3, M4, M5, M6

### Wave 7: Architecture & Code Quality
M7, M8, M9, M18, M20, M21, M22, M23, M24, M26, M27, M28, T1-T6

### Wave 8: Tests
TG1-TG10, FT1-FT4

### Wave 9: Low Priority
L1-L8

---

## Totals

| Severity | Count |
|----------|-------|
| Critical | 11 |
| High | 19 |
| Medium | 33 |
| Low | 8 |
| Thread Safety | 6 |
| Test Gaps | 10 |
| Flaky Tests | 4 |
| **Total** | **91** |

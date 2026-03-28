# MatrixHabit Bug Fix Contract

> **Branch:** `contract/2026-03-28-bugfixes`
> **Started:** 2026-03-28
> **Status:** COMPLETE

**Goal:** Fix all discovered bugs, inconsistencies, and illogical behavior in MatrixHabit.

**Root cause cluster:** Most issues stem from **three independent check-in code paths** that diverged over time, plus **scheduled-day logic not applied uniformly**.

---

## CRITICAL (Data Correctness)

- [x] #C1 — `needsRecovery` ignores scheduled days — false EMP recovery prompts on rest days `fbaced3`
- [x] #C2 — `CommandCenterView.submitAllHabits()` bypasses CheckInService entirely `ab89db1`
- [x] #C3 — `DialInView` XP formula differs from `CheckInService` `a7fb84b`
- [x] #C4 — Construct (sidequests) not behind paywall `9521e87`

## HIGH (Significant UX Issues)

- [x] #H1 — Dual UserDefaults keys for user name — reset doesn't clear dashboard name `55e6ea1`
- [x] #H2 — Reset doesn't clear `hasSeenPostOnboardingPaywall` and other AppStorage keys `f47baf9`
- [x] #H3 — `todayCompletedCount` vs `agentsCompletedCount` semantic mismatch `c18a0f1`
- [x] #H4 — DialInView "+10 XP" display is hardcoded (fixed with C3) `a7fb84b`

## MEDIUM (Consistency Issues)

- [x] #M1 — `daysActiveCount` calculated differently in two views `ad38d49`
- [x] #M2 — EMPRecoveryView uses raw date calculation instead of DateHelper `a32d348`
- [x] #M3 — Widget data not refreshed from Submit All path (fixed with C2) `ab89db1`
- [x] #M4 — Dead sidequest keys in UserDefaultsKeys `81797f1`

## LOW (Deferred)

- [ ] #L1 — No model-level duplicate check-in prevention (risk mitigated by CheckInService consolidation)
- [ ] #L2 — 66-day count = streak-days not calendar-days for non-daily habits (design choice)

---

## Completed (10 items)

| # | Commit | Description |
|---|--------|-------------|
| H1 | `55e6ea1` | Unified user name to single UserDefaults key |
| C1 | `fbaced3` | needsRecovery respects scheduled days |
| C3+H4 | `a7fb84b` | Wired DialInView through CheckInService, dynamic XP display |
| C2+M3 | `ab89db1` | Wired Submit All through CheckInService |
| H2 | `f47baf9` | Reset clears all AppStorage keys |
| H3 | `c18a0f1` | todayCompletedCount includes addressed agents |
| M1 | `ad38d49` | Unified daysActiveCount to unique check-in dates |
| M2 | `a32d348` | EMPRecoveryView uses DateHelper.yesterday |
| M4 | `81797f1` | Removed dead sidequest keys from UserDefaultsKeys |
| C4 | `9521e87` | Locked The Construct behind Red Pill paywall |

## Reverted / Skipped

| # | Reason |
|---|--------|
| L1 | Deferred — CheckInService consolidation mitigates risk |
| L2 | Deferred — design choice, not a bug |

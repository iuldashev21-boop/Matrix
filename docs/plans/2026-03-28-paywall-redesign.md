# Paywall Redesign — Show-But-Lock Strategy

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Maximize paywall conversion by showing locked personalized habits on the dashboard and triggering the paywall aggressively on all creation/unlock attempts.

**Problem:** Onboarding creates 6 free habits but paywall gates at 3, so users rarely hit it.

**Solution:** Onboarding creates 6 habits (2 active, 4 locked). Free limit = 2. Any add/unlock attempt triggers paywall. Paywall auto-shows after onboarding.

---

## Data Model Changes

- `Power` model: add `var isLocked: Bool = false`
- `Agent` model: add `var isLocked: Bool = false`
- Default `false` preserves existing App Store users' data (no migration needed)

## StoreManager Changes

- `freeHabitLimit = 2` (was 3)
- `canCreateHabit()` counts only unlocked habits
- New: `unlockAllHabits(context:)` — bulk sets `isLocked = false` on purchase

## Onboarding Changes (AwakeningView)

- `finalizeAwakening()`: first Power + first Agent → `isLocked = false`, remaining 4 → `isLocked = true`
- After onboarding completes → auto-present Red Pill paywall (dismissible)

## Dashboard Changes (CommandCenterView)

- Locked habits render at 40% opacity with red pill icon overlay
- No check-in button on locked habits
- Tapping locked habit → paywall
- Both "LOAD PROGRAM" buttons → paywall for free users (0 free adds)

## Paywall Changes (RedPillPaywallView)

Updated copy:
- "YOUR AWAKENING IS INCOMPLETE"
- Unlock all personalized habits
- Create unlimited custom programs
- Home screen widgets
- Advanced signal analysis
- Streak shield protocol
- "ONE-TIME PURCHASE. NO SUBSCRIPTION. YOURS FOREVER."
- "YOUR DATA NEVER LEAVES YOUR DEVICE. NO ACCOUNTS. NO TRACKING. 100% PRIVATE."
- "NOT NOW" dismiss button

## Paywall Trigger Points (4)

1. Auto-show after onboarding completion
2. Tap any locked habit on dashboard
3. Tap "LOAD PROGRAM" button (top section)
4. Tap "LOAD PROGRAM" button (tab bar)

## On Purchase

- Bulk unlock all habits (`isLocked = false`)
- Enable unlimited habit creation
- Auto-dismiss paywall

## Existing Users

- `isLocked` defaults to `false` → all existing habits remain unlocked
- Existing free users who already have >2 habits are unaffected (they already created them)
- Paywall only gates NEW creation attempts

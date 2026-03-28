# Paywall Redesign Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Maximize paywall conversion by showing locked personalized habits and triggering paywall aggressively — users see the paywall within their first session.

**Architecture:** Add `isPremiumLocked` property to Power/Agent models. Onboarding creates 6 habits (2 active, 4 locked). Free limit drops to 2. Locked habits render dimmed with red pill overlay. Four paywall entry points: post-onboarding auto-show, tap locked habit, both "LOAD PROGRAM" buttons.

**Tech Stack:** Swift, SwiftUI, SwiftData, StoreKit 2

---

### Task 1: Add `isPremiumLocked` to Power Model

**Files:**
- Modify: `Models/Power.swift:5-33`

**Step 1: Add the property and update init**

Add `var isPremiumLocked: Bool` to the model and a parameter to `init`:

```swift
@Model
final class Power {
    var id: UUID
    var name: String
    var icon: String
    var createdAt: Date
    var updatedAt: Date
    var targetDays: Int
    var isUnlocked: Bool
    var unlockedAt: Date?
    var isPremiumLocked: Bool

    /// Days of week habit is scheduled (1=Sun, 2=Mon, 3=Tue, 4=Wed, 5=Thu, 6=Fri, 7=Sat)
    /// Empty array or all days = daily habit
    var scheduledDays: [Int]

    @Relationship(deleteRule: .cascade, inverse: \CheckIn.power)
    var checkIns: [CheckIn]

    init(name: String, icon: String = "bolt", scheduledDays: [Int] = [1, 2, 3, 4, 5, 6, 7], isPremiumLocked: Bool = false) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.createdAt = Date()
        self.updatedAt = Date()
        self.targetDays = Theme.habitFormationDays
        self.isUnlocked = false
        self.unlockedAt = nil
        self.isPremiumLocked = isPremiumLocked
        self.scheduledDays = scheduledDays
        self.checkIns = []
    }
```

**Step 2: Build to verify**

Run: XcodeBuildMCP `build_sim`
Expected: Build succeeds. SwiftData handles the new property with default value automatically (lightweight migration).

**Step 3: Commit**

```bash
git add Models/Power.swift
git commit -m "feat: add isPremiumLocked to Power model"
```

---

### Task 2: Add `isPremiumLocked` to Agent Model

**Files:**
- Modify: `Models/Agent.swift:5-33`

**Step 1: Add the property and update init**

Same pattern as Power:

```swift
@Model
final class Agent {
    var id: UUID
    var name: String
    var icon: String
    var createdAt: Date
    var updatedAt: Date
    var targetDays: Int
    var isDefeated: Bool
    var defeatedAt: Date?
    var isPremiumLocked: Bool

    /// Days of week habit is scheduled (1=Sun, 2=Mon, 3=Tue, 4=Wed, 5=Thu, 6=Fri, 7=Sat)
    /// Empty array or all days = daily habit
    var scheduledDays: [Int]

    @Relationship(deleteRule: .cascade, inverse: \CheckIn.agent)
    var checkIns: [CheckIn]

    init(name: String, icon: String = "xmark.shield", scheduledDays: [Int] = [1, 2, 3, 4, 5, 6, 7], isPremiumLocked: Bool = false) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.createdAt = Date()
        self.updatedAt = Date()
        self.targetDays = Theme.habitFormationDays
        self.isDefeated = false
        self.defeatedAt = nil
        self.isPremiumLocked = isPremiumLocked
        self.scheduledDays = scheduledDays
        self.checkIns = []
    }
```

**Step 2: Build to verify**

Run: XcodeBuildMCP `build_sim`
Expected: Build succeeds.

**Step 3: Commit**

```bash
git add Models/Agent.swift
git commit -m "feat: add isPremiumLocked to Agent model"
```

---

### Task 3: Update StoreManager — Free Limit & Unlock Logic

**Files:**
- Modify: `Services/StoreManager.swift:17,97-108`

**Step 1: Change free limit and add unlock method**

```swift
static let freeHabitLimit = 2  // was 3
```

Update `canCreateHabit` to count only unlocked habits:

```swift
func canCreateHabit(currentCount: Int) -> Bool {
    isRedPillOwned || currentCount < StoreManager.freeHabitLimit
}
```

Note: callers must now pass count of **non-locked** habits only. We'll update callers in Task 6.

Add bulk unlock method at the end of the class (before closing `}`):

```swift
func unlockAllHabits(powers: [Power], agents: [Agent]) {
    for power in powers where power.isPremiumLocked {
        power.isPremiumLocked = false
        power.touch()
    }
    for agent in agents where agent.isPremiumLocked {
        agent.isPremiumLocked = false
        agent.touch()
    }
}
```

**Step 2: Build to verify**

Run: XcodeBuildMCP `build_sim`
Expected: Build succeeds.

**Step 3: Commit**

```bash
git add Services/StoreManager.swift
git commit -m "feat: update free limit to 2 and add unlockAllHabits"
```

---

### Task 4: Update Onboarding — Lock 4 of 6 Habits

**Files:**
- Modify: `Views/AwakeningView.swift:529-558`

**Step 1: Update `finalizeAwakening()` to lock extras**

Replace the habit creation loops with locked logic. The first Power and first Agent are active, the rest are locked:

```swift
private func finalizeAwakening() {
    UserDefaults.standard.set(operatorName, forKey: UserDefaultsKeys.operatorName)
    UserDefaults.standard.set(Int(operatorAge) ?? 25, forKey: UserDefaultsKeys.operatorAge)

    if suggestedLoadout.hacks.isEmpty {
        suggestedLoadout.hacks = [.touchGrass, .hydrationMax, .morningWin]
    }
    if suggestedLoadout.agents.isEmpty {
        suggestedLoadout.agents = [.noBrainRot, .noJunkMeals, .noBedScrolling]
    }

    for (index, hack) in suggestedLoadout.hacks.enumerated() {
        let power = Power(name: hack.habitName, icon: hack.icon, isPremiumLocked: index > 0)
        modelContext.insert(power)
    }

    for (index, agent) in suggestedLoadout.agents.enumerated() {
        let agentModel = Agent(name: agent.habitName, icon: agent.icon, isPremiumLocked: index > 0)
        modelContext.insert(agentModel)
    }

    do {
        try modelContext.save()
        UserProfile.completeOnboarding()
        isPresented = false
    } catch {
        ErrorLogger.logSaveFailure(error, context: "AwakeningView.finalizeAwakening")
        showSaveError = true
    }
}
```

Key change: `isPremiumLocked: index > 0` — only the first Power (index 0) and first Agent (index 0) are unlocked.

**Step 2: Build to verify**

Run: XcodeBuildMCP `build_sim`
Expected: Build succeeds.

**Step 3: Commit**

```bash
git add Views/AwakeningView.swift
git commit -m "feat: lock 4 of 6 onboarding habits behind paywall"
```

---

### Task 5: Add Locked State to HabitCard

**Files:**
- Modify: `Components/HabitCard.swift:3-136`

**Step 1: Add `isLocked` parameter and locked rendering**

Add the parameter and modify the body to show locked state:

```swift
struct HabitCard: View {
    let title: String
    let icon: String
    let currentDay: Int
    let targetDays: Int
    let isCompletedToday: Bool
    let isPower: Bool
    var subtitle: String? = nil
    var isRestDay: Bool = false
    var isLocked: Bool = false  // NEW
    var onEdit: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil
```

In the `body`, wrap the existing content to handle locked state. Replace the entire `body` computed property:

```swift
var body: some View {
    HStack(spacing: Spacing.md) {
        // Icon with overlay
        ZStack {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(accentColor)
                .opacity(isLocked ? 0.3 : (isCompletedToday || isRestDay ? 0.5 : 1.0))
                .frame(width: 44, height: 44)

            if isLocked {
                Image(systemName: "pill.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.red.opacity(0.8))
                    .offset(x: 14, y: 14)
            } else if isCompletedToday {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(accentColor)
                    .background(Color.matrixBlack)
                    .clipShape(Circle())
                    .offset(x: 14, y: 14)
            } else if isRestDay {
                Image(systemName: "moon.zzz.fill")
                    .font(.system(size: 14))
                    .foregroundColor(Color.mediumGray)
                    .background(Color.matrixBlack)
                    .clipShape(Circle())
                    .offset(x: 14, y: 14)
            }
        }

        // Content
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack {
                Text(title)
                    .font(.title)
                    .foregroundColor(isLocked ? Theme.primaryText.opacity(0.4) : (isCompletedToday ? Theme.secondaryText : Theme.primaryText))

                if isLocked {
                    Text("LOCKED")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(.red)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.red.opacity(0.2))
                        .cornerRadius(4)
                } else if isCompletedToday {
                    Text("UPLOADED")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(accentColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(accentColor.opacity(0.2))
                        .cornerRadius(4)
                }
            }

            if isLocked {
                Text("TAKE THE RED PILL TO UNLOCK")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.red.opacity(0.5))
                    .lineLimit(1)
            } else if isCompletedToday {
                UnlockCountdownView()
            } else {
                if let subtitle = subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Theme.secondaryText.opacity(0.8))
                        .lineLimit(1)
                }

                Text("DAY \(currentDay) OF \(targetDays)")
                    .font(.caption)
                    .foregroundColor(Theme.secondaryText)

                ProgressBar(progress: progress, isPower: isPower)
            }
        }

        Spacer()

        // Right side
        if isLocked {
            Image(systemName: "lock.fill")
                .font(.system(size: 14))
                .foregroundColor(.red.opacity(0.5))
        } else if onEdit != nil || onDelete != nil {
            Menu {
                if let onEdit = onEdit {
                    Button(action: onEdit) {
                        Label("Edit", systemImage: "pencil")
                    }
                }
                if let onDelete = onDelete {
                    Button(role: .destructive, action: onDelete) {
                        Label("Delete", systemImage: "trash")
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.mediumGray)
                    .frame(width: 32, height: 32)
                    .contentShape(Rectangle())
            }
        } else {
            if isRestDay {
                Image(systemName: "zzz")
                    .font(.system(size: 14))
                    .foregroundColor(Color.mediumGray)
            } else if !isCompletedToday {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.mediumGray)
            } else {
                Image(systemName: "lock.fill")
                    .font(.system(size: 14))
                    .foregroundColor(Color.mediumGray)
            }
        }
    }
    .padding(Spacing.md)
    .background(isLocked ? Theme.cardBackground.opacity(0.4) : (isCompletedToday ? Theme.cardBackground.opacity(0.6) : Theme.cardBackground))
    .cornerRadius(Theme.cardCornerRadius)
    .overlay(
        RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
            .stroke(isLocked ? Color.red.opacity(0.2) : (isCompletedToday ? accentColor.opacity(0.5) : Color.clear), lineWidth: 1)
    )
}
```

**Step 2: Build to verify**

Run: XcodeBuildMCP `build_sim`
Expected: Build succeeds.

**Step 3: Commit**

```bash
git add Components/HabitCard.swift
git commit -m "feat: add locked state rendering to HabitCard"
```

---

### Task 6: Update CommandCenterView — Locked Habits & Paywall Triggers

**Files:**
- Modify: `Views/CommandCenterView.swift`

**Step 1: Update powers/agents count in paywall checks**

Find both "LOAD PROGRAM" button actions (lines ~732 and ~774). Change the count to exclude locked habits:

```swift
// Replace this (both locations):
if StoreManager.shared.canCreateHabit(currentCount: powers.count + agents.count) {

// With this:
if StoreManager.shared.canCreateHabit(currentCount: powers.filter { !$0.isPremiumLocked }.count + agents.filter { !$0.isPremiumLocked }.count) {
```

**Step 2: Update `powersContent` to handle locked habits**

In `powersContent` (line ~538), add a locked section after the existing ForEach blocks. Replace the entire `powersContent` computed property:

```swift
private var powersContent: some View {
    VStack(spacing: Spacing.sm) {
        // Active scheduled habits
        ForEach(powers.filter { $0.isScheduledToday && !$0.isPremiumLocked }) { power in
            let isCompleted = power.completedToday
            let hackHabit = HackHabit.allCases.first { $0.rawValue == power.name }
            HabitCard(
                title: power.name,
                icon: power.icon,
                currentDay: power.currentStreak,
                targetDays: power.targetDays,
                isCompletedToday: isCompleted,
                isPower: true,
                subtitle: hackHabit?.shortDescription,
                onEdit: { editingPower = power },
                onDelete: {
                    deletingPower = power
                    showDeleteConfirmation = true
                }
            )
            .padding(.horizontal, Spacing.md)
            .onTapGesture {
                guard !isCompleted else { return }
                selectedPower = power
            }
        }
        // Active non-scheduled habits (rest day)
        ForEach(powers.filter { !$0.isScheduledToday && !$0.isPremiumLocked }) { power in
            HabitCard(
                title: power.name,
                icon: power.icon,
                currentDay: power.currentStreak,
                targetDays: power.targetDays,
                isCompletedToday: false,
                isPower: true,
                subtitle: "REST DAY",
                isRestDay: true,
                onEdit: { editingPower = power },
                onDelete: {
                    deletingPower = power
                    showDeleteConfirmation = true
                }
            )
            .padding(.horizontal, Spacing.md)
            .opacity(0.5)
        }
        // Locked habits
        ForEach(powers.filter { $0.isPremiumLocked }) { power in
            let hackHabit = HackHabit.allCases.first { $0.rawValue == power.name }
            HabitCard(
                title: power.name,
                icon: power.icon,
                currentDay: 0,
                targetDays: power.targetDays,
                isCompletedToday: false,
                isPower: true,
                subtitle: hackHabit?.shortDescription,
                isLocked: true
            )
            .padding(.horizontal, Spacing.md)
            .onTapGesture {
                showPaywall = true
            }
        }
    }
}
```

**Step 3: Update `agentsContent` — same pattern**

Replace the entire `agentsContent` computed property:

```swift
private var agentsContent: some View {
    VStack(spacing: Spacing.sm) {
        // Active scheduled habits
        ForEach(agents.filter { $0.isScheduledToday && !$0.isPremiumLocked }) { agent in
            let isCompleted = agent.resistedToday || agent.relapsedToday
            let agentHabit = AgentHabit.allCases.first { $0.rawValue == agent.name }
            HabitCard(
                title: agent.name,
                icon: agent.icon,
                currentDay: agent.currentStreak,
                targetDays: agent.targetDays,
                isCompletedToday: isCompleted,
                isPower: false,
                subtitle: agentHabit?.shortDescription,
                onEdit: { editingAgent = agent },
                onDelete: {
                    deletingAgent = agent
                    showDeleteConfirmation = true
                }
            )
            .padding(.horizontal, Spacing.md)
            .onTapGesture {
                guard !isCompleted else { return }
                selectedAgent = agent
            }
        }
        // Active non-scheduled habits (rest day)
        ForEach(agents.filter { !$0.isScheduledToday && !$0.isPremiumLocked }) { agent in
            HabitCard(
                title: agent.name,
                icon: agent.icon,
                currentDay: agent.currentStreak,
                targetDays: agent.targetDays,
                isCompletedToday: false,
                isPower: false,
                subtitle: "REST DAY",
                isRestDay: true,
                onEdit: { editingAgent = agent },
                onDelete: {
                    deletingAgent = agent
                    showDeleteConfirmation = true
                }
            )
            .padding(.horizontal, Spacing.md)
            .opacity(0.5)
        }
        // Locked habits
        ForEach(agents.filter { $0.isPremiumLocked }) { agent in
            let agentHabit = AgentHabit.allCases.first { $0.rawValue == agent.name }
            HabitCard(
                title: agent.name,
                icon: agent.icon,
                currentDay: 0,
                targetDays: agent.targetDays,
                isCompletedToday: false,
                isPower: false,
                subtitle: agentHabit?.shortDescription,
                isLocked: true
            )
            .padding(.horizontal, Spacing.md)
            .onTapGesture {
                showPaywall = true
            }
        }
    }
}
```

**Step 4: Build to verify**

Run: XcodeBuildMCP `build_sim`
Expected: Build succeeds.

**Step 5: Commit**

```bash
git add Views/CommandCenterView.swift
git commit -m "feat: show locked habits on dashboard with paywall triggers"
```

---

### Task 7: Update RedPillPaywallView — New Copy & Unlock Logic

**Files:**
- Modify: `Views/RedPillPaywallView.swift`

**Step 1: Rewrite the paywall view with new messaging and unlock logic**

Replace the entire file contents (keep the struct, rewrite body):

```swift
import SwiftUI
import SwiftData

struct RedPillPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var powers: [Power]
    @Query private var agents: [Agent]
    private let storeManager = StoreManager.shared

    var body: some View {
        ZStack {
            Color.matrixBlack.ignoresSafeArea()

            ScrollView {
                VStack(spacing: Spacing.xl) {
                    Spacer().frame(height: Spacing.xxl)

                    // Header icon
                    Image(systemName: "pill.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.red)
                        .shadow(color: .red.opacity(0.6), radius: 20)

                    // Title
                    VStack(spacing: Spacing.sm) {
                        Text("TAKE THE RED PILL")
                            .font(.system(size: 28, weight: .black, design: .monospaced))
                            .foregroundColor(.white)

                        Text("YOUR AWAKENING IS INCOMPLETE")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(.red.opacity(0.8))
                    }

                    // Features list
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        featureRow(icon: "lock.open.fill", text: "UNLOCK ALL YOUR HABITS")
                        featureRow(icon: "plus.circle.fill", text: "CREATE CUSTOM PROGRAMS")
                        featureRow(icon: "widget.small", text: "HOME SCREEN WIDGETS")
                        featureRow(icon: "chart.xyaxis.line", text: "ADVANCED SIGNAL ANALYSIS")
                        featureRow(icon: "shield.checkered", text: "STREAK SHIELD PROTOCOL")
                    }
                    .padding(.horizontal, Spacing.lg)

                    // Separator
                    Rectangle()
                        .fill(Color.charcoal)
                        .frame(height: 1)
                        .padding(.horizontal, Spacing.xl)

                    // Privacy & value block
                    VStack(spacing: Spacing.sm) {
                        Text("ONE-TIME PURCHASE. NO SUBSCRIPTION.\nYOURS FOREVER.")
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)

                        Text("YOUR DATA NEVER LEAVES YOUR DEVICE.\nNO ACCOUNTS. NO TRACKING. 100% PRIVATE.")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(Color.mediumGray)
                            .multilineTextAlignment(.center)
                    }

                    // Purchase area
                    VStack(spacing: Spacing.md) {
                        if let product = storeManager.redPillProduct {
                            PrimaryButton(
                                title: storeManager.purchaseInProgress
                                    ? "PROCESSING..."
                                    : "UNLOCK — \(product.displayPrice)",
                                color: .red
                            ) {
                                Task { await storeManager.purchase() }
                            }
                            .disabled(storeManager.purchaseInProgress)
                            .opacity(storeManager.purchaseInProgress ? 0.6 : 1.0)
                        } else {
                            ProgressView()
                                .tint(Color.matrixGreen)
                                .task { await storeManager.loadProduct() }
                        }

                        Text("Pay once. Own it for life.")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(Color.mediumGray)

                        Button("RESTORE PURCHASE") {
                            Task { await storeManager.restorePurchases() }
                        }
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(Color.lightGray)

                        if let error = storeManager.errorMessage {
                            Text(error)
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(Color.agentRed)
                        }
                    }
                    .padding(.horizontal, Spacing.xl)

                    Spacer().frame(height: Spacing.xl)
                }
            }

            // Close button — "NOT NOW"
            VStack {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Text("NOT NOW")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(Color.mediumGray)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.charcoal.opacity(0.6))
                            .cornerRadius(12)
                    }
                    .padding(Spacing.md)
                }
                Spacer()
            }
        }
        .onChange(of: storeManager.isRedPillOwned) { _, owned in
            if owned {
                storeManager.unlockAllHabits(powers: powers, agents: agents)
                try? modelContext.save()
                dismiss()
            }
        }
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color.matrixGreen)
                .frame(width: 28)

            Text(text)
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundColor(.white)

            Spacer()

            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color.matrixGreen)
        }
        .padding(.vertical, Spacing.xs)
    }
}
```

**Step 2: Build to verify**

Run: XcodeBuildMCP `build_sim`
Expected: Build succeeds.

**Step 3: Commit**

```bash
git add Views/RedPillPaywallView.swift
git commit -m "feat: redesign paywall with privacy messaging and unlock logic"
```

---

### Task 8: Auto-Show Paywall After Onboarding

**Files:**
- Modify: `ContentView.swift:4-20`

**Step 1: Add post-onboarding paywall trigger**

The cleanest approach: use `@AppStorage` to detect when onboarding just completed and show the paywall once.

```swift
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("hasSeenPostOnboardingPaywall") private var hasSeenPostOnboardingPaywall = false
    @State private var showPostOnboardingPaywall = false

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingContainerView()
            }
        }
        .onAppear {
            UserProfile.recordFirstLaunchIfNeeded()
        }
        .onChange(of: hasCompletedOnboarding) { _, completed in
            if completed && !hasSeenPostOnboardingPaywall {
                // Small delay so the UI transition completes first
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    showPostOnboardingPaywall = true
                    hasSeenPostOnboardingPaywall = true
                }
            }
        }
        .sheet(isPresented: $showPostOnboardingPaywall) {
            RedPillPaywallView()
        }
    }
}
```

Keep `MainTabView`, `OnboardingContainerView`, `DataErrorView`, and `#Preview` unchanged.

**Step 2: Build to verify**

Run: XcodeBuildMCP `build_sim`
Expected: Build succeeds.

**Step 3: Commit**

```bash
git add ContentView.swift
git commit -m "feat: auto-show paywall after onboarding completes"
```

---

### Task 9: Update StoreKit Config Free Tier Display

**Files:**
- Modify: `MatrixHabit.storekit:13`

**Step 1: Update product description**

Change the localization description to match new messaging:

```json
"description" : "Unlock all your habits, create custom programs, widgets, and more. One-time purchase. Yours forever.",
```

**Step 2: Commit**

```bash
git add MatrixHabit.storekit
git commit -m "chore: update StoreKit product description"
```

---

### Task 10: Build, Install, and Verify on Simulator

**Step 1: Clean build**

Run: XcodeBuildMCP `clean` then `build_sim`
Expected: Build succeeds with no errors or warnings related to our changes.

**Step 2: Install and launch on simulator**

Run: XcodeBuildMCP `install_app_sim` then `launch_app_sim`
Expected: App launches. If fresh install (no prior data), onboarding runs. After onboarding, paywall auto-shows.

**Step 3: Verify all paywall triggers**

Manual checks:
1. After onboarding → paywall appears automatically
2. Dismiss paywall → dashboard shows 2 active + 4 locked habits
3. Tap a locked habit → paywall appears
4. Tap "LOAD PROGRAM" button → paywall appears
5. Tap tab bar "+" button → paywall appears

**Step 4: Final commit**

```bash
git add -A
git commit -m "feat: paywall redesign — show-but-lock strategy complete

- Onboarding creates 2 active + 4 locked habits
- Free limit reduced to 2 (zero free adds)
- Locked habits show dimmed with red pill overlay
- 4 paywall entry points: post-onboarding, locked tap, both LOAD PROGRAM buttons
- Updated paywall copy: privacy, lifetime value, YOUR AWAKENING IS INCOMPLETE
- Bulk unlock on purchase"
```

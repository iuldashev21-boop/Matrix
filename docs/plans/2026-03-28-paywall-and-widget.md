# Paywall + StoreKit IAP & iOS Widget Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add "Red Pill" one-time IAP ($4.99) gating habits at 3 for free users, plus an iOS home screen widget showing streak data.

**Architecture:** StoreKit 2 async/await for IAP (no server validation — offline app). WidgetKit extension with App Groups + shared UserDefaults for data transfer. Widget reads cached summary data written by the main app after each check-in.

**Tech Stack:** StoreKit 2, WidgetKit, App Groups, SwiftUI, SwiftData, UserDefaults

**Key Constants:**
- Bundle ID: `com.construct.MatrixHabit`
- Team ID: `26N9LR8N99`
- App Group: `group.com.construct.MatrixHabit`
- Product ID: `com.construct.matrixhabit.redpill`
- Free habit limit: 3 (Powers + Agents combined)
- Price: $4.99

---

## Phase 1: StoreKit IAP + Paywall

### Task 1: StoreManager Service

**Files:**
- Create: `Services/StoreManager.swift`

**Step 1: Create StoreManager.swift**

```swift
import Foundation
import StoreKit

@MainActor
@Observable
final class StoreManager {
    static let shared = StoreManager()

    private let productID = "com.construct.matrixhabit.redpill"
    private let purchasedKey = "com.matrixhabit.redpill.purchased"

    var isRedPillOwned: Bool = false
    var redPillProduct: Product? = nil
    var purchaseInProgress: Bool = false
    var errorMessage: String? = nil

    private var transactionListener: Task<Void, Never>?

    private init() {
        // Fast cache read
        self.isRedPillOwned = UserDefaults.standard.bool(forKey: purchasedKey)

        // Verify with StoreKit
        Task { await checkEntitlements() }

        // Listen for external transaction updates (Family Sharing, refunds)
        transactionListener = Task(priority: .background) {
            for await verificationResult in Transaction.updates {
                await handle(verificationResult)
            }
        }
    }

    func loadProduct() async {
        guard redPillProduct == nil else { return }
        do {
            let products = try await Product.products(for: [productID])
            redPillProduct = products.first
        } catch {
            errorMessage = "PRODUCT UNAVAILABLE"
        }
    }

    func purchase() async {
        guard let product = redPillProduct else {
            await loadProduct()
            guard redPillProduct != nil else { return }
            return await purchase()
        }

        purchaseInProgress = true
        errorMessage = nil

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                await handle(verification)
            case .pending:
                errorMessage = "AWAITING APPROVAL"
            case .userCancelled:
                break
            @unknown default:
                break
            }
        } catch {
            errorMessage = "PURCHASE FAILED"
        }

        purchaseInProgress = false
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await checkEntitlements()
        } catch {
            errorMessage = "RESTORE FAILED"
        }
    }

    private func checkEntitlements() async {
        for await verificationResult in Transaction.currentEntitlements {
            await handle(verificationResult)
        }
    }

    private func handle(_ verificationResult: VerificationResult<Transaction>) async {
        guard case .verified(let transaction) = verificationResult else { return }

        if transaction.productID == productID {
            if transaction.revocationDate != nil {
                isRedPillOwned = false
                UserDefaults.standard.set(false, forKey: purchasedKey)
            } else {
                isRedPillOwned = true
                UserDefaults.standard.set(true, forKey: purchasedKey)
            }
        }

        await transaction.finish()
    }

    // MARK: - Habit Limit Check

    static let freeHabitLimit = 3

    func canCreateHabit(currentCount: Int) -> Bool {
        isRedPillOwned || currentCount < StoreManager.freeHabitLimit
    }
}
```

**Step 2: Build to verify compilation**

---

### Task 2: StoreKit Configuration File

**Files:**
- Create: `MatrixHabit.storekit`

**Step 1: Create the StoreKit configuration file**

This is a JSON file Xcode uses for local StoreKit testing. Create it at the project root:

```json
{
  "identifier" : "8A5F8A5F-0000-0000-0000-000000000001",
  "type" : "Configuration",
  "version" : 1,
  "storekit" : {
    "products" : [
      {
        "displayPrice" : "4.99",
        "familyShareable" : false,
        "internalID" : "1",
        "localizations" : [
          {
            "description" : "Unlock unlimited habits and premium features",
            "displayName" : "Red Pill",
            "locale" : "en_US"
          }
        ],
        "productID" : "com.construct.matrixhabit.redpill",
        "referenceName" : "Red Pill",
        "type" : "NonConsumable"
      }
    ]
  }
}
```

**Note:** This file will be added to the Xcode project and selected in the scheme's Run > StoreKit Configuration setting for testing.

---

### Task 3: RedPillPaywallView

**Files:**
- Create: `Views/RedPillPaywallView.swift`

**Step 1: Create the paywall view**

```swift
import SwiftUI

struct RedPillPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    private let storeManager = StoreManager.shared

    var body: some View {
        ZStack {
            Color.matrixBlack.ignoresSafeArea()

            ScrollView {
                VStack(spacing: Spacing.xl) {
                    Spacer().frame(height: Spacing.xl)

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

                        Text("ACCESS LEVEL: RESTRICTED")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(Color.mediumGray)
                    }

                    // Features list
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        featureRow(icon: "infinity", text: "UNLIMITED PROGRAMS", color: Color.matrixGreen)
                        featureRow(icon: "widget.small", text: "HOME SCREEN WIDGETS", color: Color.matrixGreen)
                        featureRow(icon: "chart.xyaxis.line", text: "ADVANCED SIGNAL ANALYSIS", color: Color.matrixGreen)
                        featureRow(icon: "shield.checkered", text: "STREAK SHIELD PROTOCOL", color: Color.matrixGreen)
                    }
                    .padding(.horizontal, Spacing.lg)

                    // Separator
                    Rectangle()
                        .fill(Color.charcoal)
                        .frame(height: 1)
                        .padding(.horizontal, Spacing.xl)

                    // Free tier info
                    Text("FREE TIER: 3 PROGRAMS MAX")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(Color.mediumGray)

                    // Purchase button
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

                        // One-time purchase note
                        Text("ONE-TIME PURCHASE. NO SUBSCRIPTION. YOURS FOREVER.")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(Color.mediumGray)
                            .multilineTextAlignment(.center)

                        // Restore
                        Button("RESTORE PURCHASE") {
                            Task { await storeManager.restorePurchases() }
                        }
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(Color.lightGray)

                        // Error
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

            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color.lightGray)
                            .frame(width: 32, height: 32)
                            .background(Color.charcoal)
                            .clipShape(Circle())
                    }
                    .padding(Spacing.md)
                }
                Spacer()
            }
        }
        .onChange(of: storeManager.isRedPillOwned) { _, owned in
            if owned { dismiss() }
        }
    }

    private func featureRow(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
                .frame(width: 28)

            Text(text)
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundColor(.white)

            Spacer()

            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(color)
        }
        .padding(.vertical, Spacing.xs)
    }
}
```

**Step 2: Build to verify compilation**

---

### Task 4: Gate Habit Creation in CommandCenterView

**Files:**
- Modify: `Views/CommandCenterView.swift`

**Step 1: Add paywall state and premium-aware "+" button**

Add a new `@State` property near the existing state vars (around line 11):

```swift
@State private var showPaywall: Bool = false
```

**Step 2: Modify the tab bar "+" button (line 759)**

Replace:
```swift
Button(action: { showAddHabit = true }) {
```

With:
```swift
Button(action: {
    if StoreManager.shared.canCreateHabit(currentCount: powers.count + agents.count) {
        showAddHabit = true
    } else {
        showPaywall = true
    }
}) {
```

**Step 3: Modify the empty state "LOAD PROGRAM" button (line 723)**

Replace:
```swift
Button(action: { showAddHabit = true }) {
```

With:
```swift
Button(action: {
    if StoreManager.shared.canCreateHabit(currentCount: powers.count + agents.count) {
        showAddHabit = true
    } else {
        showPaywall = true
    }
}) {
```

**Step 4: Add paywall sheet modifier after the existing `.sheet(isPresented: $showAddHabit)` (around line 184)**

```swift
.sheet(isPresented: $showPaywall) {
    RedPillPaywallView()
}
```

**Step 5: Add habit count badge near the "+" button (optional, enhances UX)**

In the tab bar, after the "+" Circle ZStack (around line 768), add a small counter overlay if not premium:

```swift
.overlay(alignment: .topTrailing) {
    if !StoreManager.shared.isRedPillOwned {
        Text("\(powers.count + agents.count)/\(StoreManager.freeHabitLimit)")
            .font(.system(size: 9, weight: .bold, design: .monospaced))
            .foregroundColor(Color.matrixGreen)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(Color.deepBlack)
            .cornerRadius(4)
            .offset(x: 4, y: -4)
    }
}
```

**Step 6: Build to verify compilation**

---

### Task 5: Restore Purchases in Settings (ZionMainframeView)

**Files:**
- Modify: `Views/ZionMainframeView.swift`

**Step 1: Add a "Restore Purchases" button in the memorySection (after Export button, around line 217)**

Insert before the Reset Button:

```swift
// Restore Purchases
Button(action: {
    Task { await StoreManager.shared.restorePurchases() }
}) {
    HStack {
        Image(systemName: "arrow.clockwise")
            .font(.system(size: 16))
        Text("RESTORE PURCHASE")
            .font(.system(size: 14, weight: .medium, design: .monospaced))
        Spacer()
    }
    .foregroundColor(Color.matrixGreen)
    .padding(Spacing.md)
    .background(Color.charcoal)
    .cornerRadius(Theme.cornerRadius)
    .overlay(
        RoundedRectangle(cornerRadius: Theme.cornerRadius)
            .stroke(Color.matrixGreen, lineWidth: 1)
    )
}
```

**Step 2: Build to verify compilation**

---

### Task 6: Commit Phase 1

```bash
git add Services/StoreManager.swift Views/RedPillPaywallView.swift Views/CommandCenterView.swift Views/ZionMainframeView.swift
git commit -m "feat: Add Red Pill IAP paywall — 3 free habits, StoreKit 2"
```

---

## Phase 2: iOS Widget Extension

### Task 7: Shared Data Layer (App Group)

**Files:**
- Create: `Services/WidgetDataManager.swift`

The widget can't access SwiftData directly (different process). We write a lightweight JSON snapshot to shared UserDefaults after each check-in.

**Step 1: Create WidgetDataManager.swift**

```swift
import Foundation
import WidgetKit

enum WidgetDataManager {
    static let appGroupID = "group.com.construct.MatrixHabit"

    private static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    // MARK: - Data Model for Widget

    struct HabitSnapshot: Codable {
        let name: String
        let icon: String
        let isAgent: Bool
        let currentStreak: Int
        let targetDays: Int
        let completedToday: Bool
        let isScheduledToday: Bool
    }

    struct WidgetData: Codable {
        let habits: [HabitSnapshot]
        let totalXP: Int
        let level: Int
        let rankName: String
        let operativeName: String
        let updatedAt: Date
    }

    // MARK: - Write (called from main app)

    static func updateWidgetData(powers: [Power], agents: [Agent]) {
        var snapshots: [HabitSnapshot] = []

        for power in powers {
            snapshots.append(HabitSnapshot(
                name: power.name,
                icon: power.icon,
                isAgent: false,
                currentStreak: power.currentStreak,
                targetDays: power.targetDays,
                completedToday: power.completedToday,
                isScheduledToday: power.isScheduledToday
            ))
        }

        for agent in agents {
            snapshots.append(HabitSnapshot(
                name: agent.name,
                icon: agent.icon,
                isAgent: true,
                currentStreak: agent.currentStreak,
                targetDays: agent.targetDays,
                completedToday: agent.resistedToday,
                isScheduledToday: agent.isScheduledToday
            ))
        }

        let data = WidgetData(
            habits: snapshots,
            totalXP: UserProfile.totalXP,
            level: UserProfile.currentLevel,
            rankName: UserProfile.currentRank.displayName,
            operativeName: UserProfile.displayName,
            updatedAt: Date()
        )

        if let encoded = try? JSONEncoder().encode(data) {
            sharedDefaults?.set(encoded, forKey: "widgetData")
        }

        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: - Read (called from widget extension)

    static func readWidgetData() -> WidgetData? {
        guard let data = sharedDefaults?.data(forKey: "widgetData") else { return nil }
        return try? JSONDecoder().decode(data, as: WidgetData.self)
    }
}
```

**Step 2: Build to verify compilation**

---

### Task 8: Trigger Widget Updates from CheckInService

**Files:**
- Modify: `Services/CheckInService.swift`
- Modify: `Views/CommandCenterView.swift` (for passing data to widget manager)

**Step 1: Add WidgetKit import to CheckInService.swift**

At the top of the file, add:
```swift
import WidgetKit
```

**Step 2: Add widget reload after successful power check-in (line 68, after return .success)**

Before `return .success(xpEarned)` in `recordPowerCheckIn`, add:
```swift
WidgetCenter.shared.reloadAllTimelines()
```

**Step 3: Same for recordAgentResistance (line 128)**

Before `return .success(xpEarned)`, add:
```swift
WidgetCenter.shared.reloadAllTimelines()
```

**Step 4: Same for submitAllHabits (line 234)**

Before `return .success(totalXP)`, add:
```swift
WidgetCenter.shared.reloadAllTimelines()
```

**Step 5: Same for recoverWithEMP (line 276)**

Before `return .success(())`, add:
```swift
WidgetCenter.shared.reloadAllTimelines()
```

**Step 6: In CommandCenterView, trigger widget data write on appear and after changes**

In the `.onAppear` block (around line 161), add:
```swift
WidgetDataManager.updateWidgetData(powers: powers, agents: agents)
```

Also add an `.onChange` for powers and agents count to refresh widget data:
```swift
.onChange(of: powers.count + agents.count) { _, _ in
    WidgetDataManager.updateWidgetData(powers: powers, agents: agents)
}
```

(Extend the existing `.onChange(of: powers.count + agents.count)` handler)

**Step 7: Build to verify compilation**

---

### Task 9: Create Widget Extension Target

**This must be done in Xcode manually or via pbxproj editing.**

**What needs to happen:**
1. In Xcode: File > New > Target > Widget Extension
2. Product Name: `MatrixHabitWidget`
3. Bundle ID: `com.construct.MatrixHabit.MatrixHabitWidget`
4. Team: `26N9LR8N99`
5. Uncheck "Include Configuration App Intent" (we use static config)
6. Add App Group capability (`group.com.construct.MatrixHabit`) to BOTH the main app target AND the widget target

**Alternative: Create files manually and update pbxproj**

The widget extension needs these files:
- `MatrixHabitWidget/MatrixHabitWidget.swift` (entry point + timeline provider)
- `MatrixHabitWidget/MatrixHabitWidgetBundle.swift` (widget bundle)
- `MatrixHabitWidget/Info.plist`

**IMPORTANT:** The App Group entitlement must be added to BOTH targets:
- `MatrixHabit.entitlements` (main app)
- `MatrixHabitWidget.entitlements` (widget)

Both files contain:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.com.construct.MatrixHabit</string>
    </array>
</dict>
</plist>
```

---

### Task 10: Widget Views and Timeline Provider

**Files:**
- Create: `MatrixHabitWidget/MatrixHabitWidget.swift`

**Step 1: Create the main widget file**

```swift
import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct MatrixHabitEntry: TimelineEntry {
    let date: Date
    let habits: [WidgetHabit]
    let operativeName: String
    let level: Int
    let rankName: String
    let isEmpty: Bool

    struct WidgetHabit {
        let name: String
        let icon: String
        let isAgent: Bool
        let streak: Int
        let targetDays: Int
        let completedToday: Bool
    }

    static let placeholder = MatrixHabitEntry(
        date: Date(),
        habits: [
            WidgetHabit(name: "Meditation", icon: "brain.head.profile", isAgent: false, streak: 12, targetDays: 66, completedToday: true),
            WidgetHabit(name: "Reading", icon: "book.fill", isAgent: false, streak: 8, targetDays: 66, completedToday: false),
            WidgetHabit(name: "No Scrolling", icon: "iphone", isAgent: true, streak: 5, targetDays: 66, completedToday: false)
        ],
        operativeName: "NEO",
        level: 7,
        rankName: "OPERATOR",
        isEmpty: false
    )
}

// MARK: - Timeline Provider

struct MatrixHabitProvider: TimelineProvider {
    func placeholder(in context: Context) -> MatrixHabitEntry {
        MatrixHabitEntry.placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (MatrixHabitEntry) -> Void) {
        completion(makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MatrixHabitEntry>) -> Void) {
        let entry = makeEntry()

        // Refresh at midnight (day rollover) and every 30 minutes
        let midnight = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date())
        let timeline = Timeline(entries: [entry], policy: .after(midnight))
        completion(timeline)
    }

    private func makeEntry() -> MatrixHabitEntry {
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.construct.MatrixHabit"),
              let data = sharedDefaults.data(forKey: "widgetData"),
              let widgetData = try? JSONDecoder().decode(WidgetDataCodable.self, from: data) else {
            return MatrixHabitEntry(
                date: Date(),
                habits: [],
                operativeName: "OPERATIVE",
                level: 1,
                rankName: "COPPER TOP",
                isEmpty: true
            )
        }

        let habits = widgetData.habits
            .filter { $0.isScheduledToday }
            .prefix(4)
            .map { habit in
                MatrixHabitEntry.WidgetHabit(
                    name: habit.name,
                    icon: habit.icon,
                    isAgent: habit.isAgent,
                    streak: habit.currentStreak,
                    targetDays: habit.targetDays,
                    completedToday: habit.completedToday
                )
            }

        return MatrixHabitEntry(
            date: Date(),
            habits: Array(habits),
            operativeName: widgetData.operativeName,
            level: widgetData.level,
            rankName: widgetData.rankName,
            isEmpty: habits.isEmpty
        )
    }
}

// Mirror of WidgetDataManager.WidgetData for decoding in widget
struct WidgetDataCodable: Codable {
    struct HabitSnapshot: Codable {
        let name: String
        let icon: String
        let isAgent: Bool
        let currentStreak: Int
        let targetDays: Int
        let completedToday: Bool
        let isScheduledToday: Bool
    }

    let habits: [HabitSnapshot]
    let totalXP: Int
    let level: Int
    let rankName: String
    let operativeName: String
    let updatedAt: Date
}

// MARK: - Small Widget View

struct MatrixHabitSmallView: View {
    let entry: MatrixHabitEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Header
            HStack {
                Image(systemName: "bolt.shield.fill")
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 0, green: 1, blue: 65/255))
                Text("MATRIX")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(red: 0, green: 1, blue: 65/255))
                Spacer()
            }

            if entry.isEmpty {
                Spacer()
                Text("NO ACTIVE\nPROGRAMS")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                Spacer()
            } else {
                // Show top 2 habits with streaks
                ForEach(Array(entry.habits.prefix(2).enumerated()), id: \.offset) { _, habit in
                    HStack(spacing: 4) {
                        Image(systemName: habit.completedToday ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 12))
                            .foregroundColor(habit.completedToday
                                ? Color(red: 0, green: 1, blue: 65/255)
                                : .gray)

                        Text(habit.name.prefix(10).uppercased())
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(.white)
                            .lineLimit(1)

                        Spacer()

                        Text("\(habit.streak)d")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(habit.isAgent
                                ? Color(red: 1, green: 0, blue: 51/255)
                                : Color(red: 0, green: 1, blue: 65/255))
                    }
                }

                Spacer()

                // Bottom: level
                Text("LVL \(entry.level) \(entry.rankName)")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(.gray)
            }
        }
        .padding(12)
        .containerBackground(for: .widget) {
            Color(red: 13/255, green: 13/255, blue: 13/255)
        }
    }
}

// MARK: - Medium Widget View

struct MatrixHabitMediumView: View {
    let entry: MatrixHabitEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header
            HStack {
                Image(systemName: "bolt.shield.fill")
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 0, green: 1, blue: 65/255))
                Text("COMMAND CENTER")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(red: 0, green: 1, blue: 65/255))
                Spacer()
                Text("LVL \(entry.level)")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.gray)
            }

            if entry.isEmpty {
                Spacer()
                Text("NO ACTIVE PROGRAMS — OPEN APP TO BEGIN")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                Spacer()
            } else {
                // Show up to 4 habits
                ForEach(Array(entry.habits.prefix(4).enumerated()), id: \.offset) { _, habit in
                    HStack(spacing: 6) {
                        Image(systemName: habit.completedToday ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 14))
                            .foregroundColor(habit.completedToday
                                ? Color(red: 0, green: 1, blue: 65/255)
                                : .gray)

                        Image(systemName: habit.icon)
                            .font(.system(size: 11))
                            .foregroundColor(habit.isAgent
                                ? Color(red: 1, green: 0, blue: 51/255)
                                : Color(red: 0, green: 1, blue: 65/255))
                            .frame(width: 16)

                        Text(habit.name.uppercased())
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(.white)
                            .lineLimit(1)

                        Spacer()

                        // Streak
                        Text("\(habit.streak)/\(habit.targetDays)")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(habit.isAgent
                                ? Color(red: 1, green: 0, blue: 51/255)
                                : Color(red: 0, green: 1, blue: 65/255))

                        // Progress bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.gray.opacity(0.3))
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(habit.isAgent
                                        ? Color(red: 1, green: 0, blue: 51/255)
                                        : Color(red: 0, green: 1, blue: 65/255))
                                    .frame(width: geo.size.width * min(1.0, Double(habit.streak) / Double(habit.targetDays)))
                            }
                        }
                        .frame(width: 40, height: 4)
                    }
                }

                if entry.habits.count < 4 {
                    Spacer()
                }
            }
        }
        .padding(12)
        .containerBackground(for: .widget) {
            Color(red: 13/255, green: 13/255, blue: 13/255)
        }
    }
}

// MARK: - Widget Configuration

struct MatrixHabitWidget: Widget {
    let kind: String = "MatrixHabitWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MatrixHabitProvider()) { entry in
            if #available(iOS 17, *) {
                MatrixHabitWidgetEntryView(entry: entry)
            }
        }
        .configurationDisplayName("MatrixHabit")
        .description("Track your habit streaks from the home screen.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct MatrixHabitWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: MatrixHabitEntry

    var body: some View {
        switch family {
        case .systemSmall:
            MatrixHabitSmallView(entry: entry)
        case .systemMedium:
            MatrixHabitMediumView(entry: entry)
        default:
            MatrixHabitSmallView(entry: entry)
        }
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    MatrixHabitWidget()
} timeline: {
    MatrixHabitEntry.placeholder
}

#Preview(as: .systemMedium) {
    MatrixHabitWidget()
} timeline: {
    MatrixHabitEntry.placeholder
}
```

**Step 2: Create widget bundle file**

`MatrixHabitWidget/MatrixHabitWidgetBundle.swift`:

```swift
import WidgetKit
import SwiftUI

@main
struct MatrixHabitWidgetBundle: WidgetBundle {
    var body: some Widget {
        MatrixHabitWidget()
    }
}
```

---

### Task 11: Add Widget Target to Xcode Project

**This is the most complex task — requires editing project.pbxproj or using Xcode.**

Required changes:
1. Add `MatrixHabitWidget` native target
2. Add widget extension build settings (iOS 17.0 deployment, widget extension point)
3. Add App Group entitlement to both targets
4. Add widget files to the new target
5. Add widget target as dependency of main target

**After target setup, build to verify both targets compile.**

---

### Task 12: Commit Phase 2

```bash
git add Services/WidgetDataManager.swift Services/CheckInService.swift Views/CommandCenterView.swift MatrixHabitWidget/
git commit -m "feat: Add iOS home screen widget — streak display with Matrix theme"
```

---

## Phase 3: Build Number + Final Verification

### Task 13: Bump Version for v1.1

**Files:**
- Modify: `MatrixHabit.xcodeproj/project.pbxproj`

Update in both Debug and Release configs:
- `MARKETING_VERSION` → `1.1`
- `CURRENT_PROJECT_VERSION` → `2`

### Task 14: Final Build + Test

1. Build both targets (app + widget)
2. Run existing unit tests
3. Manual verification checklist:
   - [ ] Free user can create 3 habits
   - [ ] 4th habit attempt shows paywall
   - [ ] Purchase flow works (StoreKit config)
   - [ ] Restore purchases works
   - [ ] Widget shows streak data
   - [ ] Widget updates after check-in
   - [ ] Settings shows "Restore Purchase" button

### Task 15: Final Commit

```bash
git add -A
git commit -m "chore: Bump to v1.1 build 2 — Red Pill IAP + Widget"
```

---

## File Summary

| File | Action | Phase |
|------|--------|-------|
| `Services/StoreManager.swift` | Create | 1 |
| `Views/RedPillPaywallView.swift` | Create | 1 |
| `MatrixHabit.storekit` | Create | 1 |
| `Views/CommandCenterView.swift` | Modify | 1+2 |
| `Views/ZionMainframeView.swift` | Modify | 1 |
| `Services/WidgetDataManager.swift` | Create | 2 |
| `Services/CheckInService.swift` | Modify | 2 |
| `MatrixHabitWidget/MatrixHabitWidget.swift` | Create | 2 |
| `MatrixHabitWidget/MatrixHabitWidgetBundle.swift` | Create | 2 |
| `MatrixHabit.entitlements` | Create | 2 |
| `MatrixHabitWidget/MatrixHabitWidget.entitlements` | Create | 2 |
| `MatrixHabit.xcodeproj/project.pbxproj` | Modify | 2+3 |

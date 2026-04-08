import SwiftUI
import SwiftData

@main
struct MatrixHabitApp: App {
    @Environment(\.scenePhase) private var scenePhase

    let sharedModelContainer: ModelContainer?
    private let containerError: String?

    init() {
        let schema = Schema([
            Power.self,
            Agent.self,
            CheckIn.self,
            Achievement.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            self.sharedModelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            self.containerError = nil
            // Demo data for App Store screenshots
            #if DEBUG
            MatrixHabitApp.injectDemoDataIfNeeded(into: self.sharedModelContainer!)
            #endif
        } catch {
            // Log error and try in-memory fallback
            ErrorLogger.log(error, operation: "ModelContainer.init", context: "Primary storage failed")
            #if DEBUG
            print("Error creating ModelContainer: \(error). Using in-memory storage.")
            #endif
            let fallbackConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            do {
                self.sharedModelContainer = try ModelContainer(for: schema, configurations: [fallbackConfig])
                self.containerError = nil
            } catch {
                // Both failed - store error for UI display instead of crashing
                ErrorLogger.log(error, operation: "ModelContainer.fallback", context: "In-memory fallback also failed")
                self.sharedModelContainer = nil
                self.containerError = error.localizedDescription
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            if let container = sharedModelContainer {
                ContentView()
                    .preferredColorScheme(.dark)
                    .modelContainer(container)
                    .onChange(of: scenePhase) { _, newPhase in
                        if newPhase == .active {
                            DateHelper.invalidateCache()
                            Task { @MainActor in
                                NotificationManager.shared.clearBadge()
                                WidgetSyncService.syncPendingCheckIns(context: container.mainContext)
                            }
                        }
                    }
            } else {
                // Graceful error screen instead of crash
                DataErrorView(errorMessage: containerError ?? "Unknown error")
            }
        }
    }
}

// MARK: - Demo Data for App Store Screenshots
#if DEBUG
extension MatrixHabitApp {
    @MainActor
    static func injectDemoDataIfNeeded(into container: ModelContainer) {
        let context = container.mainContext
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Skip if data already exists
        let existingPowers = (try? context.fetch(FetchDescriptor<Power>())) ?? []
        if !existingPowers.isEmpty { return }

        // 1. UserDefaults — skip onboarding, set XP, enable premium
        UserDefaults.standard.set("NEO", forKey: "operatorName")
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        UserDefaults.standard.set(Date().addingTimeInterval(-45 * 86400), forKey: "firstLaunchDate")
        UserDefaults.standard.set(2850, forKey: "totalXP")
        UserDefaults.standard.set(3, forKey: "empTokens")
        UserDefaults.standard.set(true, forKey: "com.matrixhabit.redpill.purchased")
        // Dismiss all overlays/tutorials so screenshots are clean
        UserDefaults.standard.set(true, forKey: "hasSeenGhostTutorial")
        UserDefaults.standard.set(true, forKey: "hasSeenHabitTip")
        UserDefaults.standard.set(true, forKey: "hasSeenPostOnboardingPaywall")
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasSeenNotificationPrompt)
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "lastAffirmationDate")

        // Helper: create N consecutive daily check-ins ending on offset day (0=today, 1=yesterday)
        func makeCheckIns(_ days: Int, startOffset: Int = 0) -> [CheckIn] {
            (0..<days).compactMap { i in
                calendar.date(byAdding: .day, value: -(i + startOffset), to: today)
                    .map { CheckIn(date: $0, isSuccess: true) }
            }
        }

        // 2. Powers (good habits)
        let powers: [(String, String, Int, Int)] = [
            // (name, icon, streakDays, daysAgoCreated)
            ("Lock In", "brain", 32, 35),
            ("Combat Prep", "dumbbell.fill", 21, 25),
            ("Hydration Max", "drop.fill", 14, 16),
            ("Deep Sleep", "moon.zzz.fill", 7, 10),
            ("Static Stretch", "figure.flexibility", 42, 45),
        ]

        for (name, icon, streak, created) in powers {
            let power = Power(name: name, icon: icon)
            power.createdAt = calendar.date(byAdding: .day, value: -created, to: Date())!
            context.insert(power)
            // "Lock In" skips today's check-in so Dial-In shows active state for screenshots
            let offset = (name == "Lock In") ? 1 : 0
            for ci in makeCheckIns(streak, startOffset: offset) {
                ci.power = power
                context.insert(ci)
            }
        }

        // 3. Agents (bad habits)
        let agents: [(String, String, Int, Int)] = [
            ("Doomscrolling", "iphone.slash", 28, 30),
            ("Junk Food", "fork.knife", 14, 16),
        ]

        for (name, icon, streak, created) in agents {
            let agent = Agent(name: name, icon: icon)
            agent.createdAt = calendar.date(byAdding: .day, value: -created, to: Date())!
            context.insert(agent)
            for ci in makeCheckIns(streak) {
                ci.agent = agent
                context.insert(ci)
            }
        }

        // 4. Achievements
        let ids = [
            "streak_1", "streak_3", "streak_7", "streak_14", "streak_21", "streak_30",
            "log_first", "log_3_day", "log_all_day", "perfect_week",
            "agent_resisted_5", "first_hack", "first_agent",
            "total_checkins_50", "total_checkins_100"
        ]
        for id in ids {
            context.insert(Achievement(id: id))
        }

        try? context.save()
        print("✅ Demo data loaded for App Store screenshots")
    }
}
#endif

// MARK: - Error View (shown if database completely fails)
struct DataErrorView: View {
    let errorMessage: String

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)

                Text("SYSTEM FAILURE")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(.red)

                Text("Unable to initialize data storage.")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.gray)

                Text("Try restarting the app or reinstalling.")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.gray)

                #if DEBUG
                Text(errorMessage)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.gray.opacity(0.6))
                    .padding()
                #endif
            }
            .padding()
        }
        .preferredColorScheme(.dark)
    }
}


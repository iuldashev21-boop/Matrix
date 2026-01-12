import SwiftUI
import SwiftData

@main
struct MatrixHabitApp: App {
    @Environment(\.scenePhase) private var scenePhase

    var sharedModelContainer: ModelContainer = {
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
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // Log error and create in-memory fallback to prevent crash
            #if DEBUG
            print("Error creating ModelContainer: \(error). Using in-memory storage.")
            #endif
            let fallbackConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            do {
                return try ModelContainer(for: schema, configurations: [fallbackConfig])
            } catch {
                fatalError("Could not create fallback ModelContainer: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(sharedModelContainer)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                // Refresh cached dates when app becomes active (prevents midnight bugs)
                DateHelper.invalidateCache()
                // Clear notification badge
                Task { @MainActor in
                    NotificationManager.shared.clearBadge()
                }
            }
        }
    }
}


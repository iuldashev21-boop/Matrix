import SwiftUI
import SwiftData

@main
struct MatrixHabitApp: App {
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
            print("Error creating ModelContainer: \(error). Using in-memory storage.")
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
    }
}

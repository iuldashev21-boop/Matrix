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
            fatalError("Could not create ModelContainer: \(error)")
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

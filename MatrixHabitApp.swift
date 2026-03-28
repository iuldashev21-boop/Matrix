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


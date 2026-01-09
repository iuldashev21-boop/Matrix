import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

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
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    var body: some View {
        CommandCenterView()
    }
}

// MARK: - Placeholder Views (To be replaced in later phases)

struct DashboardPlaceholder: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundColor.ignoresSafeArea()

                VStack(spacing: Spacing.lg) {
                    Image(systemName: "bolt.shield")
                        .font(.system(size: 64))
                        .foregroundColor(Color.matrixGreen)

                    Text("Command Center")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.primaryText)

                    Text("Your Powers and Agents will appear here")
                        .font(.body)
                        .foregroundColor(Theme.secondaryText)
                }
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct AddHabitPlaceholder: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundColor.ignoresSafeArea()

                VStack(spacing: Spacing.lg) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 64))
                        .foregroundColor(Color.matrixGreen)

                    Text("Add Habit")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.primaryText)

                    Text("Create new Powers or Agents")
                        .font(.body)
                        .foregroundColor(Theme.secondaryText)
                }
            }
            .navigationTitle("Add")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct StatsPlaceholder: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundColor.ignoresSafeArea()

                VStack(spacing: Spacing.lg) {
                    Image(systemName: "chart.bar")
                        .font(.system(size: 64))
                        .foregroundColor(Color.matrixGreen)

                    Text("Statistics")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.primaryText)

                    Text("Your progress overview")
                        .font(.body)
                        .foregroundColor(Theme.secondaryText)
                }
            }
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Onboarding Container

struct OnboardingContainerView: View {
    var body: some View {
        TerminalWakeUpView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Power.self, Agent.self, CheckIn.self], inMemory: true)
}


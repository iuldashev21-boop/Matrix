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


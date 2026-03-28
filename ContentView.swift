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


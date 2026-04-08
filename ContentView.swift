import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("hasSeenPostOnboardingPaywall") private var hasSeenPostOnboardingPaywall = false
    @AppStorage("hasSeenNotificationPrompt") private var hasSeenNotificationPrompt = false
    @State private var showPostOnboardingPaywall = false
    @State private var showNotificationPrompt = false

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
            // Edge case: user killed app after paywall but before notification prompt
            if hasCompletedOnboarding && hasSeenPostOnboardingPaywall && !hasSeenNotificationPrompt {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showNotificationPrompt = true
                }
            }
        }
        .onChange(of: hasCompletedOnboarding) { _, completed in
            if completed && !hasSeenPostOnboardingPaywall {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    showPostOnboardingPaywall = true
                    hasSeenPostOnboardingPaywall = true
                }
            }
        }
        .sheet(isPresented: $showPostOnboardingPaywall, onDismiss: {
            if !hasSeenNotificationPrompt {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showNotificationPrompt = true
                }
            }
        }) {
            RedPillPaywallView()
        }
        .sheet(isPresented: $showNotificationPrompt) {
            NotificationPermissionView(isPresented: $showNotificationPrompt)
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


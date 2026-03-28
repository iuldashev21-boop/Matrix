import SwiftUI
import SwiftData

// MARK: - Tier Promotion Sheet
// Matrix-themed modal for suggesting tier upgrades

struct TierPromotionSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let candidate: PromotionCandidate
    let onAccept: (Agent) -> Void
    let onDecline: () -> Void

    @State private var glowOpacity: Double = 0.3

    private var message: (title: String, message: String) {
        TierPromotionManager.promotionMessage(for: candidate)
    }

    var body: some View {
        ZStack {
            // Background
            Color.matrixBlack.ignoresSafeArea()

            // Subtle code rain effect
            CodeRainBackground(opacity: 0.15, speed: 0.3)
                .ignoresSafeArea()

            VStack(spacing: Spacing.xl) {
                Spacer()

                // Glowing icon
                ZStack {
                    Circle()
                        .fill(Color.matrixGreen.opacity(glowOpacity))
                        .frame(width: 120, height: 120)
                        .blur(radius: 30)

                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.matrixGreen)
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                        glowOpacity = 0.6
                    }
                }

                // Title
                Text(message.title)
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .foregroundColor(.matrixGreen)
                    .multilineTextAlignment(.center)

                // Current → Next tier display
                HStack(spacing: Spacing.lg) {
                    // Current
                    VStack(spacing: Spacing.xs) {
                        Text(candidate.currentTier.rawValue.uppercased())
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(.gray)
                        Text(candidate.currentHabit.rawValue)
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)

                    // Arrow
                    Image(systemName: "chevron.right.2")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.matrixGreen)

                    // Next
                    VStack(spacing: Spacing.xs) {
                        Text(candidate.nextTier.rawValue.uppercased())
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.matrixGreen)
                        Text(candidate.nextHabit.rawValue)
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundColor(.matrixGreen)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, Spacing.lg)

                // Message
                Text(message.message)
                    .font(.system(size: 16, design: .monospaced))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, Spacing.lg)

                // Streak badge
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("\(candidate.currentStreak) DAY STREAK")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.orange)
                }
                .padding(.vertical, Spacing.sm)
                .padding(.horizontal, Spacing.lg)
                .background(Color.orange.opacity(0.15))
                .cornerRadius(Theme.cornerRadiusCompact)

                Spacer()

                // Action buttons
                VStack(spacing: Spacing.md) {
                    // Accept button
                    Button(action: {
                        let newAgent = TierPromotionManager.promoteAgent(
                            candidate: candidate,
                            modelContext: modelContext
                        )
                        onAccept(newAgent)
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "arrow.up.circle.fill")
                            Text("ACCEPT UPGRADE")
                        }
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.matrixBlack)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.md)
                        .background(Color.matrixGreen)
                        .cornerRadius(12)
                    }

                    // Decline button
                    Button(action: {
                        TierPromotionManager.declinePromotion(for: candidate.agent)
                        onDecline()
                        dismiss()
                    }) {
                        Text("NOT YET")
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Spacing.md)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                    }

                    Text("You can upgrade later from Settings")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.gray.opacity(0.6))
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.xl)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    // Mock candidate for preview
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Agent.self, configurations: config)
    let agent = Agent(name: "No PMO (Night Shield)", icon: "eye.slash.fill")

    return TierPromotionSheet(
        candidate: PromotionCandidate(
            agent: agent,
            currentHabit: .noPMONightShield,
            nextHabit: .noPMODayGuard,
            currentStreak: 14,
            currentTier: .easy,
            nextTier: .medium
        ),
        onAccept: { _ in },
        onDecline: { }
    )
    .modelContainer(container)
}

import SwiftUI

// MARK: - Phase 15: Terminology Card (Single Card)

struct TerminologyCardPhase: View {
    let onBack: () -> Void
    let onComplete: () -> Void

    @State private var showContent: Bool = false
    @State private var showButton: Bool = false

    var body: some View {
        VStack(spacing: Spacing.xl) {
            // Back button
            HStack {
                Button(action: onBack) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("BACK")
                    }
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.mediumGray)
                }
                Spacer()
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.top, 72)

            Spacer()

            if showContent {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: Spacing.md) {
                        Text("> OPERATOR MANUAL")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.matrixGreen)
                            .matrixGlow()

                        Text("How The Construct Works")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(Color.mediumGray)
                            .padding(.bottom, Spacing.sm)

                        VStack(spacing: Spacing.sm) {
                            ManualConceptRow(
                                icon: "bolt.fill",
                                title: "HACKS",
                                description: "Good habits to UPLOAD daily",
                                color: Color.matrixGreen
                            )

                            ManualConceptRow(
                                icon: "exclamationmark.shield.fill",
                                title: "AGENTS",
                                description: "Bad habits to RESIST daily",
                                color: Color.agentRed
                            )

                            ManualConceptRow(
                                icon: "arrow.counterclockwise",
                                title: "RELAPSES",
                                description: "Failed Agent resistance. Track to learn patterns.",
                                color: Color.warning
                            )

                            ManualConceptRow(
                                icon: "star.fill",
                                title: "XP & RANKS",
                                description: "Earn XP from check-ins. Level up your Operator rank.",
                                color: Color.matrixGold
                            )

                            ManualConceptRow(
                                icon: "bolt.shield.fill",
                                title: "EMP TOKENS",
                                description: "Earn via streaks. Use to recover broken streaks.",
                                color: Color.purple
                            )
                        }
                        .padding(.horizontal, Spacing.lg)

                        VStack(spacing: Spacing.xs) {
                            Text("PROTOCOL DURATION")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(Color.mediumGray)

                            Text("66 DAYS")
                                .font(.system(size: 28, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)

                            Text("to rewire your code")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(Color.matrixGreen)
                                .matrixGlow()
                        }
                        .padding(.top, Spacing.md)
                        .padding(.bottom, Spacing.xl)
                    }
                }
                .transition(.opacity)
            }

            Spacer()

            if showButton {
                PrimaryButton(title: "NEXT_") {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    onComplete()
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.xxl)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeIn(duration: 0.4)) { showContent = true }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation { showButton = true }
            }
        }
    }
}

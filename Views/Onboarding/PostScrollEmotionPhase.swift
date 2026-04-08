import SwiftUI

// MARK: - Phase 5: Post-Scroll Emotion

struct PostScrollEmotionPhase: View {
    let tier: DemographicTier
    @Binding var answer: ScrollEmotion?
    let onBack: () -> Void
    let onComplete: () -> Void

    @State private var showContent: Bool = false

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
                VStack(spacing: Spacing.lg) {
                    Text("> ANALYZING TIME INVESTMENT...")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.matrixGreen)
                        .matrixGlow()


                    Text(OnboardingCopy(tier: tier).text(for: .postScrollQuestion))
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.lg)

                    VStack(spacing: Spacing.sm) {
                        ForEach(ScrollEmotion.allCases, id: \.self) { emotion in
                            DiagnosticButtonWithFlavor(
                                title: emotion.rawValue.uppercased(),
                                flavor: emotion.matrixFlavor,
                                isSelected: answer == emotion
                            ) {
                                answer = emotion
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.xl)
                }
                .transition(.opacity)
            }

            Spacer()

            if answer != nil {
                PrimaryButton(title: "CONTINUE_") { onComplete() }
                    .padding(.horizontal, Spacing.xl)
                    .padding(.bottom, Spacing.xxl)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation { showContent = true }
            }
        }
    }
}

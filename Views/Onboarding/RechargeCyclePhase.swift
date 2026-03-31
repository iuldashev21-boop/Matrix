import SwiftUI

// MARK: - Phase 8: Recharge Cycle (Sleep)

struct RechargeCyclePhase: View {
    @Binding var answer: SleepQuality?
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
                    Text("> CHECKING RECOVERY PROTOCOLS...")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.matrixGreen)
                        .matrixGlow()


                    Text("How would you rate your sleep quality last night?")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.lg)

                    VStack(spacing: Spacing.sm) {
                        ForEach(SleepQuality.allCases, id: \.self) { quality in
                            DiagnosticButtonWithFlavor(
                                title: quality.rawValue.uppercased(),
                                flavor: quality.matrixFlavor,
                                isSelected: answer == quality
                            ) {
                                answer = quality
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

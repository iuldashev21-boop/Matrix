import SwiftUI

// MARK: - Phase 6: Kinetic Integrity (Movement)

struct KineticIntegrityPhase: View {
    @Binding var answer: MovementLevel?
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
                    Text("> SCANNING KINETIC SYSTEMS...")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.matrixGreen)
                        .matrixGlow()


                    Text("When did you last break a sweat?")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.lg)

                    Text("Exercise, sports, physical work - anything that got your heart rate up.")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(Color.mediumGray)

                    VStack(spacing: Spacing.sm) {
                        ForEach(MovementLevel.allCases, id: \.self) { level in
                            DiagnosticButtonWithFlavor(
                                title: level.rawValue.uppercased(),
                                flavor: level.matrixFlavor,
                                isSelected: answer == level
                            ) {
                                answer = level
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

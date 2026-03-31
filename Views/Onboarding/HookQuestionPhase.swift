import SwiftUI

// MARK: - Phase 1: Hook Question

struct HookQuestionPhase: View {
    @Binding var answer: Bool?
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

                    Text("MORPHEUS:")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.matrixGreen)
                        .matrixGlow()

                    Text("Do you feel like you are living below your potential?")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.lg)

                    VStack(spacing: Spacing.md) {
                        DiagnosticButton(title: "YES", isSelected: answer == true) {
                            answer = true
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }
                        DiagnosticButton(title: "NO", isSelected: answer == false) {
                            answer = false
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
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

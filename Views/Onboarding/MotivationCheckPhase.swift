import SwiftUI

// MARK: - Phase 9: Motivation Check

struct MotivationCheckPhase: View {
    @Binding var answer: MotivationType?
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

                    Text("SYSTEM:")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.agentRed)

                    Text("Are you doing this for yourself, or because you feel you 'should'?")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.lg)

                    VStack(spacing: Spacing.md) {
                        DiagnosticButton(title: "FOR MYSELF", isSelected: answer == .myself) {
                            answer = .myself
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }
                        DiagnosticButton(title: "BECAUSE I SHOULD", isSelected: answer == .should) {
                            answer = .should
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

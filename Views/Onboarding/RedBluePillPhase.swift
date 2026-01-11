import SwiftUI

// MARK: - Phase 10: Red/Blue Pill Choice

struct RedBluePillPhase: View {
    @Binding var choseRedPill: Bool
    let onBack: () -> Void
    let onRedPill: () -> Void
    let onBluePill: () -> Void

    @State private var showContent: Bool = false
    @State private var selectedPill: String? = nil
    @State private var dimScreen: Bool = false
    @State private var showExitText: Bool = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if dimScreen {
                Color.black.opacity(0.8)
                    .ignoresSafeArea()
                    .transition(.opacity)
            }

            VStack(spacing: Spacing.xxl) {
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

                if showContent && !showExitText {
                    VStack(spacing: Spacing.lg) {
                        Text("THE CHOICE")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.matrixGreen)
                            .matrixGlow()

                        Text("The truth is not comfortable.")
                            .font(.system(size: 16, weight: .medium, design: .monospaced))
                            .foregroundColor(.white)

                        Text("Growth requires the destruction of who you are now.")
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(Color.mediumGray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Spacing.lg)

                        Text("You have a choice.")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(.top, Spacing.md)
                    }
                    .transition(.opacity)
                }

                Spacer()

                if showContent && !showExitText {
                    HStack(spacing: Spacing.xl) {
                        AwakeningPillButton(
                            color: .blue,
                            title: "STAY ASLEEP",
                            subtitle: "I'll change later.",
                            isSelected: selectedPill == "blue"
                        ) {
                            selectBluePill()
                        }

                        AwakeningPillButton(
                            color: .red,
                            title: "WAKE UP",
                            subtitle: "I accept the pain.",
                            isSelected: selectedPill == "red"
                        ) {
                            selectRedPill()
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                    .transition(.opacity.combined(with: .scale))
                }

                if showExitText {
                    Text("The Matrix will always be here waiting for you.")
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundColor(Color.blue.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .transition(.opacity)
                }

                Spacer()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeIn(duration: 0.8)) { showContent = true }
            }
        }
    }

    private func selectRedPill() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        selectedPill = "red"
        choseRedPill = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            onRedPill()
        }
    }

    private func selectBluePill() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        selectedPill = "blue"

        withAnimation(.easeOut(duration: 1.0)) {
            dimScreen = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation { showExitText = true; showContent = false }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            onBluePill()
        }
    }
}

// MARK: - Pill Button Component

struct AwakeningPillButton: View {
    let color: Color
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void

    @State private var isPulsing: Bool = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.md) {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 80, height: 40)
                    .shadow(color: color.opacity(0.8), radius: isSelected ? 20 : 12)
                    .scaleEffect(isSelected ? 1.1 : (isPulsing ? 1.03 : 1.0))

                Text(title)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(color)

                Text(subtitle)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(Color.mediumGray)
            }
            .padding(Spacing.md)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}

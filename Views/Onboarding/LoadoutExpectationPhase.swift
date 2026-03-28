import SwiftUI

// MARK: - Phase 16: Loadout Expectation

struct LoadoutExpectationPhase: View {
    let onBack: () -> Void
    let onComplete: () -> Void

    @State private var showContent: Bool = false
    @State private var iconPulse: Bool = false
    @AppStorage("soundEnabled") private var soundEnabled: Bool = true

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
                    Text("> SYSTEM ADVISORY")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.matrixGreen)
                        .matrixGlow()

                    Image(systemName: "square.stack.3d.up.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .opacity(iconPulse ? 1.0 : 0.7)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: iconPulse)

                    VStack(spacing: Spacing.md) {
                        Text("Based on your answers,")
                            .font(.system(size: 16, weight: .medium, design: .monospaced))
                            .foregroundColor(Color.lightGray)

                        Text("we'll suggest a starting loadout.")
                            .font(.system(size: 16, weight: .medium, design: .monospaced))
                            .foregroundColor(Color.lightGray)

                        Text("These are STARTING POINTS.")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(.top, Spacing.sm)

                        Text("Not a prison.")
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundColor(Color.mediumGray)

                        VStack(spacing: Spacing.xs) {
                            Text("Add habits that matter to you.")
                                .foregroundColor(Color.matrixGreen)
                            Text("e.g. daily supplements, journaling...")
                                .foregroundColor(Color.mediumGray)
                                .font(.system(size: 11, design: .monospaced))
                            Text("Remove what doesn't fit.")
                                .foregroundColor(Color.matrixGreen)
                            Text("You write the code.")
                                .foregroundColor(Color.matrixGreen)
                                .fontWeight(.bold)
                        }
                        .font(.system(size: 13, design: .monospaced))
                        .matrixGlow()
                        .padding(.top, Spacing.sm)

                        // Sound Toggle
                        HStack {
                            Image(systemName: soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                                .font(.system(size: 16))
                                .foregroundColor(soundEnabled ? Color.matrixGreen : Color.mediumGray)

                            Text("AUDIO CUES")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(soundEnabled ? Color.matrixGreen : Color.mediumGray)

                            Spacer()

                            Button(action: {
                                soundEnabled.toggle()
                                if soundEnabled {
                                    SoundManager.shared.playTap()
                                }
                            }) {
                                Text(soundEnabled ? "ON" : "OFF")
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .foregroundColor(soundEnabled ? .black : Color.mediumGray)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(soundEnabled ? Color.matrixGreen : Color.charcoal)
                                    .cornerRadius(Theme.cornerRadiusSm)
                            }
                        }
                        .padding(.horizontal, Spacing.lg)
                        .padding(.vertical, Spacing.sm)
                        .background(Color.charcoal.opacity(0.5))
                        .cornerRadius(Theme.cornerRadiusCompact)
                        .padding(.top, Spacing.lg)
                    }
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.lg)
                }
                .transition(.opacity)
            }

            Spacer()

            PrimaryButton(title: "BEGIN DIAGNOSTIC_") {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                onComplete()
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, Spacing.xxl)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation { showContent = true }
                iconPulse = true
            }
        }
    }
}

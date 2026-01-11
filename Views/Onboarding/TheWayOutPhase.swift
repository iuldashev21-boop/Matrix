import SwiftUI

// MARK: - Phase 12: The Way Out (Revelation 2)

struct TheWayOutPhase: View {
    let onBack: () -> Void
    let onComplete: () -> Void

    @State private var showContent: Bool = false
    @State private var showIcon: Bool = false
    @State private var iconState: Int = 0
    @State private var showButton: Bool = false
    @State private var buttonPulse: Bool = false
    @State private var iconGlow: Bool = false
    @State private var ringRotation: Double = 0

    var body: some View {
        ZStack {
            Color.matrixGreen.opacity(iconState == 2 ? 0.05 : 0)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: iconState)

            VStack(spacing: Spacing.lg) {
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
                        Text("> THE WAY OUT")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.matrixGreen)
                            .shadow(color: Color.matrixGreen.opacity(0.8), radius: 15)

                        if showIcon {
                            ZStack {
                                Circle()
                                    .stroke(
                                        AngularGradient(
                                            gradient: Gradient(colors: [Color.matrixGreen.opacity(0.3), Color.matrixGreen, Color.matrixGreen.opacity(0.3)]),
                                            center: .center
                                        ),
                                        lineWidth: 3
                                    )
                                    .frame(width: 120, height: 120)
                                    .rotationEffect(.degrees(ringRotation))

                                Circle()
                                    .fill(Color.matrixGreen.opacity(iconGlow ? 0.25 : 0.1))
                                    .frame(width: 100, height: 100)
                                    .shadow(color: Color.matrixGreen.opacity(iconGlow ? 0.8 : 0.4), radius: iconGlow ? 25 : 10)

                                Circle()
                                    .stroke(Color.matrixGreen, lineWidth: 2)
                                    .frame(width: 100, height: 100)

                                Image(systemName: iconState == 0 ? "lock.fill" : (iconState == 1 ? "lock.open.fill" : "checkmark.circle.fill"))
                                    .font(.system(size: iconState == 2 ? 50 : 40))
                                    .foregroundColor(Color.matrixGreen)
                                    .shadow(color: Color.matrixGreen.opacity(0.8), radius: 10)
                            }
                            .transition(.scale.combined(with: .opacity))
                        }

                        VStack(spacing: Spacing.md) {
                            Text("Take back control.")
                                .font(.system(size: 22, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                                .shadow(color: .white.opacity(0.3), radius: 5)

                            Text("Start living to your full potential.")
                                .font(.system(size: 16, weight: .medium, design: .monospaced))
                                .foregroundColor(Color.matrixGreen)
                                .shadow(color: Color.matrixGreen.opacity(0.6), radius: 8)

                            VStack(spacing: Spacing.xs) {
                                Text("Small actions, tracked daily.")
                                    .font(.system(size: 15, weight: .medium, design: .monospaced))
                                    .foregroundColor(Color.lightGray)

                                Text("That's the hack.")
                                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                            }
                            .padding(.top, Spacing.sm)

                            VStack(spacing: Spacing.xs) {
                                HStack(spacing: 0) {
                                    Text("Not motivation. ")
                                        .foregroundColor(Color.lightGray)
                                    Text("SYSTEMS.")
                                        .foregroundColor(Color.matrixGreen)
                                        .fontWeight(.bold)
                                        .shadow(color: Color.matrixGreen.opacity(0.5), radius: 5)
                                }

                                HStack(spacing: 0) {
                                    Text("Not willpower. ")
                                        .foregroundColor(Color.lightGray)
                                    Text("AWARENESS.")
                                        .foregroundColor(Color.matrixGreen)
                                        .fontWeight(.bold)
                                        .shadow(color: Color.matrixGreen.opacity(0.5), radius: 5)
                                }

                                HStack(spacing: 0) {
                                    Text("Not perfection. ")
                                        .foregroundColor(Color.lightGray)
                                    Text("CONSISTENCY.")
                                        .foregroundColor(Color.matrixGreen)
                                        .fontWeight(.bold)
                                        .shadow(color: Color.matrixGreen.opacity(0.5), radius: 5)
                                }
                            }
                            .font(.system(size: 14, design: .monospaced))
                            .padding(.top, Spacing.sm)

                            VStack(spacing: Spacing.xs) {
                                Text("66 days from now,")
                                    .font(.system(size: 14, design: .monospaced))
                                    .foregroundColor(Color.lightGray)

                                Text("you won't recognize yourself.")
                                    .font(.system(size: 17, weight: .bold, design: .monospaced))
                                    .foregroundColor(Color.matrixGreen)
                                    .shadow(color: Color.matrixGreen.opacity(0.8), radius: 12)

                                Text("The best version of you is waiting.")
                                    .font(.system(size: 13, design: .monospaced))
                                    .foregroundColor(Color.matrixGreen)
                                    .opacity(0.9)
                            }
                            .padding(.top, Spacing.md)
                        }
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.md)
                    }
                    .transition(.opacity)
                }

                Spacer()

                if showButton {
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        onComplete()
                    }) {
                        Text("INITIALIZE PROTOCOL_")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.deepBlack)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.matrixGreen)
                            .cornerRadius(Theme.cornerRadius)
                            .shadow(color: Color.matrixGreen.opacity(buttonPulse ? 1.0 : 0.5), radius: buttonPulse ? 20 : 10)
                    }
                    .padding(.horizontal, Spacing.xl)
                    .padding(.bottom, Spacing.xxl)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                ringRotation = 360
            }

            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                iconGlow = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation { showContent = true }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { showIcon = true }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation { iconState = 1 }
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { iconState = 2 }
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                withAnimation { showButton = true }
                buttonPulse = true
            }
        }
        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: buttonPulse)
    }
}

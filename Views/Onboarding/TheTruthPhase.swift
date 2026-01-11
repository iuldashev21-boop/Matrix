import SwiftUI

// MARK: - Phase 11: The Truth (Revelation 1)

struct TheTruthPhase: View {
    let onBack: () -> Void
    let onComplete: () -> Void

    @State private var revealedLines: Int = 0
    @State private var showButton: Bool = false

    private let lines: [(text: String, color: Color, isBold: Bool)] = [
        ("You are not lazy.", Color.white, false),
        ("You are not broken.", Color.white, false),
        ("You are PROGRAMMED.", Color.white, true),
        ("", Color.clear, false),
        ("Your brain didn't evolve for", Color.lightGray, false),
        ("infinite scroll feeds and", Color.lightGray, false),
        ("dopamine slot machines.", Color.lightGray, false),
        ("", Color.clear, false),
        ("Big Tech spent BILLIONS", Color.agentRed, true),
        ("engineering your addiction.", Color.agentRed, false),
        ("", Color.clear, false),
        ("The Matrix is not a metaphor.", Color.matrixGreen, true),
        ("It's your notification tray.", Color.matrixGreen, false),
        ("", Color.clear, false),
        ("But you found this app.", Color.white, false),
        ("That's the first crack", Color.white, false),
        ("in the simulation.", Color.matrixGreen, true)
    ]

    @State private var glitchOffset: CGSize = .zero
    @State private var headerGlitch: Bool = false
    @State private var textGlitch: Bool = false
    @State private var pulseOpacity: Double = 0.0
    @State private var glitchTimer: Timer?

    var body: some View {
        ZStack {
            Color.agentRed.opacity(pulseOpacity)
                .ignoresSafeArea()

            VStack(spacing: 0) {
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

                // Header with glitch effect
                ZStack {
                    if headerGlitch {
                        Text("> ANALYSIS COMPLETE")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.agentRed.opacity(0.8))
                            .offset(x: -3, y: 2)
                        Text("> ANALYSIS COMPLETE")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.cyan.opacity(0.8))
                            .offset(x: 3, y: -2)
                    }
                    Text("> ANALYSIS COMPLETE")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.matrixGreen)
                        .shadow(color: Color.matrixGreen.opacity(0.8), radius: 10)
                }
                .offset(glitchOffset)
                .padding(.bottom, Spacing.xl)

                // Revelation text
                VStack(spacing: Spacing.sm) {
                    ForEach(0..<lines.count, id: \.self) { index in
                        if index < revealedLines {
                            let line = lines[index]
                            if line.text.isEmpty {
                                Spacer().frame(height: Spacing.md)
                            } else {
                                ZStack {
                                    if textGlitch && line.isBold {
                                        Text(line.text)
                                            .font(.system(size: line.isBold ? 18 : 16, weight: line.isBold ? .bold : .medium, design: .monospaced))
                                            .foregroundColor(Color.agentRed.opacity(0.5))
                                            .offset(x: -2)
                                    }
                                    Text(line.text)
                                        .font(.system(size: line.isBold ? 18 : 16, weight: line.isBold ? .bold : .medium, design: .monospaced))
                                        .foregroundColor(line.color)
                                        .shadow(color: line.isBold ? line.color.opacity(0.8) : .clear, radius: 12)
                                }
                                .multilineTextAlignment(.center)
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .scale(scale: 0.95)),
                                    removal: .opacity
                                ))
                            }
                        }
                    }
                }
                .padding(.horizontal, Spacing.lg)

                Spacer()

                if showButton {
                    PrimaryButton(title: "CONTINUE_") {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        onComplete()
                    }
                    .padding(.horizontal, Spacing.xl)
                    .padding(.bottom, Spacing.xxl)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
        }
        .onAppear {
            startGlitchEffects()
            revealLines()
        }
        .onDisappear {
            glitchTimer?.invalidate()
            glitchTimer = nil
        }
    }

    private func startGlitchEffects() {
        glitchTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.05)) {
                headerGlitch = true
                textGlitch = true
                glitchOffset = CGSize(width: CGFloat.random(in: -4...4), height: CGFloat.random(in: -2...2))
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                withAnimation(.easeInOut(duration: 0.05)) {
                    headerGlitch = false
                    textGlitch = false
                    glitchOffset = .zero
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeIn(duration: 0.1)) { pulseOpacity = 0.15 }
            withAnimation(.easeOut(duration: 0.3).delay(0.1)) { pulseOpacity = 0 }
        }
    }

    private func revealLines() {
        for i in 0..<lines.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
                withAnimation(.easeIn(duration: 0.2)) {
                    revealedLines = i + 1
                }
                if lines[i].isBold {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + Double(lines.count) * 0.15 + 0.5) {
            withAnimation { showButton = true }
        }
    }
}

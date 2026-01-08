import SwiftUI

struct TerminalWakeUpView: View {
    // MARK: - State
    @State private var displayedText: String = ""
    @State private var currentLineIndex: Int = 0
    @State private var currentCharIndex: Int = 0
    @State private var showCursor: Bool = true
    @State private var showRabbit: Bool = false
    @State private var rabbitOpacity: Double = 0.8
    @State private var navigateToNextScreen: Bool = false

    // MARK: - Constants
    private let lines: [String] = [
        "> Wake up, Operative...",
        "> The Matrix has you.",
        "> Follow the white rabbit."
    ]
    private let typingSpeed: Double = 0.05 // 50ms per character
    private let lineDelay: Double = 0.8 // 800ms between lines
    private let cursorBlinkOn: Double = 0.8
    private let cursorBlinkOff: Double = 0.2

    var body: some View {
        ZStack {
            // Background
            Color.matrixBlack
                .ignoresSafeArea()

            VStack {
                // Top left status
                HStack {
                    Text("TERMINAL_CONNECT // SECURE")
                        .font(.system(size: 13, weight: .regular, design: .monospaced))
                        .foregroundColor(Color.mediumGray)
                    Spacer()
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.lg)

                Spacer()

                // Terminal text area
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text(displayedText + (showCursor ? "_" : " "))
                        .font(.system(size: 24, weight: .medium, design: .monospaced))
                        .foregroundColor(Color.matrixGreen)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: UIScreen.main.bounds.width * 0.85, alignment: .leading)
                .padding(.horizontal, Spacing.md)

                Spacer()

                // White Rabbit button
                if showRabbit {
                    Button(action: handleRabbitTap) {
                        Image(systemName: "hare.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.white)
                            .opacity(rabbitOpacity)
                            .shadow(color: .white.opacity(0.5), radius: 10)
                    }
                    .transition(.opacity)
                    .padding(.bottom, Spacing.xxl)
                }

                Spacer()
            }
        }
        .onAppear {
            startTypingAnimation()
            startCursorBlink()
        }
        .fullScreenCover(isPresented: $navigateToNextScreen) {
            AwakeningView(isPresented: $navigateToNextScreen)
        }
    }

    // MARK: - Typing Animation
    private func startTypingAnimation() {
        typeNextCharacter()
    }

    private func typeNextCharacter() {
        guard currentLineIndex < lines.count else {
            // All lines typed, show rabbit
            withAnimation(.easeIn(duration: 0.5)) {
                showRabbit = true
            }
            startRabbitPulse()
            return
        }

        let currentLine = lines[currentLineIndex]

        if currentCharIndex < currentLine.count {
            // Type next character
            let index = currentLine.index(currentLine.startIndex, offsetBy: currentCharIndex)
            displayedText += String(currentLine[index])
            currentCharIndex += 1

            DispatchQueue.main.asyncAfter(deadline: .now() + typingSpeed) {
                typeNextCharacter()
            }
        } else {
            // Line complete, move to next line
            displayedText += "\n"
            currentLineIndex += 1
            currentCharIndex = 0

            DispatchQueue.main.asyncAfter(deadline: .now() + lineDelay) {
                typeNextCharacter()
            }
        }
    }

    // MARK: - Cursor Blink
    private func startCursorBlink() {
        Timer.scheduledTimer(withTimeInterval: cursorBlinkOn + cursorBlinkOff, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.1)) {
                showCursor = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + cursorBlinkOn) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    showCursor = false
                }
            }
        }
    }

    // MARK: - Rabbit Pulse
    private func startRabbitPulse() {
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            rabbitOpacity = 1.0
        }
    }

    // MARK: - Actions
    private func handleRabbitTap() {
        // Light haptic
        let impactLight = UIImpactFeedbackGenerator(style: .light)
        impactLight.impactOccurred()

        // Navigate to pill choice
        withAnimation(.easeInOut(duration: 1.0)) {
            navigateToNextScreen = true
        }
    }
}

#Preview {
    TerminalWakeUpView()
}

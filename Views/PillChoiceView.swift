import SwiftUI

struct PillChoiceView: View {
    @Binding var isPresented: Bool

    // MARK: - State
    @State private var pillOffset: CGFloat = 0
    @State private var showBluePillMessage: Bool = false
    @State private var showCodeRainTransition: Bool = false
    @State private var navigateToNextScreen: Bool = false

    var body: some View {
        ZStack {
            // Background
            Color.matrixBlack
                .ignoresSafeArea()

            // Subtle code rain background
            CodeRainBackground(opacity: 0.1, speed: 0.5)
                .ignoresSafeArea()

            // Main content
            VStack(spacing: Spacing.xxl) {
                // Back button
                HStack {
                    Button(action: { isPresented = false }) {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .medium))
                            Text("BACK")
                                .font(.system(size: 14, weight: .medium, design: .monospaced))
                        }
                        .foregroundColor(Color.matrixGreen)
                    }
                    Spacer()
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.lg)

                Spacer()

                // Headline
                Text("THE CHOICE")
                    .font(.system(size: 34, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.matrixGreen)
                    .tracking(4)

                Spacer()

                // Pills
                VStack(spacing: Spacing.xl) {
                    // Red Pill
                    PillButton(
                        title: "INITIALIZE",
                        color: Color.danger,
                        glowColor: Color.danger
                    ) {
                        handleRedPillTap()
                    }
                    .offset(y: pillOffset)

                    // Blue Pill
                    PillButton(
                        title: "FORGET",
                        color: Color.blue,
                        glowColor: Color.blue
                    ) {
                        handleBluePillTap()
                    }
                    .offset(y: -pillOffset)
                }

                Spacer()
                Spacer()
            }

            // Blue pill message overlay
            if showBluePillMessage {
                BluePillMessageOverlay()
            }

            // Code rain transition overlay
            if showCodeRainTransition {
                CodeRainTransition()
            }
        }
        .onAppear {
            startFloatingAnimation()
        }
        .onChange(of: navigateToNextScreen) { _, newValue in
            if !newValue {
                // Reset transition overlay when coming back
                showCodeRainTransition = false
            }
        }
        .fullScreenCover(isPresented: $navigateToNextScreen) {
            FirstHackSetupView(isPresented: $navigateToNextScreen)
        }
    }

    // MARK: - Animations
    private func startFloatingAnimation() {
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            pillOffset = 8
        }
    }

    // MARK: - Actions
    private func handleRedPillTap() {
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()

        // Show code rain transition
        withAnimation(.easeIn(duration: 0.3)) {
            showCodeRainTransition = true
        }

        // Navigate after transition
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            navigateToNextScreen = true
        }
    }

    private func handleBluePillTap() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()

        withAnimation(.easeIn(duration: 0.3)) {
            showBluePillMessage = true
        }

        // Auto-dismiss after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeOut(duration: 0.5)) {
                showBluePillMessage = false
            }
        }
    }
}

// MARK: - Pill Button Component

struct PillButton: View {
    let title: String
    let color: Color
    let glowColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .frame(width: 200, height: 60)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
                .overlay(
                    Capsule()
                        .stroke(color.opacity(0.5), lineWidth: 1)
                )
                .shadow(color: glowColor.opacity(0.6), radius: 15)
        }
    }
}

// MARK: - Blue Pill Message Overlay

struct BluePillMessageOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()

            Text("The story ends.\nYou wake up in your bed and believe whatever you want to believe.")
                .font(.system(size: 18, weight: .medium, design: .monospaced))
                .foregroundColor(Color.matrixGreen)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)
        }
        .transition(.opacity)
    }
}

// MARK: - Code Rain Background

struct CodeRainBackground: View {
    let opacity: Double
    let speed: Double

    @State private var characters: [CodeCharacter] = []

    var body: some View {
        Canvas { context, size in
            for char in characters {
                let position = CGPoint(x: char.x, y: char.y)
                context.opacity = char.opacity * opacity
                context.draw(
                    Text(char.character)
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(Color.matrixGreen),
                    at: position
                )
            }
        }
        .onAppear {
            initializeCharacters()
            startAnimation()
        }
    }

    private func initializeCharacters() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let columns = Int(screenWidth / 20)

        characters = (0..<columns * 3).map { i in
            CodeCharacter(
                character: randomMatrixChar(),
                x: CGFloat(i % columns) * 20 + 10,
                y: CGFloat.random(in: -screenHeight...screenHeight),
                opacity: Double.random(in: 0.3...1.0),
                speed: Double.random(in: 2...6) * speed
            )
        }
    }

    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            let screenHeight = UIScreen.main.bounds.height

            for i in characters.indices {
                characters[i].y += characters[i].speed

                if characters[i].y > screenHeight + 20 {
                    characters[i].y = -20
                    characters[i].character = randomMatrixChar()
                }

                // Randomly change characters
                if Int.random(in: 0...20) == 0 {
                    characters[i].character = randomMatrixChar()
                }
            }
        }
    }

    private func randomMatrixChar() -> String {
        let matrixChars = "ﾊﾐﾋｰｳｼﾅﾓﾆｻﾜﾂｵﾘｱﾎﾃﾏｹﾒｴｶｷﾑﾕﾗｾﾈｽﾀﾇﾍ01234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return String(matrixChars.randomElement()!)
    }
}

struct CodeCharacter: Identifiable {
    let id = UUID()
    var character: String
    var x: CGFloat
    var y: CGFloat
    var opacity: Double
    var speed: Double
}

// MARK: - Code Rain Transition

struct CodeRainTransition: View {
    @State private var density: Double = 0.3
    @State private var brightness: Double = 1.0

    var body: some View {
        ZStack {
            Color.matrixBlack
                .ignoresSafeArea()

            CodeRainBackground(opacity: density, speed: 3.0)
                .ignoresSafeArea()

            Color.matrixGreen.opacity(brightness - 1.0)
                .ignoresSafeArea()
        }
        .onAppear {
            // Accelerate code rain
            withAnimation(.easeIn(duration: 1.0)) {
                density = 1.0
            }

            // Flash to green
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeIn(duration: 0.3)) {
                    brightness = 1.5
                }
            }
        }
    }
}

#Preview {
    PillChoiceView(isPresented: .constant(true))
}

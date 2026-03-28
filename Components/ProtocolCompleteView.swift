import SwiftUI

// MARK: - Protocol Complete Celebration
// Epic full-screen celebration for completing 66 days

struct ProtocolCompleteView: View {
    let habitName: String
    let isPower: Bool
    @Binding var isPresented: Bool
    var onDismiss: (() -> Void)? = nil

    // MARK: - Animation States
    @State private var phase: Int = 0
    @State private var codeRainSpeed: Double = 0.5
    @State private var codeRainOpacity: Double = 0.1
    @State private var showGlitch: Bool = false
    @State private var glitchOffset: CGSize = .zero
    @State private var ringScale: CGFloat = 0
    @State private var ringOpacity: Double = 0
    @State private var crownScale: CGFloat = 0.3
    @State private var crownOpacity: Double = 0
    @State private var titleOpacity: Double = 0
    @State private var messageOpacity: Double = 0
    @State private var particlesVisible: Bool = false
    @State private var buttonOpacity: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var showConfetti: Bool = false

    private var accentColor: Color {
        isPower ? Color.matrixGreen : Color.matrixGold
    }

    var body: some View {
        ZStack {
            // Deep black background
            Color.black
                .ignoresSafeArea()

            // Accelerating code rain
            CodeRainBackground(opacity: codeRainOpacity, speed: codeRainSpeed)
                .ignoresSafeArea()

            // Expanding rings
            ForEach(0..<5, id: \.self) { i in
                Circle()
                    .stroke(
                        accentColor.opacity(0.4 - Double(i) * 0.07),
                        lineWidth: 3 - CGFloat(i) * 0.4
                    )
                    .frame(width: 100 + CGFloat(i) * 80, height: 100 + CGFloat(i) * 80)
                    .scaleEffect(ringScale)
                    .opacity(ringOpacity)
            }

            // Golden/Green particles
            if particlesVisible {
                ParticleExplosionView(color: accentColor)
            }

            // Confetti burst
            if showConfetti {
                ConfettiView()
            }

            // Main content
            VStack(spacing: 0) {
                Spacer()

                // Phase 1: "PROTOCOL COMPLETE"
                if phase >= 1 {
                    Text("PROTOCOL")
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundColor(accentColor.opacity(0.7))
                        .tracking(8)
                        .opacity(titleOpacity)
                        .offset(glitchOffset)
                }

                // Crown icon with glow
                ZStack {
                    // Glow layers
                    Image(systemName: "crown.fill")
                        .font(.system(size: 80))
                        .foregroundColor(accentColor)
                        .blur(radius: 30)
                        .opacity(crownOpacity * 0.6)
                        .scaleEffect(pulseScale)

                    Image(systemName: "crown.fill")
                        .font(.system(size: 80))
                        .foregroundColor(accentColor)
                        .blur(radius: 15)
                        .opacity(crownOpacity * 0.8)

                    Image(systemName: "crown.fill")
                        .font(.system(size: 80))
                        .foregroundColor(accentColor)
                        .opacity(crownOpacity)
                        .scaleEffect(crownScale)
                        .offset(glitchOffset)
                }
                .padding(.vertical, Spacing.xl)

                // Phase 2: "COMPLETE" with dramatic reveal
                if phase >= 2 {
                    Text("COMPLETE")
                        .font(.system(size: 42, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                        .shadow(color: accentColor, radius: 20)
                        .shadow(color: accentColor.opacity(0.5), radius: 40)
                        .opacity(titleOpacity)
                        .offset(glitchOffset)
                }

                Spacer()
                    .frame(height: Spacing.xl)

                // Phase 3: "66 DAYS"
                if phase >= 3 {
                    HStack(spacing: Spacing.sm) {
                        Text("66")
                            .font(.system(size: 64, weight: .black, design: .monospaced))
                            .foregroundColor(accentColor)

                        Text("DAYS")
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(accentColor.opacity(0.8))
                            .offset(y: 12)
                    }
                    .opacity(messageOpacity)
                    .scaleEffect(pulseScale * 0.95 + 0.05)
                }

                // Habit name
                if phase >= 3 {
                    Text(habitName.uppercased())
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.7))
                        .tracking(2)
                        .padding(.top, Spacing.md)
                        .opacity(messageOpacity)
                }

                Spacer()

                // Phase 4: Message
                if phase >= 4 {
                    VStack(spacing: Spacing.md) {
                        Text("YOU'VE ESCAPED THE MATRIX")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(accentColor)

                        Text("This habit is now part of who you are.\nThe protocol is permanently encoded.")
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(Color.lightGray)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal, Spacing.xl)
                    .opacity(messageOpacity)
                }

                Spacer()

                // Phase 5: XP and button
                if phase >= 5 {
                    VStack(spacing: Spacing.lg) {
                        // XP Badge
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "bolt.fill")
                                .foregroundColor(accentColor)
                            Text("+330 XP")
                                .font(.system(size: 18, weight: .bold, design: .monospaced))
                                .foregroundColor(accentColor)
                            Image(systemName: "bolt.fill")
                                .foregroundColor(accentColor)
                        }
                        .padding(.vertical, Spacing.sm)
                        .padding(.horizontal, Spacing.lg)
                        .background(accentColor.opacity(0.15))
                        .cornerRadius(20)

                        // EMP Token Badge
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "bolt.shield.fill")
                                .font(.system(size: 14))
                            Text("+5 EMP TOKENS")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                        }
                        .foregroundColor(.purple)

                        // Achievement unlocked hint
                        Text("ACHIEVEMENT UNLOCKED")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(Color.matrixGold)

                        // Continue button
                        Button(action: handleDismiss) {
                            Text("CONTINUE YOUR JOURNEY")
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .foregroundColor(Color.deepBlack)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, Spacing.md)
                                .background(accentColor)
                                .cornerRadius(Theme.cornerRadius)
                        }
                        .padding(.horizontal, Spacing.xl)
                    }
                    .opacity(buttonOpacity)
                    .padding(.bottom, Spacing.xxl)
                }
            }
        }
        .onAppear {
            startCelebration()
        }
    }

    // MARK: - Animation Sequence

    private func startCelebration() {
        // Heavy haptic burst
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // Phase 0: Initial glitch
        triggerGlitch()

        // Phase 1: "PROTOCOL" text (0.3s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            phase = 1
            withAnimation(.easeOut(duration: 0.5)) {
                titleOpacity = 1.0
            }
        }

        // Accelerate code rain
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 1.0)) {
                codeRainSpeed = 3.0
                codeRainOpacity = 0.4
            }
        }

        // Phase 2: Crown + "COMPLETE" (1.0s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            phase = 2
            triggerGlitch()

            // Crown animation
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                crownScale = 1.0
                crownOpacity = 1.0
            }

            // Rings expand
            withAnimation(.easeOut(duration: 1.0)) {
                ringScale = 1.0
                ringOpacity = 1.0
            }

            // Haptic
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()
        }

        // Phase 3: "66 DAYS" + particles (1.8s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            phase = 3
            particlesVisible = true

            withAnimation(.easeOut(duration: 0.6)) {
                messageOpacity = 1.0
            }

            // Confetti burst
            showConfetti = true

            // Triple haptic burst
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                impact.impactOccurred()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                impact.impactOccurred()
            }
        }

        // Phase 4: Message (2.5s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            phase = 4
            withAnimation(.easeOut(duration: 0.5)) {
                messageOpacity = 1.0
            }
        }

        // Phase 5: XP + Button (3.2s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
            phase = 5
            withAnimation(.easeOut(duration: 0.5)) {
                buttonOpacity = 1.0
            }

            // Start pulsing crown
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulseScale = 1.1
            }

            // Settle code rain
            withAnimation(.easeOut(duration: 2.0)) {
                codeRainSpeed = 1.5
                codeRainOpacity = 0.25
            }
        }
    }

    private func triggerGlitch() {
        showGlitch = true
        GlitchEffect.trigger(
            offset: $glitchOffset,
            iterations: 10, range: -10...10, interval: 0.025, resetDelay: 0.25
        ) {
            showGlitch = false
        }
    }

    private func handleDismiss() {
        // Rewards already awarded in checkMilestone()

        // Final haptic
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        withAnimation(.easeOut(duration: 0.3)) {
            isPresented = false
        }
        onDismiss?()
    }
}

// MARK: - Particle Explosion View

struct ParticleExplosionView: View {
    let color: Color

    @State private var particles: [Particle] = []

    struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var size: CGFloat
        var opacity: Double
        var velocityX: CGFloat
        var velocityY: CGFloat
    }

    var body: some View {
        Canvas { context, size in
            for particle in particles {
                let rect = CGRect(
                    x: particle.x - particle.size / 2,
                    y: particle.y - particle.size / 2,
                    width: particle.size,
                    height: particle.size
                )
                context.opacity = particle.opacity
                context.fill(
                    Circle().path(in: rect),
                    with: .color(color)
                )
            }
        }
        .ignoresSafeArea()
        .onAppear {
            createParticles()
            animateParticles()
        }
    }

    private func createParticles() {
        let centerX = UIScreen.main.bounds.width / 2
        let centerY = UIScreen.main.bounds.height / 2

        for _ in 0..<50 {
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let speed = CGFloat.random(in: 3...8)
            particles.append(Particle(
                x: centerX,
                y: centerY,
                size: CGFloat.random(in: 4...12),
                opacity: Double.random(in: 0.6...1.0),
                velocityX: cos(angle) * speed,
                velocityY: sin(angle) * speed
            ))
        }
    }

    private func animateParticles() {
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { timer in
            var allFaded = true
            for i in particles.indices {
                particles[i].x += particles[i].velocityX
                particles[i].y += particles[i].velocityY
                particles[i].velocityY += 0.1 // gravity
                particles[i].opacity -= 0.015
                if particles[i].opacity > 0 {
                    allFaded = false
                }
            }
            if allFaded {
                timer.invalidate()
            }
        }
    }
}

// MARK: - Confetti View

struct ConfettiView: View {
    @State private var confetti: [ConfettiPiece] = []

    struct ConfettiPiece: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var rotation: Double
        var color: Color
        var size: CGFloat
        var velocityY: CGFloat
        var rotationSpeed: Double
        var swayAmplitude: CGFloat
        var swaySpeed: CGFloat
        var time: CGFloat = 0
    }

    private let colors: [Color] = [
        .matrixGreen, .matrixGold, .white, Color.cyan, Color.pink
    ]

    var body: some View {
        Canvas { context, size in
            for piece in confetti {
                context.translateBy(x: piece.x, y: piece.y)
                context.rotate(by: .degrees(piece.rotation))

                let rect = CGRect(x: -piece.size/2, y: -piece.size/4, width: piece.size, height: piece.size/2)
                context.fill(
                    RoundedRectangle(cornerRadius: 2).path(in: rect),
                    with: .color(piece.color)
                )

                context.rotate(by: .degrees(-piece.rotation))
                context.translateBy(x: -piece.x, y: -piece.y)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            createConfetti()
            animateConfetti()
        }
    }

    private func createConfetti() {
        let width = UIScreen.main.bounds.width

        for _ in 0..<60 {
            confetti.append(ConfettiPiece(
                x: CGFloat.random(in: 0...width),
                y: CGFloat.random(in: -200...(-50)),
                rotation: Double.random(in: 0...360),
                color: colors.randomElement() ?? .white,
                size: CGFloat.random(in: 8...16),
                velocityY: CGFloat.random(in: 2...5),
                rotationSpeed: Double.random(in: -10...10),
                swayAmplitude: CGFloat.random(in: 20...50),
                swaySpeed: CGFloat.random(in: 0.02...0.05)
            ))
        }
    }

    private func animateConfetti() {
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { timer in
            let height = UIScreen.main.bounds.height
            var allOffScreen = true

            for i in confetti.indices {
                confetti[i].time += confetti[i].swaySpeed
                confetti[i].x += sin(confetti[i].time) * 2
                confetti[i].y += confetti[i].velocityY
                confetti[i].rotation += confetti[i].rotationSpeed

                if confetti[i].y < height + 50 {
                    allOffScreen = false
                }
            }

            if allOffScreen {
                timer.invalidate()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ProtocolCompleteView(
        habitName: "Morning Meditation",
        isPower: true,
        isPresented: .constant(true)
    )
}

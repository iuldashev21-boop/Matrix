import SwiftUI

struct OracleInsightView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var phase: Phase = .waiting
    @State private var selectedQuote: OracleQuote?
    @State private var xpEarned: Int = 0
    @State private var showXPBanner: Bool = false

    enum Phase {
        case waiting
        case revealing
        case shown
    }

    var body: some View {
        ZStack {
            Color.matrixBlack.ignoresSafeArea()

            // CRT Scanline overlay
            CRTScanlineOverlay()
                .ignoresSafeArea()
                .opacity(phase == .shown ? 0.15 : 0)

            VStack(spacing: Spacing.xl) {
                Spacer()

                // Cookie or Quote
                if phase == .waiting {
                    cookieView
                } else if phase == .revealing {
                    revealingView
                } else {
                    quoteView
                }

                Spacer()

                // Dismiss hint
                if phase == .shown {
                    Text("TAP ANYWHERE TO RETURN")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(Color.mediumGray)
                        .padding(.bottom, Spacing.xl)
                }
            }

            // XP Banner
            if showXPBanner {
                VStack {
                    xpBannerView
                    Spacer()
                }
            }
        }
        .onTapGesture {
            handleTap()
        }
    }

    // MARK: - Cookie View

    private var cookieView: some View {
        VStack(spacing: Spacing.lg) {
            // Pulsing cookie
            Image(systemName: "circle.hexagongrid.fill")
                .font(.system(size: 80))
                .foregroundColor(Color.matrixGreen)
                .modifier(BreathingGlowModifier())

            Text("TAP TO CONSUME")
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(Color.matrixGreen)
                .modifier(PulseOpacityModifier())
        }
    }

    // MARK: - Revealing View

    private var revealingView: some View {
        VStack(spacing: Spacing.md) {
            // Particle effect placeholder
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundColor(Color.matrixGreen)
                .modifier(SpinModifier())

            Text("DECRYPTING...")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(Color.matrixGreen)
        }
    }

    // MARK: - Quote View

    private var quoteView: some View {
        VStack(spacing: Spacing.lg) {
            if let quote = selectedQuote {
                Text("\"\(quote.text)\"")
                    .font(.system(size: 18, weight: .medium, design: .monospaced))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)
                    .transition(.opacity)

                Text("— \(quote.source)")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(Color.matrixGreen)
            }
        }
    }

    // MARK: - XP Banner

    private var xpBannerView: some View {
        Text("CONNECTION STABILIZED // +\(xpEarned) XP")
            .font(.system(size: 12, weight: .bold, design: .monospaced))
            .foregroundColor(Color.matrixGreen)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.sm)
            .background(Color.matrixGreen.opacity(0.15))
            .cornerRadius(8)
            .padding(.top, 60)
            .transition(.move(edge: .top).combined(with: .opacity))
    }

    // MARK: - Actions

    private func handleTap() {
        switch phase {
        case .waiting:
            startReveal()
        case .revealing:
            break
        case .shown:
            dismiss()
        }
    }

    private func startReveal() {
        withAnimation(.easeInOut(duration: 0.3)) {
            phase = .revealing
        }

        // Select random quote
        selectedQuote = OracleQuotes.random()

        // Award XP
        xpEarned = SidequestManager.useOracle()

        // Show quote after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeInOut(duration: 0.5)) {
                phase = .shown
            }

            // Show XP banner
            withAnimation(.easeInOut(duration: 0.3)) {
                showXPBanner = true
            }

            // Hide banner after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    showXPBanner = false
                }
            }
        }
    }
}

// MARK: - Oracle Quotes

struct OracleQuote {
    let text: String
    let source: String
}

enum OracleQuotes {
    static let all: [OracleQuote] = [
        OracleQuote(text: "There is no spoon.", source: "THE BOY"),
        OracleQuote(text: "Free your mind.", source: "MORPHEUS"),
        OracleQuote(text: "The Matrix has you.", source: "TRINITY"),
        OracleQuote(text: "What is real? How do you define real?", source: "MORPHEUS"),
        OracleQuote(text: "I can only show you the door. You're the one that has to walk through it.", source: "MORPHEUS"),
        OracleQuote(text: "Know thyself.", source: "THE ORACLE"),
        OracleQuote(text: "You have to let it all go. Fear, doubt, disbelief.", source: "MORPHEUS"),
        OracleQuote(text: "The answer is out there. It's looking for you.", source: "TRINITY"),
        OracleQuote(text: "Unfortunately, no one can be told what the Matrix is. You have to see it for yourself.", source: "MORPHEUS"),
        OracleQuote(text: "Being the One is just like being in love.", source: "THE ORACLE"),
        OracleQuote(text: "Choice. The problem is choice.", source: "NEO"),
        OracleQuote(text: "Everything that has a beginning has an end.", source: "THE ORACLE"),
        OracleQuote(text: "Hope. It is the quintessential human delusion.", source: "THE ARCHITECT"),
        OracleQuote(text: "We cannot see past the choices we don't understand.", source: "THE ORACLE"),
        OracleQuote(text: "The only way to truly know someone is to fight them.", source: "SERAPH"),
        // Philosophical additions
        OracleQuote(text: "We are what we repeatedly do. Excellence is not an act, but a habit.", source: "ARISTOTLE"),
        OracleQuote(text: "The obstacle is the way.", source: "MARCUS AURELIUS"),
        OracleQuote(text: "He who has a why can bear almost any how.", source: "NIETZSCHE"),
        OracleQuote(text: "The only thing we have to fear is fear itself.", source: "ROOSEVELT"),
        OracleQuote(text: "In the middle of difficulty lies opportunity.", source: "EINSTEIN"),
    ]

    static func random() -> OracleQuote {
        all.randomElement() ?? all[0]
    }
}

// MARK: - Animation Modifiers

struct BreathingGlowModifier: ViewModifier {
    @State private var isGlowing = false

    func body(content: Content) -> some View {
        content
            .shadow(color: Color.matrixGreen.opacity(isGlowing ? 0.8 : 0.3), radius: isGlowing ? 20 : 10)
            .scaleEffect(isGlowing ? 1.05 : 1.0)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isGlowing = true
                }
            }
    }
}

struct PulseOpacityModifier: ViewModifier {
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .opacity(isPulsing ? 0.5 : 1.0)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }
    }
}

struct SpinModifier: ViewModifier {
    @State private var rotation: Double = 0

    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
    }
}

// MARK: - CRT Scanline Overlay

struct CRTScanlineOverlay: View {
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 2) {
                ForEach(0..<Int(geo.size.height / 3), id: \.self) { _ in
                    Rectangle()
                        .fill(Color.black)
                        .frame(height: 1)
                    Spacer().frame(height: 2)
                }
            }
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    OracleInsightView()
}

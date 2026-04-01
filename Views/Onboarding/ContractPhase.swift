import SwiftUI

// MARK: - Phase 14: Contract

struct ContractPhase: View {
    let onBack: () -> Void
    let onComplete: () -> Void

    @State private var showText: Bool = false
    @State private var showScanner: Bool = false
    @State private var holdProgress: CGFloat = 0
    @State private var isHolding: Bool = false
    @State private var isCompleted: Bool = false
    @State private var showFlash: Bool = false
    @State private var showFinalText: Bool = false

    private let holdDuration: Double = 3.0

    var body: some View {
        ZStack {
            CodeRainBackground(opacity: 0.2 + Double(holdProgress) * 0.4, speed: 0.5 + Double(holdProgress) * 3.0)
                .ignoresSafeArea()

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

                if showText {
                    VStack(spacing: Spacing.md) {
                        Text("THE CONTRACT")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.matrixGreen)
                            .matrixGlow()

                        Text("This is the Red Pill.")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)

                        Text("There is no turning back.")
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundColor(Color.lightGray)
                    }
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)
                    .transition(.opacity)
                }

                Spacer()

                if showScanner {
                    VStack(spacing: Spacing.lg) {
                        ZStack {
                            Circle()
                                .stroke(Color.matrixGreen.opacity(0.3), lineWidth: 4)
                                .frame(width: 150, height: 150)
                            Circle()
                                .trim(from: 0, to: holdProgress)
                                .stroke(Color.matrixGreen, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                .frame(width: 150, height: 150)
                                .rotationEffect(.degrees(-90))
                                .shadow(color: Color.matrixGreen.opacity(0.6), radius: 8)
                            Circle()
                                .fill(Color.charcoal)
                                .frame(width: 130, height: 130)
                            Image(systemName: "touchid")
                                .font(.system(size: 50))
                                .foregroundColor(holdProgress > 0 ? Color.matrixGreen : Color.mediumGray)
                        }
                        .scaleEffect(isHolding ? 0.95 : 1.0)
                        .animation(.easeInOut(duration: 0.1), value: isHolding)
                        .gesture(DragGesture(minimumDistance: 0).onChanged { _ in startHold() }.onEnded { _ in endHold() })

                        Text("> HOLD TO DISCONNECT FROM SIMULATION")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(Color.mediumGray)
                    }
                    .transition(.opacity.combined(with: .scale))
                }

                Spacer()
            }

            if showFlash { Color.white.ignoresSafeArea().transition(.opacity) }

            if showFinalText {
                Text("WELCOME TO THE DESERT OF THE REAL.")
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.matrixGreen)
                    .matrixGlow()
                    .multilineTextAlignment(.center)
                    .transition(.opacity)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { withAnimation { showText = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { withAnimation { showScanner = true } }
        }
    }

    private func startHold() {
        guard !isHolding && !isCompleted && holdProgress < 1.0 else { return }
        isHolding = true
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation(.linear(duration: holdDuration)) { holdProgress = 1.0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + holdDuration) { if isHolding && !isCompleted { completeContract() } }
        for i in 1...10 {
            DispatchQueue.main.asyncAfter(deadline: .now() + holdDuration * Double(i) / 10.0) {
                guard isHolding else { return }
                UIImpactFeedbackGenerator(style: i < 5 ? .light : (i < 8 ? .medium : .heavy)).impactOccurred()
            }
        }
    }

    private func endHold() {
        guard holdProgress < 1.0 else { return }
        isHolding = false
        withAnimation(.easeOut(duration: 0.3)) { holdProgress = 0 }
    }

    private func completeContract() {
        guard !isCompleted else { return }
        isCompleted = true
        SoundManager.shared.playProtocolComplete()
        withAnimation(.easeIn(duration: 0.1)) { showFlash = true; showText = false; showScanner = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { withAnimation(.easeOut(duration: 0.3)) { showFlash = false } }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { withAnimation { showFinalText = true } }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { onComplete() }
    }
}

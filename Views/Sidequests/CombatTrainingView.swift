import SwiftUI

struct CombatTrainingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var phase: Phase = .loading
    @State private var challenge: CombatChallenge?
    @State private var timeRemaining: Int = 60
    @State private var timer: Timer?
    @State private var canComplete: Bool = false
    @State private var xpEarned: Int = 0
    @State private var showShockwave: Bool = false

    enum Phase {
        case loading
        case active
        case completed
    }

    var body: some View {
        ZStack {
            Color.matrixBlack.ignoresSafeArea()

            // Shockwave effect
            if showShockwave {
                ShockwaveView()
                    .ignoresSafeArea()
            }

            VStack(spacing: Spacing.xl) {
                // Header
                headerView

                Spacer()

                // Content based on phase
                switch phase {
                case .loading:
                    loadingView
                case .active:
                    activeView
                case .completed:
                    completedView
                }

                Spacer()
            }
            .padding()
        }
        .onAppear {
            startLoading()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color.mediumGray)
            }

            Spacer()

            Text("COMBAT_DOJO")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(Color.matrixGreen)

            Spacer()

            // Spacer for alignment
            Color.clear.frame(width: 24, height: 24)
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: Spacing.lg) {
            Text("LOADING DOJO...")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(Color.matrixGreen)

            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.matrixGreen))
                .scaleEffect(1.5)
        }
    }

    // MARK: - Active View

    private var activeView: some View {
        VStack(spacing: Spacing.xl) {
            // Challenge name
            if let challenge = challenge {
                Text("COMBAT MODULE:")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(Color.mediumGray)

                Text(challenge.name.uppercased())
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.matrixGreen)

                Text(challenge.description)
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(Color.lightGray)
                    .multilineTextAlignment(.center)
            }

            // Timer
            ZStack {
                Circle()
                    .stroke(Color.charcoal, lineWidth: 8)
                    .frame(width: 150, height: 150)

                Circle()
                    .trim(from: 0, to: CGFloat(timeRemaining) / 60.0)
                    .stroke(Color.matrixGreen, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))

                Text(String(format: "%02d:%02d", timeRemaining / 60, timeRemaining % 60))
                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.matrixGreen)
            }

            // Complete button
            Button(action: completeChallenge) {
                Text("COMPLETE")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(canComplete ? Color.deepBlack : Color.mediumGray)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(canComplete ? Color.matrixGreen : Color.charcoal)
                    .cornerRadius(12)
            }
            .disabled(!canComplete)
            .padding(.horizontal, Spacing.xl)
        }
    }

    // MARK: - Completed View

    private var completedView: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(Color.matrixGreen)

            Text("SKILL_ACQUIRED")
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundColor(Color.matrixGreen)

            Text("+\(xpEarned) XP")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(Color.matrixGreen)

            Button(action: { dismiss() }) {
                Text("EXIT DOJO")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.matrixGreen)
                    .padding(.horizontal, Spacing.xl)
                    .padding(.vertical, Spacing.md)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.matrixGreen, lineWidth: 2)
                    )
            }
            .padding(.top, Spacing.md)
        }
    }

    // MARK: - Logic

    private func startLoading() {
        challenge = CombatChallenges.random()

        // Simulate loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                phase = .active
            }
            startTimer()
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1

                // Enable complete after 5 seconds
                if timeRemaining <= 55 && !canComplete {
                    withAnimation {
                        canComplete = true
                    }
                }
            } else {
                timer?.invalidate()
                // Auto-complete when timer ends
                completeChallenge()
            }
        }
    }

    private func completeChallenge() {
        timer?.invalidate()

        // Shockwave effect
        withAnimation(.easeOut(duration: 0.5)) {
            showShockwave = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showShockwave = false
        }

        xpEarned = SidequestManager.completeCombatTraining()

        withAnimation {
            phase = .completed
        }
    }
}

// MARK: - Combat Challenges

struct CombatChallenge {
    let name: String
    let description: String
}

enum CombatChallenges {
    static let all: [CombatChallenge] = [
        CombatChallenge(name: "PUSHUPS", description: "Complete 10 pushups with proper form"),
        CombatChallenge(name: "SQUATS", description: "Complete 20 bodyweight squats"),
        CombatChallenge(name: "PLANK", description: "Hold a plank position for 60 seconds"),
        CombatChallenge(name: "JUMPING JACKS", description: "Complete 30 jumping jacks"),
        CombatChallenge(name: "LUNGES", description: "Complete 10 lunges per leg"),
        CombatChallenge(name: "BURPEES", description: "Complete 5 burpees"),
        CombatChallenge(name: "WALL SIT", description: "Hold a wall sit for 45 seconds"),
        CombatChallenge(name: "HIGH KNEES", description: "Run in place with high knees for 60 seconds"),
        CombatChallenge(name: "MOUNTAIN CLIMBERS", description: "Complete 20 mountain climbers"),
        CombatChallenge(name: "STRETCH", description: "Stretch your hamstrings and hold for 60 seconds"),
    ]

    static func random() -> CombatChallenge {
        all.randomElement() ?? all[0]
    }
}

// MARK: - Shockwave View

struct ShockwaveView: View {
    @State private var scale: CGFloat = 0.1
    @State private var opacity: Double = 1.0

    var body: some View {
        Circle()
            .stroke(Color.matrixGreen, lineWidth: 3)
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) {
                    scale = 3.0
                    opacity = 0
                }
            }
    }
}

#Preview {
    CombatTrainingView()
}


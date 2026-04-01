import SwiftUI

// MARK: - Phase 3: Years Deleted

struct YearsDeletedPhase: View {
    let age: Int
    @Binding var hoursLost: Int
    let onBack: () -> Void
    let onComplete: () -> Void

    @State private var showContent: Bool = false
    @State private var showResult: Bool = false
    @State private var animatedYears: Double = 0

    private var percentOfLife: Int {
        Int((Double(hoursLost) / 16.0) * 100)
    }

    private var yearsDeleted: Double {
        let remainingYears = Double(80 - age)
        return (Double(hoursLost) / 16.0) * remainingYears
    }

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

            if showContent && !showResult {
                VStack(spacing: Spacing.lg) {

                    Text("How many hours do you lose to these loops daily?")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.lg)

                    Text("\(hoursLost) HOURS")
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.agentRed)
                        .shadow(color: Color.agentRed.opacity(0.5), radius: 8)

                    Slider(value: Binding(
                        get: { Double(hoursLost) },
                        set: { hoursLost = Int($0) }
                    ), in: 1...8, step: 1)
                    .accentColor(Color.agentRed)
                    .padding(.horizontal, Spacing.xl)

                    HStack {
                        Text("1 hr").font(.system(size: 12, design: .monospaced)).foregroundColor(Color.mediumGray)
                        Spacer()
                        Text("8 hrs").font(.system(size: 12, design: .monospaced)).foregroundColor(Color.mediumGray)
                    }
                    .padding(.horizontal, Spacing.xl)

                    PrimaryButton(title: "CALCULATE DAMAGE", color: Color.agentRed) {
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        withAnimation { showResult = true }
                        animateYears()
                    }
                    .padding(.horizontal, Spacing.xl)
                }
                .transition(.opacity)
            }

            if showResult {
                VStack(spacing: Spacing.lg) {
                    Text("> CALCULATING TIME LOST...")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.agentRed)

                    VStack(spacing: Spacing.sm) {
                        TimeBreakdownRow(label: "PER DAY", value: "\(hoursLost) hours")
                        TimeBreakdownRow(label: "PER WEEK", value: "\(hoursLost * 7) hours")
                        TimeBreakdownRow(label: "PER MONTH", value: "\(hoursLost * 30) hours")
                        TimeBreakdownRow(label: "PER YEAR", value: String(format: "%.0f days", Double(hoursLost * 365) / 24.0))
                    }
                    .padding(.vertical, Spacing.md)

                    VStack(spacing: Spacing.sm) {
                        Text("LIFETIME COST:")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.agentRed)

                        Text(String(format: "%.1f", animatedYears))
                            .font(.system(size: 72, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.agentRed)
                            .shadow(color: Color.agentRed.opacity(0.6), radius: 10)

                        Text("YEARS DELETED")
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.agentRed)

                        Text("(by age 80)")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(Color.mediumGray)
                    }

                    Text("That's \(Int(yearsDeleted)) years you could spend building something real.")
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundColor(Color.matrixGreen)
                        .matrixGlow()
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.sm)
                }
                .transition(.opacity.combined(with: .scale))
            }

            Spacer()

            if showResult {
                PrimaryButton(title: "I AM ANGRY", color: Color.agentRed) { onComplete() }
                    .padding(.horizontal, Spacing.xl)
                    .padding(.bottom, Spacing.xxl)
                    .scaleEffect(1.0)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: showResult)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation { showContent = true }
            }
        }
    }

    private func animateYears() {
        let target = yearsDeleted
        let duration: Double = 2.0
        let steps = 40
        for i in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration * Double(i) / Double(steps)) {
                animatedYears = target * Double(i) / Double(steps)
            }
        }
    }
}

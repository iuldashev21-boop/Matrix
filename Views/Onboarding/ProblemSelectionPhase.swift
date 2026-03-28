import SwiftUI

// MARK: - Phase 2: Problem Selection

struct ProblemSelectionPhase: View {
    @Binding var selectedProblems: Set<ModernProblem>
    let onBack: () -> Void
    let onComplete: () -> Void

    @State private var showContent: Bool = false

    var body: some View {
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

            if showContent {
                VStack(spacing: Spacing.sm) {
                    Text("DIAGNOSTIC 2/9")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.mediumGray)
                        .padding(.top, Spacing.md)

                    Text("SYSTEM:")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.agentRed)

                    Text("Detecting control programs...")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)

                    Text("Select all that apply")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(Color.mediumGray)
                }
                .padding(.bottom, Spacing.md)

                ScrollView {
                    VStack(spacing: Spacing.sm) {
                        ForEach(ModernProblem.allCases) { problem in
                            ProblemCard(
                                problem: problem,
                                isSelected: selectedProblems.contains(problem)
                            ) {
                                toggleProblem(problem)
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.bottom, Spacing.lg)
                }
            }

            if !selectedProblems.isEmpty {
                PrimaryButton(title: "ACKNOWLEDGE CHAINS_", color: Color.agentRed) { onComplete() }
                    .padding(.horizontal, Spacing.xl)
                    .padding(.bottom, Spacing.xxl)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation { showContent = true }
            }
        }
    }

    private func toggleProblem(_ problem: ModernProblem) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if problem == .allAbove {
            if selectedProblems.contains(.allAbove) {
                selectedProblems.removeAll()
            } else {
                selectedProblems = Set(ModernProblem.allCases)
            }
        } else {
            if selectedProblems.contains(problem) {
                selectedProblems.remove(problem)
                selectedProblems.remove(.allAbove)
            } else {
                selectedProblems.insert(problem)
            }
        }
    }
}

// MARK: - Problem Card

struct ProblemCard: View {
    let problem: ModernProblem
    let isSelected: Bool
    let action: () -> Void

    @State private var jitterOffset: CGFloat = 0

    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.05)) { jitterOffset = 4 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation(.easeInOut(duration: 0.05)) { jitterOffset = -2 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.05)) { jitterOffset = 0 }
            }
            action()
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(problem.rawValue.uppercased())
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(isSelected ? Color.agentRed : .white)
                    Text(problem.description)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color.lightGray)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color.agentRed)
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 18))
                        .foregroundColor(Color.mediumGray)
                }
            }
            .padding(Spacing.md)
            .background(Color.charcoal)
            .cornerRadius(Theme.cornerRadiusCompact)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadiusCompact)
                    .stroke(isSelected ? Color.agentRed : Color.mediumGray.opacity(0.5), lineWidth: isSelected ? 2 : 1)
                    .shadow(color: isSelected ? Color.agentRed.opacity(0.4) : .clear, radius: 4)
            )
        }
        .offset(x: jitterOffset, y: -jitterOffset / 2)
    }
}

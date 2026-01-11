import SwiftUI

// MARK: - Phase 13: Solution Protocol

struct SolutionProtocolPhase: View {
    @Binding var loadout: ProtocolLoadout
    let onBack: () -> Void
    let onComplete: () -> Void

    @State private var showContent: Bool = false
    @State private var revealedHacks: Int = 0
    @State private var revealedAgents: Int = 0
    @State private var showAgentsSection: Bool = false

    private var totalItems: Int { loadout.hacks.count + loadout.agents.count }
    private var allRevealed: Bool { revealedHacks >= loadout.hacks.count && revealedAgents >= loadout.agents.count }

    var body: some View {
        ScrollView {
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

                if showContent {
                    VStack(spacing: Spacing.sm) {
                        Text("YOUR PROTOCOL")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.matrixGreen)
                            .matrixGlow()

                        Text("> INITIALIZING LOADOUT...")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(Color.mediumGray)
                    }
                }

                // HACKS Section
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("// HACKS TO UPLOAD")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.matrixGreen)
                        .matrixGlow()
                        .padding(.horizontal, Spacing.lg)

                    ForEach(Array(loadout.hacks.enumerated()), id: \.element) { index, hack in
                        if index < revealedHacks {
                            HackCard(hack: hack)
                                .padding(.horizontal, Spacing.lg)
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .move(edge: .leading)),
                                    removal: .opacity
                                ))
                        }
                    }
                }

                // AGENTS Section
                if showAgentsSection {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("// AGENTS TO BLOCK")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.agentRed)
                            .padding(.horizontal, Spacing.lg)

                        ForEach(Array(loadout.agents.enumerated()), id: \.element) { index, agent in
                            if index < revealedAgents {
                                AgentCard(agent: agent)
                                    .padding(.horizontal, Spacing.lg)
                                    .transition(.asymmetric(
                                        insertion: .opacity.combined(with: .move(edge: .trailing)),
                                        removal: .opacity
                                    ))
                            }
                        }
                    }
                }

                if allRevealed {
                    VStack(spacing: Spacing.xs) {
                        Text("SYSTEM NOTE:")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.mediumGray)

                        Text("This is your starting loadout.")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(Color.lightGray)

                        Text("Customize anytime in the Mainframe.")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(Color.matrixGreen)
                            .matrixGlow()
                    }
                    .multilineTextAlignment(.center)
                    .padding(.top, Spacing.md)
                    .padding(.horizontal, Spacing.xl)
                }

                if allRevealed {
                    PrimaryButton(title: "INITIATE PROTOCOL_") { onComplete() }
                        .padding(.horizontal, Spacing.xl)
                        .padding(.top, Spacing.md)
                        .padding(.bottom, Spacing.xxl)
                }
            }
            .padding(.top, Spacing.md)
        }
        .animation(.easeInOut(duration: 0.4), value: revealedHacks)
        .animation(.easeInOut(duration: 0.4), value: revealedAgents)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation { showContent = true }
            }
            revealItems()
        }
    }

    private func revealItems() {
        for i in 0..<loadout.hacks.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6 + Double(i) * 0.4) {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                withAnimation { revealedHacks = i + 1 }
            }
        }

        let hacksDelay = 0.6 + Double(loadout.hacks.count) * 0.4 + 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + hacksDelay) {
            withAnimation { showAgentsSection = true }
        }

        for i in 0..<loadout.agents.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + hacksDelay + 0.3 + Double(i) * 0.4) {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                withAnimation { revealedAgents = i + 1 }
            }
        }
    }
}

// MARK: - Hack Card

struct HackCard: View {
    let hack: HackHabit

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: hack.icon)
                .font(.system(size: 24))
                .foregroundColor(Color.matrixGreen)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(hack.habitName)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.matrixGreen)

                Text(hack.description)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(Color.lightGray)
                    .lineLimit(2)
            }

            Spacer()

            Text("DO")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(Color.deepBlack)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.matrixGreen)
                .cornerRadius(4)
        }
        .padding(Spacing.md)
        .background(Color.charcoal)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.matrixGreen.opacity(0.5), lineWidth: 1)
        )
    }
}

// MARK: - Agent Card

struct AgentCard: View {
    let agent: AgentHabit

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: agent.icon)
                .font(.system(size: 24))
                .foregroundColor(Color.agentRed)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(agent.habitName)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.agentRed)

                Text(agent.counterTactic)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(Color.lightGray)
                    .lineLimit(2)
            }

            Spacer()

            Text("RESIST")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.agentRed)
                .cornerRadius(4)
        }
        .padding(Spacing.md)
        .background(Color.charcoal)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.agentRed.opacity(0.5), lineWidth: 1)
        )
    }
}

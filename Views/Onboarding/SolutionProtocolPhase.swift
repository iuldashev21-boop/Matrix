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
    @State private var isCustomizing: Bool = false

    private var totalItems: Int { loadout.hacks.count + loadout.agents.count }
    private var allRevealed: Bool { revealedHacks >= loadout.hacks.count && revealedAgents >= loadout.agents.count }

    // Available habits to add (excluding already selected ones)
    private var availableHacks: [HackHabit] {
        HackHabit.allCases.filter { !loadout.hacks.contains($0) }
    }

    private var availableAgents: [AgentHabit] {
        AgentHabit.allCases.filter { !loadout.agents.contains($0) }
    }

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

                if allRevealed && !isCustomizing {
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

                // Customize Mode
                if isCustomizing {
                    customizeView
                }

                if allRevealed {
                    VStack(spacing: Spacing.sm) {
                        PrimaryButton(title: "INITIATE PROTOCOL_") { onComplete() }

                        if !isCustomizing {
                            Button(action: {
                                withAnimation { isCustomizing = true }
                            }) {
                                Text("CUSTOMIZE")
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    .foregroundColor(Color.matrixGreen)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Theme.cornerRadius)
                                            .stroke(Color.matrixGreen.opacity(0.5), lineWidth: 1)
                                    )
                            }
                        } else {
                            Button(action: {
                                withAnimation { isCustomizing = false }
                            }) {
                                Text("DONE CUSTOMIZING")
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    .foregroundColor(Color.mediumGray)
                            }
                        }
                    }
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

    // MARK: - Customize View

    private var customizeView: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            // Current Hacks with delete
            if !loadout.hacks.isEmpty {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("// YOUR HACKS")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.matrixGreen)
                        .padding(.horizontal, Spacing.lg)

                    ForEach(loadout.hacks, id: \.self) { hack in
                        EditableHackCard(hack: hack) {
                            withAnimation {
                                loadout.hacks.removeAll { $0 == hack }
                            }
                        }
                        .padding(.horizontal, Spacing.lg)
                    }
                }
            }

            // Add Hacks Section
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("+ ADD HACK")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.matrixGreen.opacity(0.7))
                    .padding(.horizontal, Spacing.lg)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.sm) {
                        ForEach(availableHacks, id: \.self) { hack in
                            HackChip(hack: hack) {
                                withAnimation {
                                    loadout.hacks.append(hack)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                }
            }

            // Current Agents with delete
            if !loadout.agents.isEmpty {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("// YOUR AGENTS")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.agentRed)
                        .padding(.horizontal, Spacing.lg)

                    ForEach(loadout.agents, id: \.self) { agent in
                        EditableAgentCard(agent: agent) {
                            withAnimation {
                                loadout.agents.removeAll { $0 == agent }
                            }
                        }
                        .padding(.horizontal, Spacing.lg)
                    }
                }
            }

            // Add Agents Section
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("+ ADD AGENT")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.agentRed.opacity(0.7))
                    .padding(.horizontal, Spacing.lg)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.sm) {
                        ForEach(availableAgents, id: \.self) { agent in
                            AgentChip(agent: agent) {
                                withAnimation {
                                    loadout.agents.append(agent)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                }
            }
        }
        .padding(.vertical, Spacing.md)
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
                .cornerRadius(Theme.cornerRadiusSm)
        }
        .padding(Spacing.md)
        .background(Color.charcoal)
        .cornerRadius(Theme.cornerRadiusCompact)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadiusCompact)
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
                .cornerRadius(Theme.cornerRadiusSm)
        }
        .padding(Spacing.md)
        .background(Color.charcoal)
        .cornerRadius(Theme.cornerRadiusCompact)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadiusCompact)
                .stroke(Color.agentRed.opacity(0.5), lineWidth: 1)
        )
    }
}

// MARK: - Editable Hack Card (with delete button)

struct EditableHackCard: View {
    let hack: HackHabit
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: hack.icon)
                .font(.system(size: 20))
                .foregroundColor(Color.matrixGreen)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(hack.habitName)
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.matrixGreen)

                Text(hack.shortDescription)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(Color.lightGray)
                    .lineLimit(1)
            }

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color.mediumGray)
            }
        }
        .padding(Spacing.sm)
        .background(Color.charcoal)
        .cornerRadius(Theme.cornerRadiusCompact)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadiusCompact)
                .stroke(Color.matrixGreen.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Editable Agent Card (with delete button)

struct EditableAgentCard: View {
    let agent: AgentHabit
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: agent.icon)
                .font(.system(size: 20))
                .foregroundColor(Color.agentRed)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(agent.habitName)
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.agentRed)

                Text(agent.shortDescription)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(Color.lightGray)
                    .lineLimit(1)
            }

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color.mediumGray)
            }
        }
        .padding(Spacing.sm)
        .background(Color.charcoal)
        .cornerRadius(Theme.cornerRadiusCompact)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadiusCompact)
                .stroke(Color.agentRed.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Hack Chip (for adding)

struct HackChip: View {
    let hack: HackHabit
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: hack.icon)
                    .font(.system(size: 12))
                Text(hack.habitName)
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
            }
            .foregroundColor(Color.matrixGreen)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(Color.matrixGreen.opacity(0.15))
            .cornerRadius(Theme.cornerRadiusCompact)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadiusCompact)
                    .stroke(Color.matrixGreen.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - Agent Chip (for adding)

struct AgentChip: View {
    let agent: AgentHabit
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: agent.icon)
                    .font(.system(size: 12))
                Text(agent.habitName)
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
            }
            .foregroundColor(Color.agentRed)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(Color.agentRed.opacity(0.15))
            .cornerRadius(Theme.cornerRadiusCompact)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadiusCompact)
                    .stroke(Color.agentRed.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

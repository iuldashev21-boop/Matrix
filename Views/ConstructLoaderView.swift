import SwiftUI

struct ConstructLoaderView: View {
    @State private var showOracle: Bool = false
    @State private var showCodeBreaker: Bool = false
    @State private var showCombatTraining: Bool = false
    @State private var showMaintenance: Bool = false

    var body: some View {
        VStack(spacing: Spacing.sm) {
            // Oracle's Insight
            ProgramCard(
                id: "ORACLE_LINK",
                title: "ORACLE'S INSIGHT",
                description: "Receive cryptic wisdom",
                icon: "eye",
                xpReward: SidequestManager.oracleXP,
                isAvailable: SidequestManager.canUseOracle,
                remainingUses: SidequestManager.oracleRemainingUses,
                maxUses: SidequestManager.oracleDailyLimit
            ) {
                showOracle = true
            }

            // Code Breaker
            ProgramCard(
                id: "CODE_BREAKER",
                title: "CODE BREAKER",
                description: "Hack the 4-digit sequence",
                icon: "lock.shield",
                xpReward: SidequestManager.codeBreakerXP,
                isAvailable: SidequestManager.canPlayCodeBreaker,
                remainingUses: SidequestManager.codeBreakerCompletedToday ? 0 : 1,
                maxUses: 1
            ) {
                showCodeBreaker = true
            }

            // Combat Training
            ProgramCard(
                id: "COMBAT_DOJO",
                title: "COMBAT TRAINING",
                description: "60-second physical challenge",
                icon: "figure.martial.arts",
                xpReward: SidequestManager.combatXP,
                isAvailable: SidequestManager.canDoCombatTraining,
                remainingUses: SidequestManager.combatRemainingUses,
                maxUses: SidequestManager.combatDailyLimit
            ) {
                showCombatTraining = true
            }

            // System Maintenance
            ProgramCard(
                id: "SYS_MAINT",
                title: "SYSTEM MAINTENANCE",
                description: "Clear environmental glitches",
                icon: "wrench.and.screwdriver",
                xpReward: SidequestManager.maintenanceXP,
                isAvailable: SidequestManager.canDoMaintenance,
                remainingUses: SidequestManager.maintenanceRemainingUses,
                maxUses: SidequestManager.maintenanceDailyLimit
            ) {
                showMaintenance = true
            }
        }
        .padding(.horizontal, Spacing.md)
        .sheet(isPresented: $showOracle) {
            OracleInsightView()
        }
        .sheet(isPresented: $showCodeBreaker) {
            CodeBreakerView()
        }
        .sheet(isPresented: $showCombatTraining) {
            CombatTrainingView()
        }
        .sheet(isPresented: $showMaintenance) {
            SystemMaintenanceView()
        }
    }
}

// MARK: - Program Card

struct ProgramCard: View {
    let id: String
    let title: String
    let description: String
    let icon: String
    let xpReward: Int
    let isAvailable: Bool
    let remainingUses: Int
    let maxUses: Int
    let action: () -> Void

    private var statusText: String {
        if !isAvailable && remainingUses == 0 {
            return "SYNCED"
        } else if !isAvailable {
            return "XP CAP REACHED"
        }
        return "\(remainingUses)/\(maxUses)"
    }

    var body: some View {
        Button(action: {
            if isAvailable {
                action()
            }
        }) {
            HStack(spacing: Spacing.md) {
                // Program Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isAvailable ? Color.matrixGreen.opacity(0.15) : Color.charcoal)
                        .frame(width: 44, height: 44)

                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(isAvailable ? Color.matrixGreen : Color.mediumGray)
                }

                // Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(isAvailable ? .white : Color.mediumGray)

                    Text(description)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(Color.mediumGray)
                }

                Spacer()

                // Status / XP
                VStack(alignment: .trailing, spacing: 2) {
                    if isAvailable {
                        Text("+\(xpReward) XP")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.matrixGreen)
                    }

                    Text(statusText)
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(isAvailable ? Color.lightGray : Color.mediumGray)
                }

                // Load indicator
                if isAvailable {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(Color.matrixGreen)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color.mediumGray)
                }
            }
            .padding(Spacing.md)
            .background(isAvailable ? Color.charcoal : Color.charcoal.opacity(0.5))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isAvailable ? Color.matrixGreen.opacity(0.3) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(!isAvailable)
        .opacity(isAvailable ? 1.0 : 0.7)
    }
}

#Preview {
    ZStack {
        Color.matrixBlack.ignoresSafeArea()
        ConstructLoaderView()
    }
}

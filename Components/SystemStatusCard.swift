import SwiftUI

// MARK: - System Status Card (Compact Stats)

struct SystemStatusCard: View {
    let todayCompleted: Int
    let todayTotal: Int
    let currentStreak: Int
    let daysActive: Int
    let relapseCount: Int

    @State private var appeared: Bool = false
    @State private var pulseOpacity: Double = 1.0

    private var completionRatio: Double {
        guard todayTotal > 0 else { return 0 }
        return Double(todayCompleted) / Double(todayTotal)
    }

    var body: some View {
        VStack(spacing: Spacing.sm) {
            // Header
            HStack {
                Text("// SYSTEM STATUS")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.lightGray)
                Spacer()
                statusIndicator
            }

            // Stats Row
            HStack(spacing: 0) {
                // Today's Progress (X/Y)
                VStack(spacing: 4) {
                    HStack(spacing: 2) {
                        Text("\(todayCompleted)")
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundColor(todayColor)
                        Text("/")
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundColor(Color.mediumGray)
                        Text("\(todayTotal)")
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundColor(Color.mediumGray)
                    }
                    Text("TODAY")
                        .font(.system(size: 8, design: .monospaced))
                        .foregroundColor(Color.mediumGray)
                }
                .frame(maxWidth: .infinity)

                divider

                // Best Streak
                VStack(spacing: 4) {
                    HStack(spacing: 3) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 12))
                            .foregroundColor(currentStreak > 0 ? .orange : Color.mediumGray)
                        Text("\(currentStreak)")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(currentStreak > 0 ? .white : Color.mediumGray)
                    }
                    Text("STREAK")
                        .font(.system(size: 8, design: .monospaced))
                        .foregroundColor(Color.mediumGray)
                }
                .frame(maxWidth: .infinity)

                divider

                // Days Active
                VStack(spacing: 4) {
                    HStack(spacing: 2) {
                        Text("\(daysActive)")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.matrixGreen)
                    }
                    Text("DAYS")
                        .font(.system(size: 8, design: .monospaced))
                        .foregroundColor(Color.mediumGray)
                }
                .frame(maxWidth: .infinity)

                divider

                // Relapses
                VStack(spacing: 4) {
                    HStack(spacing: 3) {
                        Image(systemName: "bolt.slash.fill")
                            .font(.system(size: 12))
                            .foregroundColor(relapseCount > 0 ? Color.agentRed : Color.mediumGray)
                        Text("\(relapseCount)")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(relapseCount > 0 ? Color.agentRed : Color.mediumGray)
                    }
                    Text("RELAPSES")
                        .font(.system(size: 8, design: .monospaced))
                        .foregroundColor(Color.mediumGray)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, Spacing.md)
            .padding(.horizontal, Spacing.xs)
            .background(Color.darkGray)
            .cornerRadius(12)
            .opacity(appeared ? 1 : 0)
            .animation(.easeOut(duration: 0.5), value: appeared)
        }
        .padding(.horizontal, Spacing.md)
        .onAppear {
            appeared = true
            // Pulse animation for status indicator
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulseOpacity = 0.4
            }
        }
    }

    // MARK: - Subviews

    private var divider: some View {
        Rectangle()
            .fill(Color.charcoal)
            .frame(width: 1, height: 36)
    }

    private var statusIndicator: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
                .opacity(pulseOpacity)
            Text(statusText)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(statusColor)
        }
    }

    // MARK: - Computed Properties

    private var todayColor: Color {
        if todayTotal == 0 { return Color.mediumGray }
        if completionRatio >= 1.0 { return Color.matrixGreen }
        if completionRatio >= 0.5 { return .yellow }
        return Color.agentRed
    }

    private var statusColor: Color {
        if todayTotal == 0 { return Color.mediumGray }
        if completionRatio >= 1.0 { return Color.matrixGreen }
        if completionRatio >= 0.5 { return .yellow }
        if completionRatio > 0 { return .orange }
        return Color.agentRed
    }

    private var statusText: String {
        if todayTotal == 0 { return "NO DATA" }
        if completionRatio >= 1.0 { return "COMPLETE" }
        if completionRatio >= 0.75 { return "OPTIMAL" }
        if completionRatio >= 0.5 { return "NOMINAL" }
        if completionRatio > 0 { return "WARNING" }
        return "CRITICAL"
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.matrixBlack.ignoresSafeArea()

        VStack(spacing: 20) {
            SystemStatusCard(
                todayCompleted: 3,
                todayTotal: 4,
                currentStreak: 7,
                daysActive: 23,
                relapseCount: 2
            )

            SystemStatusCard(
                todayCompleted: 4,
                todayTotal: 4,
                currentStreak: 12,
                daysActive: 45,
                relapseCount: 0
            )

            SystemStatusCard(
                todayCompleted: 1,
                todayTotal: 4,
                currentStreak: 0,
                daysActive: 5,
                relapseCount: 8
            )
        }
    }
}

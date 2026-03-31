import SwiftUI

// MARK: - Program Status List (Horizontal Bars)

struct ProgramStatusList: View {
    let programs: [ProgramStatus]

    var body: some View {
        VStack(spacing: Spacing.sm) {
            // Header
            HStack {
                Text("// PROGRAM STATUS")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.lightGray)
                Spacer()
                Text("\(programs.filter { $0.isPower }.count)H / \(programs.filter { !$0.isPower }.count)A")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.mediumGray)
            }

            // Program bars
            VStack(spacing: 8) {
                ForEach(programs) { program in
                    ProgramStatusRow(program: program)
                }
            }
            .padding(Spacing.sm)
            .background(Color.darkGray)
            .cornerRadius(12)
        }
        .padding(.horizontal, Spacing.md)
    }
}

// MARK: - Program Status Row

struct ProgramStatusRow: View {
    let program: ProgramStatus

    @State private var animatedProgress: CGFloat = 0
    @State private var glitchOffset: CGFloat = 0
    @State private var glitchOpacity: Double = 1.0
    @State private var glitchTimer: Timer?

    private var accentColor: Color {
        program.isPower ? Color.matrixGreen : Color.agentRed
    }

    private var isStruggling: Bool {
        program.currentStreak == 0 && program.completionRate < 50
    }

    var body: some View {
        HStack(spacing: Spacing.sm) {
            // Status indicator
            Circle()
                .fill(statusColor)
                .frame(width: 6, height: 6)
                .opacity(isStruggling ? glitchOpacity : 1.0)

            // Icon
            Image(systemName: program.icon)
                .font(.system(size: 12))
                .foregroundColor(accentColor)
                .frame(width: 16)

            // Name
            Text(program.name.uppercased())
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(.white)
                .lineLimit(1)
                .frame(width: 65, alignment: .leading)

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Track
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.charcoal)
                        .frame(height: 8)

                    // Fill
                    RoundedRectangle(cornerRadius: 3)
                        .fill(accentColor)
                        .frame(width: geometry.size.width * animatedProgress, height: 8)
                }
            }
            .frame(height: 8)

            // Percentage
            Text("\(program.completionRate)%")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(accentColor)
                .frame(width: 36, alignment: .trailing)

            // Streak
            HStack(spacing: 2) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 9))
                    .foregroundColor(program.currentStreak > 0 ? .warning : Color.mediumGray)
                Text("\(program.currentStreak)")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(program.currentStreak > 0 ? .white : Color.mediumGray)
            }
            .frame(width: 32, alignment: .trailing)
        }
        .offset(x: glitchOffset)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(Double(program.sortOrder) * 0.1)) {
                animatedProgress = CGFloat(program.completionRate) / 100.0
            }

            // Glitch animation for struggling habits
            if isStruggling {
                startGlitchAnimation()
            }
        }
        .onDisappear {
            // Clean up timer to prevent memory leak
            glitchTimer?.invalidate()
            glitchTimer = nil
        }
    }

    private var statusColor: Color {
        if program.currentStreak >= 7 { return Color.matrixGreen }
        if program.currentStreak >= 3 { return .yellow }
        if program.currentStreak > 0 { return .warning }
        return Color.agentRed
    }

    private func startGlitchAnimation() {
        // Random glitch every 2-4 seconds
        glitchTimer = Timer.scheduledTimer(withTimeInterval: Double.random(in: 2...4), repeats: true) { _ in
            // Quick glitch sequence
            withAnimation(.linear(duration: 0.05)) {
                glitchOffset = CGFloat.random(in: -3...3)
                glitchOpacity = 0.3
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation(.linear(duration: 0.05)) {
                    glitchOffset = CGFloat.random(in: -2...2)
                    glitchOpacity = 0.8
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.linear(duration: 0.05)) {
                    glitchOffset = 0
                    glitchOpacity = 1.0
                }
            }
        }
    }
}

// MARK: - Program Status Data

struct ProgramStatus: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let completionRate: Int // 0-100
    let currentStreak: Int
    let isPower: Bool
    var sortOrder: Int = 0
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.matrixBlack.ignoresSafeArea()

        ProgramStatusList(programs: [
            ProgramStatus(name: "Water", icon: "drop.fill", completionRate: 78, currentStreak: 12, isPower: true, sortOrder: 0),
            ProgramStatus(name: "Exercise", icon: "figure.run", completionRate: 65, currentStreak: 5, isPower: true, sortOrder: 1),
            ProgramStatus(name: "Read", icon: "book.fill", completionRate: 92, currentStreak: 21, isPower: true, sortOrder: 2),
            ProgramStatus(name: "No Soda", icon: "xmark.circle", completionRate: 58, currentStreak: 3, isPower: false, sortOrder: 3),
            ProgramStatus(name: "No Sugar", icon: "cube.fill", completionRate: 32, currentStreak: 0, isPower: false, sortOrder: 4),
        ])
    }
}

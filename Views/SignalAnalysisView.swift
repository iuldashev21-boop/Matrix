import SwiftUI
import SwiftData

struct SignalAnalysisView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var powers: [Power]
    @Query private var agents: [Agent]
    @Query private var checkIns: [CheckIn]

    @State private var progressAnimated: Double = 0
    @State private var gridAppeared: Bool = false
    #if DEBUG
    @State private var hasSeededData: Bool = false
    #endif

    // MARK: - Computed Stats

    private var totalCheckIns: Int {
        checkIns.filter { $0.isSuccess }.count
    }

    private var systemIntegrity: Int {
        let total = checkIns.count
        guard total > 0 else { return 0 }
        let successful = checkIns.filter { $0.isSuccess }.count
        return Int((Double(successful) / Double(total)) * 100)
    }

    private var maxSignalStrength: Int {
        let powerMax = powers.map { $0.longestStreak }.max() ?? 0
        let agentMax = agents.map { $0.longestStreak }.max() ?? 0
        return max(powerMax, agentMax)
    }

    private var currentLevel: Int {
        UserProfile.currentLevel
    }

    private var currentRank: Rank {
        UserProfile.currentRank
    }

    private var xpProgress: Double {
        RankSystem.progressToNextLevel(UserProfile.totalXP)
    }

    private var xpToNext: Int {
        RankSystem.xpForNextLevel(UserProfile.totalXP)
    }

    var body: some View {
        ZStack {
            Color.matrixBlack
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Header
                    headerView

                    // Operator Level Card
                    operatorLevelCard

                    // The Grid (Compact)
                    gridSection

                    // System Status (compact stats)
                    systemStatusSection

                    // Program Status (horizontal bars)
                    programStatusSection

                    Spacer(minLength: 100)
                }
                .padding(.top, Spacing.md)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                progressAnimated = xpProgress
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                gridAppeared = true
            }
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            Text("SIGNAL ANALYSIS")
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            Spacer()

            #if DEBUG
            // DEBUG: Seed data button
            Button(action: seedTestData) {
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 16))
                    .foregroundColor(Color.matrixGreen)
            }
            #endif
        }
        .padding(.horizontal, Spacing.md)
    }

    // MARK: - DEBUG: Seed Test Data

    #if DEBUG
    private func seedTestData() {
        guard !hasSeededData else { return }
        hasSeededData = true

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Create a test Power if none exists
        var testPower: Power
        if let existing = powers.first {
            testPower = existing
        } else {
            testPower = Power(name: "Debug Hack", icon: "bolt")
            modelContext.insert(testPower)
        }

        // Seed 31 days of check-ins with ~80% success rate
        for dayOffset in 1...31 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }

            // 80% chance of success
            let isSuccess = Double.random(in: 0...1) < 0.80

            let checkIn = CheckIn(date: date, isSuccess: isSuccess)
            checkIn.power = testPower
            testPower.checkIns.append(checkIn)
            modelContext.insert(checkIn)
        }

        // Add some XP
        UserProfile.addXP(310) // ~31 days * 10 XP

        try? modelContext.save()

        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    #endif

    // MARK: - Operator Level Card

    private var operatorLevelCard: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Section header
            Text("// OPERATOR IDENTITY")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(Color.lightGray)

            VStack(alignment: .leading, spacing: Spacing.md) {
                // Level label
                Text("OPERATOR LEVEL \(currentLevel)")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(Color.lightGray)

                // Rank name
                Text(currentRank.rawValue)
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.matrixGreen)

                // Progress bar
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Track
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.charcoal)
                                .frame(height: 12)

                            // Fill
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.matrixGreen)
                                .frame(width: geometry.size.width * progressAnimated, height: 12)
                        }
                    }
                    .frame(height: 12)

                    // Status text
                    HStack {
                        Text("DECRYPTING NEXT LEVEL...")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(Color.matrixGreen)
                        Spacer()
                        Text("\(UserProfile.totalXP) XP")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.matrixGreen)
                    }
                }
            }
            .padding(Spacing.md)
            .background(Color.darkGray)
            .cornerRadius(16)
        }
        .padding(.horizontal, Spacing.md)
    }

    // MARK: - Grid Section (Compact 28-day view)

    private var gridSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Section header with info
            HStack {
                Text("// 66-DAY PROTOCOL")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.lightGray)
                Spacer()
                Text("LAST 4 WEEKS")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(Color.mediumGray)
            }
            .padding(.horizontal, Spacing.md)

            // Day labels
            HStack(spacing: 2) {
                ForEach(["M", "T", "W", "T", "F", "S", "S"], id: \.self) { day in
                    Text(day)
                        .font(.system(size: 8, design: .monospaced))
                        .foregroundColor(Color.mediumGray)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, Spacing.md)

            // Compact Grid (28 days = 4 weeks)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7), spacing: 2) {
                ForEach(0..<28, id: \.self) { index in
                    GridCell(
                        state: getCellState(for: index),
                        isCurrentDay: isCurrentDay(index: index),
                        appeared: gridAppeared,
                        delay: Double(index) * 0.01
                    )
                    .frame(height: 16)
                }
            }
            .padding(.horizontal, Spacing.md)
        }
    }

    // MARK: - System Status Section

    private var systemStatusSection: some View {
        SystemStatusCard(
            todayCompleted: todayCompletedCount,
            todayTotal: totalHabitsCount,
            currentStreak: bestCurrentStreak,
            daysActive: daysActiveCount,
            relapseCount: totalRelapses
        )
    }

    private var totalRelapses: Int {
        // Relapses = failed check-ins for Agents (gave in to bad habit)
        checkIns.filter { checkIn in
            !checkIn.isSuccess && checkIn.agent != nil
        }.count
    }

    private var todayCompletedCount: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return checkIns.filter {
            calendar.startOfDay(for: $0.date) == today && $0.isSuccess
        }.count
    }

    private var totalHabitsCount: Int {
        powers.count + agents.count
    }

    private var bestCurrentStreak: Int {
        let powerStreaks = powers.map { $0.currentStreak }
        let agentStreaks = agents.map { $0.currentStreak }
        return (powerStreaks + agentStreaks).max() ?? 0
    }

    private var daysActiveCount: Int {
        guard let firstCheckIn = checkIns.map({ $0.date }).min() else { return 0 }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let firstDay = calendar.startOfDay(for: firstCheckIn)
        let components = calendar.dateComponents([.day], from: firstDay, to: today)
        return (components.day ?? 0) + 1
    }

    // MARK: - Program Status Section

    private var programStatusSection: some View {
        ProgramStatusList(programs: programStatusData)
    }

    private var programStatusData: [ProgramStatus] {
        var programs: [ProgramStatus] = []
        var sortOrder = 0

        // Add powers
        for power in powers {
            programs.append(ProgramStatus(
                name: power.name,
                icon: power.icon,
                completionRate: calculateCompletionRate(checkIns: power.checkIns),
                currentStreak: power.currentStreak,
                isPower: true,
                sortOrder: sortOrder
            ))
            sortOrder += 1
        }

        // Add agents
        for agent in agents {
            programs.append(ProgramStatus(
                name: agent.name,
                icon: agent.icon,
                completionRate: calculateCompletionRate(checkIns: agent.checkIns),
                currentStreak: agent.currentStreak,
                isPower: false,
                sortOrder: sortOrder
            ))
            sortOrder += 1
        }

        return programs
    }

    // MARK: - Analytics Helpers

    private func calculateCompletionRate(checkIns: [CheckIn]) -> Int {
        guard !checkIns.isEmpty else { return 0 }
        let successful = checkIns.filter { $0.isSuccess }.count
        return Int((Double(successful) / Double(checkIns.count)) * 100)
    }

    // MARK: - Grid Helpers

    private func getCellState(for index: Int) -> GridCellState {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Calculate the date for this cell (going back from today)
        // Index 0 = today, Index 69 = 69 days ago (top to bottom)
        guard let cellDate = calendar.date(byAdding: .day, value: -index, to: today) else {
            return .empty
        }

        // Future dates
        if cellDate > today {
            return .empty
        }

        // Check if any check-in exists for this date
        let hasSuccess = checkIns.contains { checkIn in
            calendar.startOfDay(for: checkIn.date) == cellDate && checkIn.isSuccess
        }

        let hasFail = checkIns.contains { checkIn in
            calendar.startOfDay(for: checkIn.date) == cellDate && !checkIn.isSuccess
        }

        if hasSuccess {
            return .success
        } else if hasFail {
            return .fail
        } else if cellDate < today {
            // Past date with no check-in - could be before app install
            let firstCheckIn = checkIns.map { $0.date }.min()
            if let first = firstCheckIn, cellDate >= calendar.startOfDay(for: first) {
                return .missed
            }
            return .empty
        }

        return .empty
    }

    private func isCurrentDay(index: Int) -> Bool {
        return index == 0 // First cell is today (top-left)
    }
}

// MARK: - Grid Cell

enum GridCellState {
    case success
    case fail
    case missed
    case empty
}

struct GridCell: View {
    let state: GridCellState
    let isCurrentDay: Bool
    let appeared: Bool
    let delay: Double

    @State private var blinkOpacity: Double = 1.0

    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(fillColor)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(strokeColor, lineWidth: isCurrentDay ? 2 : (state == .empty ? 1 : 0))
            )
            .aspectRatio(1, contentMode: .fit)
            .opacity(appeared ? (isCurrentDay ? blinkOpacity : 1.0) : 0)
            .animation(.easeOut(duration: 0.3).delay(delay), value: appeared)
            .onAppear {
                if isCurrentDay {
                    withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                        blinkOpacity = 0.5
                    }
                }
            }
    }

    private var fillColor: Color {
        switch state {
        case .success: return Color.matrixGreen
        case .fail: return Color.agentRed.opacity(0.5)
        case .missed: return Color.charcoal
        case .empty: return Color.clear
        }
    }

    private var strokeColor: Color {
        if isCurrentDay {
            return Color.matrixGreen
        }
        switch state {
        case .empty: return Color.mediumGray
        default: return Color.clear
        }
    }
}

// MARK: - Metric Item

struct MetricItem: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: Spacing.xs) {
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundColor(.white)

            Text(label)
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(Color.lightGray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.md)
        .background(Color.darkGray)
        .cornerRadius(12)
    }
}

// MARK: - Habit Analytics Card (Compact Visual)

struct HabitAnalyticsCard: View {
    let name: String
    let icon: String
    let currentStreak: Int
    let longestStreak: Int
    let completionRate: Int
    let last7Days: [GridCellState]
    let isPower: Bool

    private var accentColor: Color {
        isPower ? Color.matrixGreen : Color.agentRed
    }

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Left: Mini progress ring with streak
            ZStack {
                // Background ring
                Circle()
                    .stroke(Color.charcoal, lineWidth: 4)
                    .frame(width: 44, height: 44)

                // Progress ring
                Circle()
                    .trim(from: 0, to: CGFloat(min(completionRate, 100)) / 100)
                    .stroke(accentColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 44, height: 44)
                    .rotationEffect(.degrees(-90))

                // Streak number
                Text("\(currentStreak)")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(accentColor)
            }

            // Middle: Name + 7-day bar chart
            VStack(alignment: .leading, spacing: 6) {
                // Name row
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 10))
                        .foregroundColor(accentColor)
                    Text(name.uppercased())
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }

                // 7-day mini bar chart
                HStack(spacing: 3) {
                    ForEach(0..<7, id: \.self) { index in
                        let state = last7Days.indices.contains(index) ? last7Days[index] : .empty
                        RoundedRectangle(cornerRadius: 2)
                            .fill(barColor(for: state))
                            .frame(width: 8, height: barHeight(for: state))
                    }
                }
                .frame(height: 16, alignment: .bottom)
            }

            Spacer()

            // Right: Best streak + rate
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 8))
                        .foregroundColor(Color.mediumGray)
                    Text("\(longestStreak)")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }

                Text("\(completionRate)%")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(Color.mediumGray)
            }
        }
        .padding(Spacing.sm)
        .background(Color.darkGray)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(accentColor.opacity(0.3), lineWidth: 1)
        )
    }

    private func barColor(for state: GridCellState) -> Color {
        switch state {
        case .success: return accentColor
        case .fail: return Color.agentRed.opacity(0.5)
        case .missed: return Color.charcoal
        case .empty: return Color.charcoal.opacity(0.5)
        }
    }

    private func barHeight(for state: GridCellState) -> CGFloat {
        switch state {
        case .success: return 16
        case .fail: return 10
        case .missed: return 4
        case .empty: return 4
        }
    }
}

#Preview {
    SignalAnalysisView()
        .modelContainer(for: [Power.self, Agent.self, CheckIn.self], inMemory: true)
}


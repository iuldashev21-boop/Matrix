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

    // MARK: - P2: Weekly Summary Stats

    private var weeklyStats: (completed: Int, total: Int, rate: Int, vsLastWeek: Int?) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // This week: last 7 days including today
        guard let weekStart = calendar.date(byAdding: .day, value: -6, to: today) else {
            return (0, 0, 0, nil)
        }

        // Last week: 7-14 days ago
        guard let lastWeekStart = calendar.date(byAdding: .day, value: -13, to: today),
              let lastWeekEnd = calendar.date(byAdding: .day, value: -7, to: today) else {
            return (0, 0, 0, nil)
        }

        // Helper to count scheduled days in a date range for a habit
        func countScheduledDays(scheduledDays: [Int], from start: Date, to end: Date) -> Int {
            var count = 0
            var date = start
            while date <= end {
                let weekday = calendar.component(.weekday, from: date)
                if scheduledDays.isEmpty || scheduledDays.count == 7 || scheduledDays.contains(weekday) {
                    count += 1
                }
                guard let next = calendar.date(byAdding: .day, value: 1, to: date) else { break }
                date = next
            }
            return count
        }

        // Calculate total possible for this week and last week
        var thisWeekTotal = 0
        var lastWeekTotal = 0

        for power in powers {
            thisWeekTotal += countScheduledDays(scheduledDays: power.scheduledDays, from: weekStart, to: today)
            lastWeekTotal += countScheduledDays(scheduledDays: power.scheduledDays, from: lastWeekStart, to: lastWeekEnd)
        }

        for agent in agents {
            thisWeekTotal += countScheduledDays(scheduledDays: agent.scheduledDays, from: weekStart, to: today)
            lastWeekTotal += countScheduledDays(scheduledDays: agent.scheduledDays, from: lastWeekStart, to: lastWeekEnd)
        }

        // Count from habits' perspective (more reliable than checking orphaned check-ins)
        var thisWeekCount = 0
        var lastWeekCount = 0

        // Count Power check-ins
        for power in powers {
            for checkIn in power.checkIns where checkIn.isSuccess {
                let checkInDate = calendar.startOfDay(for: checkIn.date)
                if checkInDate >= weekStart && checkInDate <= today {
                    thisWeekCount += 1
                } else if checkInDate >= lastWeekStart && checkInDate <= lastWeekEnd {
                    lastWeekCount += 1
                }
            }
        }

        // Count Agent check-ins
        for agent in agents {
            for checkIn in agent.checkIns where checkIn.isSuccess {
                let checkInDate = calendar.startOfDay(for: checkIn.date)
                if checkInDate >= weekStart && checkInDate <= today {
                    thisWeekCount += 1
                } else if checkInDate >= lastWeekStart && checkInDate <= lastWeekEnd {
                    lastWeekCount += 1
                }
            }
        }

        // Cap at total possible (in case of duplicate check-ins on same day)
        thisWeekCount = min(thisWeekCount, thisWeekTotal)
        lastWeekCount = min(lastWeekCount, lastWeekTotal)

        let thisWeekRate = thisWeekTotal > 0 ? Int((Double(thisWeekCount) / Double(thisWeekTotal)) * 100) : 0
        let lastWeekRate = lastWeekTotal > 0 ? Int((Double(lastWeekCount) / Double(lastWeekTotal)) * 100) : 0

        // Only show comparison if we have last week data
        let comparison: Int? = lastWeekCount > 0 ? thisWeekRate - lastWeekRate : nil

        return (thisWeekCount, thisWeekTotal, thisWeekRate, comparison)
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

                    // P2: Weekly Summary
                    weeklySummarySection

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

        // Create test habits if none exist
        var testPower: Power
        var testAgent: Agent

        if let existing = powers.first {
            testPower = existing
        } else {
            testPower = Power(name: "Morning Walk", icon: "figure.walk")
            modelContext.insert(testPower)
        }

        if let existing = agents.first {
            testAgent = existing
        } else {
            testAgent = Agent(name: "No Doom Scrolling", icon: "iphone.slash")
            modelContext.insert(testAgent)
        }

        // Seed 66 days of check-ins for full protocol simulation
        // Power: 90% success rate (realistic for dedicated user)
        // Agent: 85% success rate with some relapses
        for dayOffset in 1...66 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }

            // Power check-in (90% success)
            let powerSuccess = Double.random(in: 0...1) < 0.90
            let powerCheckIn = CheckIn(date: date, isSuccess: powerSuccess)
            powerCheckIn.power = testPower
            testPower.checkIns.append(powerCheckIn)
            modelContext.insert(powerCheckIn)

            // Agent check-in (85% success, 15% relapse)
            let agentSuccess = Double.random(in: 0...1) < 0.85
            let agentCheckIn = CheckIn(date: date, isSuccess: agentSuccess)
            agentCheckIn.agent = testAgent
            testAgent.checkIns.append(agentCheckIn)
            modelContext.insert(agentCheckIn)
        }

        // Add XP for 66 days (~60 successful days * 10 XP + achievements)
        UserProfile.addXP(750)

        do {
            try modelContext.save()
            // Haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        } catch {
            ErrorLogger.logSaveFailure(error, context: "SignalAnalysisView.seedTestData")
        }
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

    // MARK: - P2: Weekly Summary Section

    private var weeklySummarySection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("// WEEKLY REPORT")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(Color.lightGray)

            HStack(spacing: Spacing.md) {
                // Completion count
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(weeklyStats.completed)/\(weeklyStats.total)")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.matrixGreen)

                    Text("CHECK-INS")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(Color.mediumGray)
                }

                Spacer()

                // Completion rate with progress ring
                ZStack {
                    Circle()
                        .stroke(Color.charcoal, lineWidth: 6)
                        .frame(width: 60, height: 60)

                    Circle()
                        .trim(from: 0, to: CGFloat(weeklyStats.rate) / 100)
                        .stroke(Color.matrixGreen, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))

                    Text("\(weeklyStats.rate)%")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }

                // Comparison to last week
                if let comparison = weeklyStats.vsLastWeek {
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 2) {
                            Image(systemName: comparison >= 0 ? "arrow.up" : "arrow.down")
                                .font(.system(size: 12, weight: .bold))
                            Text("\(abs(comparison))%")
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                        }
                        .foregroundColor(comparison >= 0 ? Color.matrixGreen : Color.agentRed)

                        Text("VS LAST WEEK")
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(Color.mediumGray)
                    }
                }
            }
            .padding(Spacing.md)
            .background(Color.darkGray)
            .cornerRadius(Theme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .stroke(Color.matrixGreen.opacity(0.3), lineWidth: 1)
            )
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
        let allDates = checkIns.map { Calendar.current.startOfDay(for: $0.date) }
        return Set(allDates).count
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


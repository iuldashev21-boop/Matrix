import SwiftUI
import SwiftData

struct CommandCenterView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var powers: [Power]
    @Query private var agents: [Agent]
    @Query private var checkIns: [CheckIn]

    @State private var selectedTab: Int = 0
    @State private var showAddHabit: Bool = false
    @State private var showSettings: Bool = false
    @State private var selectedPower: Power? = nil
    @State private var selectedAgent: Agent? = nil
    @State private var showWhiteRabbit: Bool = false
    @State private var showHabitTip: Bool = false
    @State private var showGhostTutorial: Bool = false  // P1: First-time user tutorial
    @State private var showDailyAffirmation: Bool = false  // P2: Daily motivation
    @StateObject private var rabbitManager = WhiteRabbitManager()
    @AppStorage("hasSeenHabitTip") private var hasSeenHabitTip: Bool = false
    @AppStorage("hasSeenGhostTutorial") private var hasSeenGhostTutorial: Bool = false  // P1
    @AppStorage("lastAffirmationDate") private var lastAffirmationDate: Double = 0  // P2

    // Collapsible section states
    @State private var isPowersExpanded: Bool = true
    @State private var isAgentsExpanded: Bool = true
    @State private var isSidequestsExpanded: Bool = false

    private var totalSignalStrength: Int {
        let powerStreak = powers.reduce(0) { $0 + $1.currentStreak }
        let agentStreak = agents.reduce(0) { $0 + $1.currentStreak }
        return powerStreak + agentStreak
    }

    private var codeRainOpacity: Double {
        // Base 0.1, max 0.4 at high streaks
        min(0.4, 0.1 + Double(totalSignalStrength) * 0.02)
    }

    private var codeRainSpeed: Double {
        // Base 0.5, faster at high streaks
        min(3.0, 0.5 + Double(totalSignalStrength) * 0.1)
    }

    // Completion tracking
    private var allPowersCompleted: Bool {
        !powers.isEmpty && powers.allSatisfy { $0.completedToday }
    }

    private var allAgentsCompleted: Bool {
        !agents.isEmpty && agents.allSatisfy { $0.resistedToday || $0.relapsedToday }
    }

    private var allHabitsCompleted: Bool {
        let hasHabits = !powers.isEmpty || !agents.isEmpty
        let powersOk = powers.isEmpty || allPowersCompleted
        let agentsOk = agents.isEmpty || allAgentsCompleted
        return hasHabits && powersOk && agentsOk
    }

    private var powersCompletedCount: Int {
        powers.filter { $0.completedToday }.count
    }

    private var agentsCompletedCount: Int {
        agents.filter { $0.resistedToday || $0.relapsedToday }.count
    }

    // MARK: - System Status Card Data

    private var todayCompletedCount: Int {
        powersCompletedCount + agents.filter { $0.resistedToday }.count
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
        let allDates = checkIns.map { $0.date }
        return Set(allDates).count
    }

    private var totalRelapses: Int {
        checkIns.filter { checkIn in
            !checkIn.isSuccess && checkIn.agent != nil
        }.count
    }

    var body: some View {
        ZStack {
            // Background
            Color.matrixBlack
                .ignoresSafeArea()

            // Dynamic code rain
            CodeRainBackground(opacity: codeRainOpacity, speed: codeRainSpeed)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Content based on selected tab
                if selectedTab == 0 {
                    dashboardContent
                } else if selectedTab == 1 {
                    SignalAnalysisView()
                } else if selectedTab == 2 {
                    AchievementsTabView()
                }

                // Tab Bar
                tabBarView
            }

            // White Rabbit Overlay (5% chance)
            if showWhiteRabbit {
                WhiteRabbitOverlay(isVisible: $showWhiteRabbit) { reward in
                    handleRabbitReward(reward)
                }
            }
        }
        .onAppear {
            rabbitManager.checkForRabbit()

            // P1: Show Ghost Tutorial on first launch with habits
            if !hasSeenGhostTutorial && (!powers.isEmpty || !agents.isEmpty) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation {
                        showGhostTutorial = true
                    }
                }
            }
            // P2: Show Daily Affirmation once per day (after tutorial)
            else if hasSeenGhostTutorial && shouldShowDailyAffirmation {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        showDailyAffirmation = true
                    }
                }
            }
        }
        .onChange(of: rabbitManager.shouldShowRabbit) { _, newValue in
            if newValue {
                showWhiteRabbit = true
                rabbitManager.rabbitDismissed()
            }
        }
        .sheet(isPresented: $showAddHabit) {
            AddHabitSheet()
        }
        .sheet(isPresented: $showSettings) {
            ZionMainframeView()
        }
        .sheet(item: $selectedPower) { power in
            DialInView(power: power, agent: nil)
        }
        .sheet(item: $selectedAgent) { agent in
            DialInView(power: nil, agent: agent)
        }
        .overlay {
            // First-time tip overlay
            if showHabitTip {
                habitTipOverlay
            }
            // P1: Ghost Tutorial for first-time users
            if showGhostTutorial {
                ghostTutorialOverlay
            }
            // P2: Daily Affirmation
            if showDailyAffirmation {
                dailyAffirmationOverlay
            }
        }
        .onChange(of: powers.count + agents.count) { oldValue, newValue in
            // Show tip when first habit is created
            if oldValue == 0 && newValue > 0 && !hasSeenHabitTip {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        showHabitTip = true
                    }
                }
            }
        }
    }

    // MARK: - Habit Tip Overlay

    private var habitTipOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissTip()
                }

            VStack(spacing: Spacing.md) {
                Image(systemName: "hand.tap")
                    .font(.system(size: 40))
                    .foregroundColor(Color.matrixGreen)

                Text("// SYSTEM TIP")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.matrixGreen)

                Text("TAP ANY PROGRAM TO ACCESS\nMODIFICATION PROTOCOLS")
                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("Edit, view stats, or delete programs")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(Color.mediumGray)

                Button(action: dismissTip) {
                    Text("GOT IT")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.deepBlack)
                        .padding(.horizontal, Spacing.xl)
                        .padding(.vertical, Spacing.sm)
                        .background(Color.matrixGreen)
                        .cornerRadius(8)
                }
                .padding(.top, Spacing.sm)
            }
            .padding(Spacing.xl)
            .background(Color.charcoal)
            .cornerRadius(Theme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .stroke(Color.matrixGreen, lineWidth: 1)
            )
            .padding(.horizontal, Spacing.xl)
        }
    }

    private func dismissTip() {
        withAnimation {
            showHabitTip = false
            hasSeenHabitTip = true
        }
    }

    // MARK: - Ghost Tutorial Overlay (P1)

    private var ghostTutorialOverlay: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()

            VStack(spacing: Spacing.xl) {
                // Header
                Text("// OPERATOR BRIEFING")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.matrixGreen)

                Text("HOW TO SYNC")
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)

                VStack(spacing: Spacing.lg) {
                    // Hack instruction
                    HStack(spacing: Spacing.md) {
                        ZStack {
                            Circle()
                                .fill(Color.matrixGreen.opacity(0.2))
                                .frame(width: 50, height: 50)
                            Image(systemName: "hand.tap.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color.matrixGreen)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("HACKS (Green)")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(Color.matrixGreen)
                            Text("Tap → Hold to upload")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(Color.lightGray)
                        }

                        Spacer()
                    }

                    // Agent instruction
                    HStack(spacing: Spacing.md) {
                        ZStack {
                            Circle()
                                .fill(Color.agentRed.opacity(0.2))
                                .frame(width: 50, height: 50)
                            Image(systemName: "hand.tap.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color.agentRed)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("AGENTS (Red)")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(Color.agentRed)
                            Text("Tap → Hold to resist")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(Color.lightGray)
                            Text("Or report breach if you relapsed")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(Color.mediumGray)
                        }

                        Spacer()
                    }

                    // Daily goal
                    HStack(spacing: Spacing.md) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 50, height: 50)
                            Image(systemName: "calendar")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("DAILY PROTOCOL")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                            Text("Check in every day to build streaks")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(Color.lightGray)
                        }

                        Spacer()
                    }
                }
                .padding(Spacing.lg)
                .background(Color.charcoal)
                .cornerRadius(Theme.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .stroke(Color.matrixGreen.opacity(0.5), lineWidth: 1)
                )

                Button(action: dismissGhostTutorial) {
                    Text("BEGIN PROTOCOL")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.deepBlack)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.matrixGreen)
                        .cornerRadius(Theme.cornerRadius)
                }
            }
            .padding(.horizontal, Spacing.xl)
        }
    }

    private func dismissGhostTutorial() {
        withAnimation {
            showGhostTutorial = false
            hasSeenGhostTutorial = true
        }
    }

    // MARK: - P2: Daily Affirmation

    private var shouldShowDailyAffirmation: Bool {
        let calendar = Calendar.current
        let lastShown = Date(timeIntervalSince1970: lastAffirmationDate)
        let today = calendar.startOfDay(for: Date())
        let lastShownDay = calendar.startOfDay(for: lastShown)
        return lastShownDay < today && (!powers.isEmpty || !agents.isEmpty)
    }

    private var bestStreak: (name: String, days: Int)? {
        var best: (String, Int)? = nil
        for power in powers {
            if power.currentStreak > (best?.1 ?? 0) {
                best = (power.name, power.currentStreak)
            }
        }
        for agent in agents {
            if agent.currentStreak > (best?.1 ?? 0) {
                best = (agent.name, agent.currentStreak)
            }
        }
        return best
    }

    private var dailyAffirmation: String {
        if let streak = bestStreak, streak.days > 0 {
            let messages = [
                "Day \(streak.days) of \(streak.name).\nMost people can't do 3 days.\nYou're not most people.",
                "\(streak.days) days strong.\nThe Matrix is losing its grip.\nKeep going, Operator.",
                "Signal strength: \(streak.days) days.\nYou're rewriting your code.\nOne day at a time.",
                "\(streak.days) consecutive uploads.\nThe old you would have quit.\nBut you're still here.",
                "Day \(streak.days). The compound effect is real.\nSmall wins create momentum.\nMomentum creates change."
            ]
            return messages.randomElement() ?? messages[0]
        } else {
            let messages = [
                "Every master was once a disaster.\nToday is Day 1.\nMake it count.",
                "The journey of 66 days\nbegins with a single check-in.\nYou've got this.",
                "Welcome back, Operator.\nThe Matrix is waiting.\nTime to fight back."
            ]
            return messages.randomElement() ?? messages[0]
        }
    }

    private var dailyAffirmationOverlay: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissAffirmation()
                }

            VStack(spacing: Spacing.lg) {
                // Terminal-style header
                Text("> DAILY TRANSMISSION")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.matrixGreen)

                // Affirmation text
                Text(dailyAffirmation)
                    .font(.system(size: 18, weight: .medium, design: .monospaced))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)

                // Dismiss hint
                Text("TAP TO CONTINUE")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(Color.mediumGray)
                    .padding(.top, Spacing.lg)
            }
            .padding(Spacing.xl)
        }
    }

    private func dismissAffirmation() {
        withAnimation {
            showDailyAffirmation = false
            lastAffirmationDate = Date().timeIntervalSince1970
        }
    }

    // MARK: - Dashboard Content

    private var dashboardContent: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            // Content
            ScrollView {
                VStack(spacing: Spacing.md) {
                    // System Status Card - shown when all habits are completed
                    if allHabitsCompleted && (!powers.isEmpty || !agents.isEmpty) {
                        SystemStatusCard(
                            todayCompleted: todayCompletedCount,
                            todayTotal: totalHabitsCount,
                            currentStreak: bestCurrentStreak,
                            daysActive: daysActiveCount,
                            relapseCount: totalRelapses
                        )
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    // Powers Section (collapsible)
                    if !powers.isEmpty {
                        CollapsibleSection(
                            title: "// LOADED HACKS",
                            subtitle: allPowersCompleted ? "ALL SYNCED" : "\(powersCompletedCount)/\(powers.count) UPLOADED",
                            accentColor: Color.matrixGreen,
                            isExpanded: $isPowersExpanded
                        ) {
                            powersContent
                        }
                    }

                    // Agents Section (collapsible)
                    if !agents.isEmpty {
                        CollapsibleSection(
                            title: "// DETECTED AGENTS",
                            subtitle: allAgentsCompleted ? "ALL CONTAINED" : "\(agentsCompletedCount)/\(agents.count) RESISTED",
                            accentColor: Color.agentRed,
                            isExpanded: $isAgentsExpanded
                        ) {
                            agentsContent
                        }
                    }

                    // Sidequests Section (collapsible, available after habits done)
                    sidequestsSection

                    // Empty state
                    if powers.isEmpty && agents.isEmpty {
                        emptyStateView
                    }

                    Spacer(minLength: 100)
                }
                .padding(.top, Spacing.md)
            }
        }
        .onChange(of: allPowersCompleted) { _, completed in
            if completed {
                withAnimation(.easeInOut(duration: 0.3).delay(0.5)) {
                    isPowersExpanded = false
                }
            }
        }
        .onChange(of: allAgentsCompleted) { _, completed in
            if completed {
                withAnimation(.easeInOut(duration: 0.3).delay(0.5)) {
                    isAgentsExpanded = false
                }
            }
        }
    }

    // MARK: - Powers Content

    private var powersContent: some View {
        VStack(spacing: Spacing.sm) {
            ForEach(powers) { power in
                let isCompleted = power.completedToday
                HabitCard(
                    title: power.name,
                    icon: power.icon,
                    currentDay: power.currentStreak,
                    targetDays: power.targetDays,
                    isCompletedToday: isCompleted,
                    isPower: true
                )
                .padding(.horizontal, Spacing.md)
                .onTapGesture {
                    guard !isCompleted else { return }
                    selectedPower = power
                }
            }
        }
    }

    // MARK: - Agents Content

    private var agentsContent: some View {
        VStack(spacing: Spacing.sm) {
            ForEach(agents) { agent in
                let isCompleted = agent.resistedToday || agent.relapsedToday
                HabitCard(
                    title: agent.name,
                    icon: agent.icon,
                    currentDay: agent.currentStreak,
                    targetDays: agent.targetDays,
                    isCompletedToday: isCompleted,
                    isPower: false
                )
                .padding(.horizontal, Spacing.md)
                .onTapGesture {
                    guard !isCompleted else { return }
                    selectedAgent = agent
                }
            }
        }
    }

    // MARK: - Sidequests Section

    private var sidequestsSection: some View {
        VStack(spacing: Spacing.sm) {
            SidequestSectionHeader(
                isAvailable: allHabitsCompleted,
                isExpanded: $isSidequestsExpanded,
                xpEarned: SidequestManager.sidequestXPToday,
                xpCap: SidequestManager.dailyXPCap
            )

            if isSidequestsExpanded && allHabitsCompleted {
                ConstructLoaderView()
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    // MARK: - Header

    private var operativeName: String {
        UserDefaults.standard.string(forKey: UserDefaultsKeys.operatorName) ?? "OPERATIVE"
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            // Operative identifier
            Text("> LOGGED IN: \(operativeName.uppercased())")
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(Color.matrixGreen)
                .shadow(color: Color.matrixGreen.opacity(0.5), radius: 4)

            HStack {
                Text("COMMAND CENTER")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)

                Spacer()

                // Rank badge
                Text("RANK: \(UserProfile.currentRank.rawValue)")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(Color.matrixGreen)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(Color.darkGray)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.matrixGreen.opacity(0.5), lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.top, Spacing.lg)
        .padding(.bottom, Spacing.sm)
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: Spacing.lg) {
            Spacer().frame(height: 100)

            Image(systemName: "cube.transparent")
                .font(.system(size: 60))
                .foregroundColor(Color.mediumGray)

            Text("CONSTRUCT EMPTY")
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(Color.lightGray)

            Text("Load a program to begin.")
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(Color.mediumGray)

            Button(action: { showAddHabit = true }) {
                HStack {
                    Image(systemName: "plus")
                    Text("LOAD PROGRAM")
                }
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(Color.matrixGreen)
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.md)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .stroke(Color.matrixGreen, lineWidth: 2)
                )
            }
            .padding(.top, Spacing.md)
        }
    }

    // MARK: - Tab Bar

    private var tabBarView: some View {
        HStack {
            Spacer()

            // Grid (Dashboard)
            TabBarButton(icon: "square.grid.2x2", isSelected: selectedTab == 0) {
                selectedTab = 0
            }

            Spacer()

            // Stats
            TabBarButton(icon: "chart.bar", isSelected: selectedTab == 1) {
                selectedTab = 1
            }

            Spacer()

            // Add
            Button(action: { showAddHabit = true }) {
                ZStack {
                    Circle()
                        .fill(Color.matrixGreen)
                        .frame(width: 56, height: 56)

                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color.deepBlack)
                }
            }

            Spacer()

            // Achievements
            TabBarButton(icon: "trophy", isSelected: selectedTab == 2) {
                selectedTab = 2
            }

            Spacer()

            // Settings
            TabBarButton(icon: "gearshape", isSelected: false) {
                showSettings = true
            }

            Spacer()
        }
        .padding(.vertical, Spacing.md)
        .background(
            Color.deepBlack
                .opacity(0.95)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    // MARK: - White Rabbit Reward

    private func handleRabbitReward(_ reward: WhiteRabbitOverlay.RewardType) {
        switch reward {
        case .cheatKey:
            WhiteRabbitManager.addCheatKey()
        case .cosmeticHack:
            // TODO: Implement cosmetic unlocks
            break
        }
    }
}

// MARK: - Tab Bar Button

struct TabBarButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(isSelected ? Color.matrixGreen : Color.mediumGray)
        }
    }
}

// MARK: - Habit Protocol

protocol HabitProtocol {
    var name: String { get }
    var icon: String { get }
    var currentStreak: Int { get }
    var targetDays: Int { get }
}

extension Power: HabitProtocol {}
extension Agent: HabitProtocol {}

// MARK: - Add Habit Sheet (Placeholder)

struct AddHabitSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var habitName: String = ""
    @State private var isAgent: Bool = false
    @State private var selectedIcon: String = "bolt"
    @State private var showSaveError: Bool = false

    private let powerIcons = ["bolt", "figure.run", "book", "brain.head.profile", "drop.fill", "pencil.and.scribble"]
    private let agentIcons = ["xmark.shield", "iphone", "moon.zzz", "cup.and.saucer", "tv", "creditcard"]

    var body: some View {
        NavigationView {
            ZStack {
                Color.matrixBlack.ignoresSafeArea()

                VStack(spacing: Spacing.lg) {
                    // Type Toggle
                    HStack(spacing: Spacing.md) {
                        TypeToggleButton(title: "HACK", isSelected: !isAgent) {
                            isAgent = false
                        }
                        TypeToggleButton(title: "AGENT", isSelected: isAgent) {
                            isAgent = true
                        }
                    }
                    .padding(.horizontal, Spacing.md)

                    // Name Input
                    TextField("", text: $habitName, prompt: Text("PROGRAM NAME").foregroundColor(Color.mediumGray))
                        .font(.system(size: 18, design: .monospaced))
                        .foregroundColor(isAgent ? Color.agentRed : Color.matrixGreen)
                        .padding()
                        .background(Color.charcoal)
                        .cornerRadius(Theme.cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                                .stroke(isAgent ? Color.agentRed : Color.matrixGreen, lineWidth: 1)
                        )
                        .padding(.horizontal, Spacing.md)

                    // Icon Selection
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("SELECT ICON")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.lightGray)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: Spacing.md) {
                            ForEach(isAgent ? agentIcons : powerIcons, id: \.self) { icon in
                                Button(action: { selectedIcon = icon }) {
                                    Image(systemName: icon)
                                        .font(.system(size: 24))
                                        .foregroundColor(selectedIcon == icon ? (isAgent ? Color.agentRed : Color.matrixGreen) : Color.mediumGray)
                                        .frame(width: 44, height: 44)
                                        .background(selectedIcon == icon ? Color.charcoal : Color.clear)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.md)

                    Spacer()

                    // Upload Button
                    if !habitName.trimmingCharacters(in: .whitespaces).isEmpty {
                        PrimaryButton(title: "UPLOAD TO CORE") {
                            if createHabit() {
                                dismiss()
                            } else {
                                showSaveError = true
                            }
                        }
                        .padding(.horizontal, Spacing.xl)
                        .padding(.bottom, Spacing.xl)
                    }
                }
                .padding(.top, Spacing.lg)
            }
            .navigationTitle(isAgent ? "NEW AGENT" : "NEW HACK")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("CANCEL") { dismiss() }
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(Color.matrixGreen)
                }
            }
            .alert("SAVE FAILED", isPresented: $showSaveError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Failed to create habit. Please try again.")
            }
        }
    }

    private func createHabit() -> Bool {
        let name = habitName.trimmingCharacters(in: .whitespaces)
        if isAgent {
            let agent = Agent(name: name, icon: selectedIcon)
            modelContext.insert(agent)
        } else {
            let power = Power(name: name, icon: selectedIcon)
            modelContext.insert(power)
        }
        do {
            try modelContext.save()
            return true
        } catch {
            return false
        }
    }
}

struct TypeToggleButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(isSelected ? Color.deepBlack : Color.mediumGray)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(isSelected ? (title == "AGENT" ? Color.agentRed : Color.matrixGreen) : Color.clear)
                .cornerRadius(Theme.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .stroke(title == "AGENT" ? Color.agentRed : Color.matrixGreen, lineWidth: 1)
                )
        }
    }
}

// MARK: - Achievements Tab View

struct AchievementsTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var unlockedAchievements: [Achievement]

    @State private var selectedAchievement: AchievementDefinition? = nil

    private var unlockedIds: Set<String> {
        Set(unlockedAchievements.map { $0.id })
    }

    private var unlockedCount: Int {
        unlockedAchievements.count
    }

    private var totalCount: Int {
        AchievementLibrary.all.count
    }

    private let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 5)

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("> DECRYPTIONS")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(Color.matrixGreen)
                    .shadow(color: Color.matrixGreen.opacity(0.5), radius: 4)

                HStack {
                    Text("ACHIEVEMENTS")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)

                    Spacer()

                    // Progress badge
                    Text("\(unlockedCount)/\(totalCount)")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(Color.matrixGold)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.xs)
                        .background(Color.darkGray)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.matrixGold.opacity(0.5), lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.lg)
            .padding(.bottom, Spacing.sm)

            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Progress Ring
                    progressHeader

                    // Categories - Icon Grid
                    achievementGridSection(
                        title: "STREAK DECRYPTIONS",
                        achievements: AchievementLibrary.streakAchievements
                    )

                    achievementGridSection(
                        title: "CONSISTENCY PROTOCOLS",
                        achievements: AchievementLibrary.consistencyAchievements
                    )

                    achievementGridSection(
                        title: "SPECIAL OPS",
                        achievements: AchievementLibrary.specialAchievements
                    )

                    Spacer(minLength: 100)
                }
                .padding(.top, Spacing.md)
            }
        }
        .sheet(item: $selectedAchievement) { achievement in
            AchievementDetailSheet(
                achievement: achievement,
                isUnlocked: unlockedIds.contains(achievement.id),
                unlockedAt: unlockedAchievements.first { $0.id == achievement.id }?.unlockedAt
            )
            .presentationDetents([.height(280)])
            .presentationDragIndicator(.visible)
        }
    }

    private var progressHeader: some View {
        VStack(spacing: Spacing.sm) {
            ZStack {
                Circle()
                    .stroke(Color.charcoal, lineWidth: 8)
                    .frame(width: 100, height: 100)

                Circle()
                    .trim(from: 0, to: totalCount > 0 ? CGFloat(unlockedCount) / CGFloat(totalCount) : 0)
                    .stroke(Color.matrixGreen, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Text("\(unlockedCount)")
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.matrixGreen)
                    Text("/ \(totalCount)")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(Color.mediumGray)
                }
            }

            Text("DECRYPTION PROGRESS")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(Color.lightGray)

            Text("+\(totalXPEarned) XP EARNED")
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(Color.matrixGreen)
        }
        .padding(.vertical, Spacing.md)
    }

    private var totalXPEarned: Int {
        unlockedAchievements.compactMap { achievement in
            AchievementLibrary.definition(for: achievement.id)?.rarity.xpReward
        }.reduce(0, +)
    }

    private func achievementGridSection(title: String, achievements: [AchievementDefinition]) -> some View {
        let unlockedInSection = achievements.filter { unlockedIds.contains($0.id) }.count

        return VStack(alignment: .leading, spacing: Spacing.sm) {
            // Section Header
            HStack {
                Text("// \(title)")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.lightGray)

                Spacer()

                Text("\(unlockedInSection)/\(achievements.count)")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(unlockedInSection == achievements.count ? Color.matrixGreen : Color.mediumGray)
            }
            .padding(.horizontal, Spacing.lg)

            // Icon Grid
            LazyVGrid(columns: gridColumns, spacing: 12) {
                ForEach(achievements) { achievement in
                    AchievementBadge(
                        achievement: achievement,
                        isUnlocked: unlockedIds.contains(achievement.id)
                    )
                    .onTapGesture {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        selectedAchievement = achievement
                    }
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.sm)
            .background(Color.darkGray.opacity(0.5))
            .cornerRadius(12)
            .padding(.horizontal, Spacing.md)
        }
    }
}

#Preview {
    CommandCenterView()
        .modelContainer(for: [Power.self, Agent.self, CheckIn.self], inMemory: true)
}


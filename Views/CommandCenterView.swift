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
    @State private var editingPower: Power? = nil
    @State private var editingAgent: Agent? = nil
    @State private var deletingPower: Power? = nil
    @State private var deletingAgent: Agent? = nil
    @State private var showDeleteConfirmation: Bool = false
    @State private var showDeleteError: Bool = false
    @State private var showWhiteRabbit: Bool = false
    @State private var showHabitTip: Bool = false
    @State private var showGhostTutorial: Bool = false
    @State private var showDailyAffirmation: Bool = false
    @StateObject private var rabbitManager = WhiteRabbitManager()
    @AppStorage("hasSeenHabitTip") private var hasSeenHabitTip: Bool = false
    @AppStorage("hasSeenGhostTutorial") private var hasSeenGhostTutorial: Bool = false
    @AppStorage("lastAffirmationDate") private var lastAffirmationDate: Double = 0

    // Tier Promotion System
    @State private var promotionCandidate: PromotionCandidate? = nil

    // Collapsible section states
    @State private var isPowersExpanded: Bool = true
    @State private var isAgentsExpanded: Bool = true
    @State private var isSidequestsExpanded: Bool = false
    @State private var sidequestRefreshTrigger: Int = 0 // Forces refresh when sidequests complete
    private var empTokenDisplayCount: Int { UserProfile.empTokens }

    // Paywall
    @State private var showPaywall: Bool = false

    // Submit All
    @State private var isSubmittingAll: Bool = false
    @State private var showSubmitAllSuccess: Bool = false
    @State private var cachedAffirmation: String?

    // MARK: - Computed Properties

    private var totalSignalStrength: Int {
        let powerStreak = powers.reduce(0) { $0 + $1.currentStreak }
        let agentStreak = agents.reduce(0) { $0 + $1.currentStreak }
        return powerStreak + agentStreak
    }

    private var codeRainOpacity: Double {
        min(0.4, 0.1 + Double(totalSignalStrength) * 0.02)
    }

    private var codeRainSpeed: Double {
        min(3.0, 0.5 + Double(totalSignalStrength) * 0.1)
    }

    // Filter habits scheduled for today (exclude premium-locked for free users)
    private var powersScheduledToday: [Power] {
        let isRedPill = StoreManager.shared.isRedPillOwned
        return powers.filter { $0.isScheduledToday && (isRedPill || !$0.isPremiumLocked) }
    }

    private var agentsScheduledToday: [Agent] {
        let isRedPill = StoreManager.shared.isRedPillOwned
        return agents.filter { $0.isScheduledToday && (isRedPill || !$0.isPremiumLocked) }
    }

    private var allPowersCompleted: Bool {
        let scheduled = powersScheduledToday
        return !scheduled.isEmpty && scheduled.allSatisfy { $0.completedToday }
    }

    private var allAgentsCompleted: Bool {
        let scheduled = agentsScheduledToday
        return !scheduled.isEmpty && scheduled.allSatisfy { $0.resistedToday || $0.relapsedToday }
    }

    private var allHabitsCompleted: Bool {
        let hasScheduled = !powersScheduledToday.isEmpty || !agentsScheduledToday.isEmpty
        let powersOk = powersScheduledToday.isEmpty || allPowersCompleted
        let agentsOk = agentsScheduledToday.isEmpty || allAgentsCompleted
        return hasScheduled && powersOk && agentsOk
    }

    private var powersCompletedCount: Int {
        powersScheduledToday.filter { $0.completedToday }.count
    }

    private var agentsCompletedCount: Int {
        agentsScheduledToday.filter { $0.resistedToday || $0.relapsedToday }.count
    }

    private var todayCompletedCount: Int {
        powersCompletedCount + agentsCompletedCount
    }

    private var totalHabitsCount: Int {
        powersScheduledToday.count + agentsScheduledToday.count
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

    private var operativeName: String {
        UserProfile.displayName
    }

    private var incompleteHabitsCount: Int {
        let incompletePowers = powersScheduledToday.filter { !$0.completedToday }.count
        let incompleteAgents = agentsScheduledToday.filter { !$0.resistedToday && !$0.relapsedToday }.count
        return incompletePowers + incompleteAgents
    }

    private var hasIncompleteHabits: Bool {
        incompleteHabitsCount > 0
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.matrixBlack
                .ignoresSafeArea()

            CodeRainBackground(opacity: codeRainOpacity, speed: codeRainSpeed)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                if selectedTab == 0 {
                    dashboardContent
                } else if selectedTab == 1 {
                    SignalAnalysisView()
                } else if selectedTab == 2 {
                    AchievementsTabView()
                }

                tabBarView
            }

            if showWhiteRabbit {
                WhiteRabbitOverlay(isVisible: $showWhiteRabbit) { reward in
                    handleRabbitReward(reward)
                }
            }
        }
        .onAppear {
            syncWidgetData()
            rabbitManager.checkForRabbit()



            if !hasSeenGhostTutorial && (!powers.isEmpty || !agents.isEmpty) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation { showGhostTutorial = true }
                }
            } else if hasSeenGhostTutorial && shouldShowDailyAffirmation {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation { showDailyAffirmation = true }
                }
            }

            checkForTierPromotions()
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
        .sheet(isPresented: $showPaywall) {
            RedPillPaywallView()
        }
        .sheet(isPresented: $showSettings) {
            ZionMainframeView()
        }
        .onChange(of: showSettings) { _, isShowing in
            if !isShowing {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    checkForTierPromotions()
                }
            }
        }
        .sheet(item: $selectedPower) { power in
            DialInView(power: power, agent: nil)
        }
        .sheet(item: $selectedAgent) { agent in
            DialInView(power: nil, agent: agent)
        }
        .sheet(item: $editingPower) { power in
            EditHabitSheet(power: power, agent: nil)
        }
        .sheet(item: $editingAgent) { agent in
            EditHabitSheet(power: nil, agent: agent)
        }
        .sheet(item: $promotionCandidate) { candidate in
            TierPromotionSheet(
                candidate: candidate,
                onAccept: { _ in },
                onDecline: { }
            )
        }
        .overlay {
            if showHabitTip {
                HabitTipOverlay(onDismiss: dismissTip)
            }
            if showGhostTutorial {
                GhostTutorialOverlay(onDismiss: dismissGhostTutorial)
            }
            if showDailyAffirmation {
                DailyAffirmationOverlay(affirmation: dailyAffirmation, onDismiss: dismissAffirmation)
            }
        }
        .onChange(of: powers.count + agents.count) { oldValue, newValue in
            if oldValue == 0 && newValue > 0 && !hasSeenHabitTip {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation { showHabitTip = true }
                }
            }
            syncWidgetData()
        }
        .alert("DELETE PROGRAM?", isPresented: $showDeleteConfirmation) {
            Button("DELETE", role: .destructive) {
                deleteSelectedHabit()
            }
            Button("CANCEL", role: .cancel) {
                deletingPower = nil
                deletingAgent = nil
            }
        } message: {
            Text("This will permanently delete this program and all its check-in history. This cannot be undone.")
        }
        .alert("DELETE FAILED", isPresented: $showDeleteError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Failed to delete program. Please try again.")
        }
    }

    // MARK: - Delete Habit

    private func deleteSelectedHabit() {
        if let power = deletingPower {
            modelContext.delete(power)
            deletingPower = nil
        } else if let agent = deletingAgent {
            modelContext.delete(agent)
            deletingAgent = nil
        }

        do {
            try modelContext.save()
        } catch {
            ErrorLogger.logSaveFailure(error, context: "CommandCenterView.deleteSelectedHabit")
            showDeleteError = true
        }
    }

    // MARK: - Submit All Habits

    private func submitAllHabits() {
        guard !isSubmittingAll else { return }
        isSubmittingAll = true

        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        let result = CheckInService.submitAllHabits(
            powers: Array(powersScheduledToday),
            agents: Array(agentsScheduledToday),
            context: modelContext
        )

        switch result {
        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    isSubmittingAll = false
                    showSubmitAllSuccess = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        showSubmitAllSuccess = false
                    }
                }
            }
        case .failure:
            isSubmittingAll = false
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }

    // MARK: - Dismiss Actions

    private func dismissTip() {
        withAnimation {
            showHabitTip = false
            hasSeenHabitTip = true
        }
    }

    private func dismissGhostTutorial() {
        withAnimation {
            showGhostTutorial = false
            hasSeenGhostTutorial = true
        }
    }

    private func dismissAffirmation() {
        withAnimation {
            showDailyAffirmation = false
            lastAffirmationDate = Date().timeIntervalSince1970
        }
    }

    // MARK: - Daily Affirmation Logic

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
        if let cached = cachedAffirmation { return cached }
        let result: String
        if let streak = bestStreak, streak.days > 0 {
            let messages = [
                "Day \(streak.days) of \(streak.name).\nMost people can't do 3 days.\nYou're not most people.",
                "\(streak.days) days strong.\nThe Matrix is losing its grip.\nKeep going, Operator.",
                "Signal strength: \(streak.days) days.\nYou're rewriting your code.\nOne day at a time.",
                "\(streak.days) consecutive uploads.\nThe old you would have quit.\nBut you're still here.",
                "Day \(streak.days). The compound effect is real.\nSmall wins create momentum.\nMomentum creates change."
            ]
            result = messages.randomElement() ?? messages[0]
        } else {
            let messages = [
                "Every master was once a disaster.\nToday is Day 1.\nMake it count.",
                "The journey of 66 days\nbegins with a single check-in.\nYou've got this.",
                "Welcome back, Operator.\nThe Matrix is waiting.\nTime to fight back."
            ]
            result = messages.randomElement() ?? messages[0]
        }
        DispatchQueue.main.async { cachedAffirmation = result }
        return result
    }

    // MARK: - Dashboard Content

    private var dashboardContent: some View {
        VStack(spacing: 0) {
            headerView

            ScrollView {
                VStack(spacing: Spacing.md) {
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

                    // Submit All Button
                    if hasIncompleteHabits {
                        submitAllButton
                            .padding(.horizontal, Spacing.md)
                    }

                    if !powers.isEmpty {
                        let scheduledCount = powersScheduledToday.count
                        let subtitle = allPowersCompleted ? "ALL SYNCED" :
                            (scheduledCount < powers.count ?
                                "\(powersCompletedCount)/\(scheduledCount) TODAY" :
                                "\(powersCompletedCount)/\(powers.count) UPLOADED")
                        CollapsibleSection(
                            title: "// LOADED HACKS",
                            subtitle: subtitle,
                            accentColor: Color.matrixGreen,
                            isExpanded: $isPowersExpanded
                        ) {
                            powersContent
                        }
                    }

                    if !agents.isEmpty {
                        let scheduledCount = agentsScheduledToday.count
                        let subtitle = allAgentsCompleted ? "ALL CONTAINED" :
                            (scheduledCount < agents.count ?
                                "\(agentsCompletedCount)/\(scheduledCount) TODAY" :
                                "\(agentsCompletedCount)/\(agents.count) RESISTED")
                        CollapsibleSection(
                            title: "// DETECTED AGENTS",
                            subtitle: subtitle,
                            accentColor: Color.agentRed,
                            isExpanded: $isAgentsExpanded
                        ) {
                            agentsContent
                        }
                    }

                    sidequestsSection

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

    // MARK: - Submit All Button

    private var submitAllButton: some View {
        Button(action: submitAllHabits) {
            HStack(spacing: Spacing.sm) {
                if isSubmittingAll {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                        .scaleEffect(0.8)
                } else if showSubmitAllSuccess {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 18))
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                }
                Text(submitAllButtonLabel)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                LinearGradient(
                    colors: [Color.matrixGreen, Color.matrixGreen.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(Theme.cornerRadius)
            .shadow(color: Color.matrixGreen.opacity(0.4), radius: 8, x: 0, y: 4)
        }
        .disabled(isSubmittingAll || showSubmitAllSuccess)
        .opacity(isSubmittingAll ? 0.7 : 1.0)
    }

    private var submitAllButtonLabel: String {
        if isSubmittingAll { return "SYNCING..." }
        if showSubmitAllSuccess { return "ALL SIGNALS LOCKED" }
        return "SUBMIT ALL (\(incompleteHabitsCount))"
    }

    // MARK: - Powers Content

    private var powersContent: some View {
        VStack(spacing: Spacing.sm) {
            // Active scheduled habits
            ForEach(powers.filter { $0.isScheduledToday && !$0.isPremiumLocked }) { power in
                let isCompleted = power.completedToday
                let hackHabit = HackHabit.allCases.first { $0.rawValue == power.name }
                HabitCard(
                    title: power.name,
                    icon: power.icon,
                    currentDay: power.currentStreak,
                    targetDays: power.targetDays,
                    isCompletedToday: isCompleted,
                    isPower: true,
                    subtitle: hackHabit?.shortDescription,
                    onEdit: { editingPower = power },
                    onDelete: {
                        deletingPower = power
                        showDeleteConfirmation = true
                    }
                )
                .padding(.horizontal, Spacing.md)
                .onTapGesture {
                    selectedPower = power
                }
            }
            // Active non-scheduled habits (rest day)
            ForEach(powers.filter { !$0.isScheduledToday && !$0.isPremiumLocked }) { power in
                HabitCard(
                    title: power.name,
                    icon: power.icon,
                    currentDay: power.currentStreak,
                    targetDays: power.targetDays,
                    isCompletedToday: false,
                    isPower: true,
                    subtitle: "REST DAY",
                    isRestDay: true,
                    onEdit: { editingPower = power },
                    onDelete: {
                        deletingPower = power
                        showDeleteConfirmation = true
                    }
                )
                .padding(.horizontal, Spacing.md)
                .opacity(0.5)
            }
            // Locked habits
            ForEach(powers.filter { $0.isPremiumLocked }) { power in
                let hackHabit = HackHabit.allCases.first { $0.rawValue == power.name }
                HabitCard(
                    title: power.name,
                    icon: power.icon,
                    currentDay: 0,
                    targetDays: power.targetDays,
                    isCompletedToday: false,
                    isPower: true,
                    subtitle: hackHabit?.shortDescription,
                    isLocked: true
                )
                .padding(.horizontal, Spacing.md)
                .onTapGesture {
                    showPaywall = true
                }
            }
        }
    }

    // MARK: - Agents Content

    private var agentsContent: some View {
        VStack(spacing: Spacing.sm) {
            // Active scheduled habits
            ForEach(agents.filter { $0.isScheduledToday && !$0.isPremiumLocked }) { agent in
                let isCompleted = agent.resistedToday || agent.relapsedToday
                let agentHabit = AgentHabit.allCases.first { $0.rawValue == agent.name }
                HabitCard(
                    title: agent.name,
                    icon: agent.icon,
                    currentDay: agent.currentStreak,
                    targetDays: agent.targetDays,
                    isCompletedToday: isCompleted,
                    isPower: false,
                    subtitle: agentHabit?.shortDescription,
                    onEdit: { editingAgent = agent },
                    onDelete: {
                        deletingAgent = agent
                        showDeleteConfirmation = true
                    }
                )
                .padding(.horizontal, Spacing.md)
                .onTapGesture {
                    selectedAgent = agent
                }
            }
            // Active non-scheduled habits (rest day)
            ForEach(agents.filter { !$0.isScheduledToday && !$0.isPremiumLocked }) { agent in
                HabitCard(
                    title: agent.name,
                    icon: agent.icon,
                    currentDay: agent.currentStreak,
                    targetDays: agent.targetDays,
                    isCompletedToday: false,
                    isPower: false,
                    subtitle: "REST DAY",
                    isRestDay: true,
                    onEdit: { editingAgent = agent },
                    onDelete: {
                        deletingAgent = agent
                        showDeleteConfirmation = true
                    }
                )
                .padding(.horizontal, Spacing.md)
                .opacity(0.5)
            }
            // Locked habits
            ForEach(agents.filter { $0.isPremiumLocked }) { agent in
                let agentHabit = AgentHabit.allCases.first { $0.rawValue == agent.name }
                HabitCard(
                    title: agent.name,
                    icon: agent.icon,
                    currentDay: 0,
                    targetDays: agent.targetDays,
                    isCompletedToday: false,
                    isPower: false,
                    subtitle: agentHabit?.shortDescription,
                    isLocked: true
                )
                .padding(.horizontal, Spacing.md)
                .onTapGesture {
                    showPaywall = true
                }
            }
        }
    }

    // MARK: - Sidequests Section

    private var sidequestsSection: some View {
        VStack(spacing: Spacing.sm) {
            if StoreManager.shared.isRedPillOwned {
                SidequestSectionHeader(
                    isAvailable: allHabitsCompleted,
                    isExpanded: $isSidequestsExpanded,
                    xpEarned: SidequestManager.sidequestXPToday,
                    xpCap: SidequestManager.dailyXPCap
                )
                .id(sidequestRefreshTrigger)
            } else {
                SidequestSectionHeader(
                    isAvailable: allHabitsCompleted,
                    isExpanded: .constant(false),
                    xpEarned: 0,
                    xpCap: SidequestManager.dailyXPCap
                )
                .overlay(
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            showPaywall = true
                        }
                )
                .overlay(alignment: .trailing) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.orange)
                        .padding(.trailing, Spacing.md)
                }
            }

            if isSidequestsExpanded && allHabitsCompleted && StoreManager.shared.isRedPillOwned {
                ConstructLoaderView(onSidequestComplete: {
                    sidequestRefreshTrigger += 1
                })
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("> LOGGED IN: \(operativeName.uppercased())")
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(Color.matrixGreen)
                .shadow(color: Color.matrixGreen.opacity(0.5), radius: 4)

            HStack {
                Text("COMMAND CENTER")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)

                Spacer()

                // EMP Token Display
                HStack(spacing: 4) {
                    Image(systemName: "bolt.shield.fill")
                        .font(.system(size: 10))
                    Text("\(empTokenDisplayCount)")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                }
                .foregroundColor(.purple)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, Spacing.xs)
                .background(Color.darkGray)
                .cornerRadius(Theme.cornerRadiusCompact)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cornerRadiusCompact)
                        .stroke(Color.purple.opacity(0.5), lineWidth: 1)
                )

                Text("RANK: \(UserProfile.currentRank.rawValue)")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(Color.matrixGreen)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(Color.darkGray)
                    .cornerRadius(Theme.cornerRadiusCompact)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.cornerRadiusCompact)
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

            Button(action: {
                if StoreManager.shared.canCreateHabit(currentCount: powers.filter { !$0.isPremiumLocked }.count + agents.filter { !$0.isPremiumLocked }.count) {
                    showAddHabit = true
                } else {
                    showPaywall = true
                }
            }) {
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

            TabBarButton(icon: "square.grid.2x2", isSelected: selectedTab == 0) {
                selectedTab = 0
            }

            Spacer()

            TabBarButton(icon: "chart.bar", isSelected: selectedTab == 1) {
                selectedTab = 1
            }

            Spacer()

            Button(action: {
                if StoreManager.shared.canCreateHabit(currentCount: powers.filter { !$0.isPremiumLocked }.count + agents.filter { !$0.isPremiumLocked }.count) {
                    showAddHabit = true
                } else {
                    showPaywall = true
                }
            }) {
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

            TabBarButton(icon: "trophy", isSelected: selectedTab == 2) {
                selectedTab = 2
            }

            Spacer()

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
            break
        }
    }

    // MARK: - Widget Data Sync

    private func syncWidgetData() {
        WidgetDataManager.update(
            powers: powers.map { ($0.id.uuidString, $0.name, $0.icon, $0.currentStreak, $0.completedToday, $0.isScheduledToday) },
            agents: agents.map { ($0.id.uuidString, $0.name, $0.icon, $0.currentStreak, $0.resistedToday, $0.isScheduledToday) }
        )
    }

    // MARK: - Tier Promotion System

    private func checkForTierPromotions() {
        guard !showGhostTutorial && !showDailyAffirmation else { return }

        let activeAgents = agents.filter { !$0.isDefeated }
        let candidates = TierPromotionManager.checkForPromotions(agents: activeAgents)
        let eligibleCandidates = TierPromotionManager.filterDeclinedPromotions(candidates)

        if let firstCandidate = eligibleCandidates.first {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                promotionCandidate = firstCandidate
            }
        }
    }
}

#Preview {
    CommandCenterView()
        .modelContainer(for: [Power.self, Agent.self, CheckIn.self], inMemory: true)
}

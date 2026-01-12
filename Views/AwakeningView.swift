import SwiftUI
import SwiftData

// MARK: - Awakening Flow Container

struct AwakeningView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isPresented: Bool

    // MARK: - Phase State
    @State private var currentPhase: Int = 0
    @State private var transitionOpacity: Double = 1.0

    // MARK: - Collected Data
    @State private var operatorName: String = ""
    @State private var operatorAge: String = ""
    @State private var livingBelowPotential: Bool? = nil
    @State private var selectedProblems: Set<ModernProblem> = []
    @State private var hoursLost: Int = 3
    @State private var brokenPromises: BrokenPromisesOption? = nil
    @State private var postScrollEmotion: ScrollEmotion? = nil
    @State private var movementLevel: MovementLevel? = nil
    @State private var energyCrash: EnergyCrash? = nil
    @State private var sleepQuality: SleepQuality? = nil
    @State private var motivationType: MotivationType? = nil
    @State private var choseRedPill: Bool = false
    @State private var suggestedLoadout: ProtocolLoadout = ProtocolLoadout()
    @State private var showSaveError: Bool = false

    private let totalPhases = 17

    var body: some View {
        ZStack {
            // Background
            Color.matrixBlack.ignoresSafeArea()

            // Code Rain (intensity varies by phase)
            CodeRainBackground(
                opacity: codeRainOpacity,
                speed: codeRainSpeed
            )
            .ignoresSafeArea()

            // P1: Progress indicator (hidden on special phases)
            if shouldShowProgressIndicator {
                VStack {
                    OnboardingProgressBar(currentPhase: currentPhase, totalPhases: totalPhases)
                        .padding(.top, Spacing.xl)
                        .padding(.horizontal, Spacing.lg)
                    Spacer()
                }
                .zIndex(100)
            }

            // Main content with top padding to avoid progress bar overlap
            Group {
                switch currentPhase {
                case 0:
                    PrisonerRecordPhase(
                        operatorName: $operatorName,
                        operatorAge: $operatorAge,
                        onComplete: { advancePhase() }
                    )
                case 1:
                    TerminologyCardPhase(
                        onBack: { goBack() },
                        onComplete: { advancePhase() }
                    )
                case 2:
                    LoadoutExpectationPhase(
                        onBack: { goBack() },
                        onComplete: { advancePhase() }
                    )
                case 3:
                    HookQuestionPhase(
                        answer: $livingBelowPotential,
                        onBack: { goBack() },
                        onComplete: { advancePhase() }
                    )
                case 4:
                    ProblemSelectionPhase(
                        selectedProblems: $selectedProblems,
                        onBack: { goBack() },
                        onComplete: { advancePhase() }
                    )
                case 5:
                    YearsDeletedPhase(
                        age: Int(operatorAge) ?? 25,
                        hoursLost: $hoursLost,
                        onBack: { goBack() },
                        onComplete: { advancePhase() }
                    )
                case 6:
                    BrokenPromisesPhase(
                        answer: $brokenPromises,
                        onBack: { goBack() },
                        onComplete: { advancePhase() }
                    )
                case 7:
                    PostScrollEmotionPhase(
                        answer: $postScrollEmotion,
                        onBack: { goBack() },
                        onComplete: { advancePhase() }
                    )
                case 8:
                    KineticIntegrityPhase(
                        answer: $movementLevel,
                        onBack: { goBack() },
                        onComplete: { advancePhase() }
                    )
                case 9:
                    FuelPurityPhase(
                        answer: $energyCrash,
                        onBack: { goBack() },
                        onComplete: { advancePhase() }
                    )
                case 10:
                    RechargeCyclePhase(
                        answer: $sleepQuality,
                        onBack: { goBack() },
                        onComplete: { advancePhase() }
                    )
                case 11:
                    MotivationCheckPhase(
                        answer: $motivationType,
                        onBack: { goBack() },
                        onComplete: { advancePhase() }
                    )
                case 12:
                    RedBluePillPhase(
                        choseRedPill: $choseRedPill,
                        onBack: { goBack() },
                        onRedPill: {
                            generateLoadout()
                            advancePhase()
                        },
                        onBluePill: { handleBluePill() }
                    )
                case 13:
                    TheTruthPhase(
                        onBack: { goBack() },
                        onComplete: { advancePhase() }
                    )
                case 14:
                    TheWayOutPhase(
                        onBack: { goBack() },
                        onComplete: { advancePhase() }
                    )
                case 15:
                    SolutionProtocolPhase(
                        loadout: $suggestedLoadout,
                        onBack: { goBack() },
                        onComplete: { advancePhase() }
                    )
                case 16:
                    ContractPhase(
                        onBack: { goBack() },
                        onComplete: { finalizeAwakening() }
                    )
                default:
                    EmptyView()
                }
            }
            .opacity(transitionOpacity)

            // CRT Overlays
            ScanlineOverlay()
            VignetteOverlay()
        }
        .alert("INITIALIZATION FAILED", isPresented: $showSaveError) {
            Button("RETRY", role: .cancel) {
                finalizeAwakening()
            }
        } message: {
            Text("Failed to save your protocol. Please try again.")
        }
    }

    private var codeRainOpacity: Double {
        switch currentPhase {
        case 0...2: return 0.08
        case 3...5: return 0.08
        case 6...9: return 0.12
        case 10...11: return 0.18
        case 12: return 0.0
        case 13: return 0.25
        case 14: return 0.35
        case 15...16: return 0.25
        default: return 0.1
        }
    }

    private var codeRainSpeed: Double {
        switch currentPhase {
        case 0...2: return 0.3
        case 3...7: return 0.3
        case 8...11: return 0.5
        case 12: return 0.0
        case 13: return 0.4
        case 14: return 1.2
        case 15: return 1.0
        case 16: return 2.0
        default: return 0.5
        }
    }

    private var shouldShowProgressIndicator: Bool {
        ![13, 14, 15, 17].contains(currentPhase)
    }

    private func advancePhase() {
        SoundManager.shared.playTap()

        withAnimation(.easeOut(duration: 0.2)) {
            transitionOpacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            currentPhase += 1
            withAnimation(.easeIn(duration: 0.2)) {
                transitionOpacity = 1.0
            }
        }
    }

    private func goBack() {
        guard currentPhase > 0 else { return }
        withAnimation(.easeOut(duration: 0.2)) {
            transitionOpacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            currentPhase -= 1
            withAnimation(.easeIn(duration: 0.2)) {
                transitionOpacity = 1.0
            }
        }
    }

    private func handleBluePill() {
        withAnimation(.easeOut(duration: 1.0)) {
            transitionOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isPresented = false
        }
    }

    private func generateLoadout() {
        let willpowerTier = getWillpowerTier()
        let physicalTier = getPhysicalTier()
        let severityScore = getSeverityScore()

        if isOptimizerProfile(willpower: willpowerTier, severity: severityScore) {
            generateOptimizerLoadout()
            return
        }

        if isDisasterProfile(willpower: willpowerTier, severity: severityScore) {
            generateDisasterLoadout()
            return
        }

        let problemsToProcess = resolveAllOfTheAbove()
        let sortedProblems = problemsToProcess.sorted { $0.priority < $1.priority }
        let effectiveTier = min(willpowerTier, physicalTier)

        var agentCandidates: [AgentHabit] = []
        var overflowProblems: [ModernProblem] = []

        for (index, problem) in sortedProblems.enumerated() {
            if index < 3 {
                if let agent = problem.agent(for: effectiveTier) {
                    agentCandidates.append(agent)
                } else if !problem.isDirectProblem {
                    agentCandidates.append(AgentFamily.anxiety.agent(for: effectiveTier))
                }
            } else {
                overflowProblems.append(problem)
            }
        }

        var powerCandidates: [HackHabit] = []
        for problem in sortedProblems {
            powerCandidates.append(contentsOf: problem.suggestedHacks)
        }

        for problem in overflowProblems {
            if let primary = problem.primaryPower {
                powerCandidates.insert(primary, at: 0)
            }
        }

        addSignalBasedHabits(powers: &powerCandidates, agents: &agentCandidates, willpowerTier: willpowerTier)

        let filteredPowers = filterByDifficulty(powers: powerCandidates, maxDifficulty: effectiveTier)

        var seenPowers = Set<HackHabit>()
        var uniquePowers = filteredPowers.filter { seenPowers.insert($0).inserted }

        var seenAgents = Set<AgentHabit>()
        let uniqueAgents = agentCandidates.filter { seenAgents.insert($0).inserted }

        if uniquePowers.contains(.brainDump) && uniquePowers.contains(.dailyWs) {
            uniquePowers.removeAll { $0 == .dailyWs }
        }

        let bedroomPhoneAgents: Set<AgentHabit> = [.noBedScrolling, .noPMONightShield]
        if uniqueAgents.contains(where: { bedroomPhoneAgents.contains($0) }) {
            uniquePowers.removeAll { $0 == .phoneJail }
        }

        suggestedLoadout.hacks = Array(uniquePowers.prefix(3))
        suggestedLoadout.agents = Array(uniqueAgents.prefix(3))

        fillFromUniversalPool()
        ensureMinimumLoadout()
    }

    private func resolveAllOfTheAbove() -> [ModernProblem] {
        guard selectedProblems.contains(.allAbove) else {
            return Array(selectedProblems)
        }

        var inferred: [ModernProblem] = []

        if sleepQuality == .broken && hoursLost >= 6 {
            inferred.append(.doomscrolling)
        } else if energyCrash == .constant && movementLevel == .monthPlus {
            inferred.append(.bedRotting)
        } else if postScrollEmotion == .regret && brokenPromises == .always {
            inferred.append(.adultContent)
        } else if energyCrash == .morning && sleepQuality == .groggy {
            inferred.append(.junkFood)
        } else if hoursLost >= 6 {
            inferred.append(.doomscrolling)
        } else if sleepQuality == .broken {
            inferred.append(.bedRotting)
        } else {
            inferred.append(.doomscrolling)
        }

        if movementLevel == .monthPlus && !inferred.contains(.bedRotting) {
            inferred.append(.bedRotting)
        }
        if energyCrash == .constant && !inferred.contains(.junkFood) {
            inferred.append(.junkFood)
        }

        return inferred
    }

    private func addSignalBasedHabits(powers: inout [HackHabit], agents: inout [AgentHabit], willpowerTier: DifficultyTier) {
        switch willpowerTier {
        case .hard: powers.append(.lockIn)
        case .medium: powers.append(.brainDump)
        case .easy: powers.append(.morningWin)
        }

        if postScrollEmotion == .empty {
            powers.append(.dailyWs)
            agents.append(.noSelfSabotage)
        } else if postScrollEmotion == .regret {
            powers.append(.brainDump)
            agents.append(.noRageBait)
        }

        switch energyCrash {
        case .morning:
            powers.append(.hydrationMax)
        case .afternoon:
            powers.append(.proteinFirst)
            agents.append(.noLiquidSugar)
        case .constant:
            powers.append(.proteinFirst)
            agents.append(.noJunkMeals)
        case .none:
            powers.append(.hydrationMax)
        }

        if sleepQuality == .broken {
            powers.append(.deepSleep)
            agents.append(.noBedScrolling)
        }
    }

    private func getWillpowerTier() -> DifficultyTier {
        switch brokenPromises {
        case .rarely: return .hard
        case .often: return .medium
        case .always: return .easy
        case .none: return .medium
        }
    }

    private func getPhysicalTier() -> DifficultyTier {
        switch movementLevel {
        case .recent: return .hard
        case .lastWeek: return .medium
        case .monthPlus: return .easy
        case .none: return .medium
        }
    }

    private func getSeverityScore() -> Int {
        return hoursLost
    }

    private func isOptimizerProfile(willpower: DifficultyTier, severity: Int) -> Bool {
        let fewProblems = selectedProblems.count <= 1 || (selectedProblems.count == 1 && selectedProblems.contains(.allAbove) == false)
        let lowSeverity = severity <= 2
        let goodSleep = sleepQuality == .optimized
        let activeBody = movementLevel == .recent
        let strongWill = willpower == .hard || willpower == .medium

        return lowSeverity && fewProblems && goodSleep && activeBody && strongWill
    }

    private func isDisasterProfile(willpower: DifficultyTier, severity: Int) -> Bool {
        let highSeverity = severity >= 6
        let brokenSleep = sleepQuality == .broken
        let lowWill = willpower == .easy
        let manyProblems = selectedProblems.contains(.allAbove) || selectedProblems.count >= 4

        return highSeverity && brokenSleep && lowWill && manyProblems
    }

    private func generateOptimizerLoadout() {
        suggestedLoadout.hacks = [.coldReboot, .lockIn, .skillUpload]
        suggestedLoadout.agents = [.noBrainRot, .noLateNight, .noImpulseBuys]
    }

    private func generateDisasterLoadout() {
        let problemsToProcess = resolveAllOfTheAbove()
        let sortedProblems = problemsToProcess.sorted { $0.priority < $1.priority }

        var agentCandidates: [AgentHabit] = []
        for problem in sortedProblems.prefix(3) {
            if let agent = problem.agent(for: .easy) {
                agentCandidates.append(agent)
            }
        }

        let easyUniversals: [AgentHabit] = [.noBedScrolling, .noLiquidSugar, .morningMaker, .noChairLock, .noGhostingIRL]
        while agentCandidates.count < 3 {
            for agent in easyUniversals {
                if !agentCandidates.contains(agent) {
                    agentCandidates.append(agent)
                    break
                }
            }
            if agentCandidates.count >= 3 { break }
        }

        var powerCandidates: [HackHabit] = []
        for problem in sortedProblems {
            powerCandidates.append(contentsOf: problem.suggestedHacks)
        }

        let easyPowers = powerCandidates.filter { $0.difficulty == .easy }
        let easyFallbacks: [HackHabit] = [.hydrationMax, .morningWin, .solarLoad, .phoneJail, .dailyWs, .staticStretch]
        var finalPowers = easyPowers
        for fallback in easyFallbacks {
            if !finalPowers.contains(fallback) {
                finalPowers.append(fallback)
            }
        }

        var seenAgents = Set<AgentHabit>()
        let uniqueAgents = agentCandidates.filter { seenAgents.insert($0).inserted }
        suggestedLoadout.agents = Array(uniqueAgents.prefix(3))

        var seenPowers = Set<HackHabit>()
        var uniquePowers = finalPowers.filter { seenPowers.insert($0).inserted }

        let bedroomPhoneAgents: Set<AgentHabit> = [.noBedScrolling, .noPMONightShield]
        if uniqueAgents.contains(where: { bedroomPhoneAgents.contains($0) }) {
            uniquePowers.removeAll { $0 == .phoneJail }
        }

        suggestedLoadout.hacks = Array(uniquePowers.prefix(3))
    }

    private func filterByDifficulty(powers: [HackHabit], maxDifficulty: DifficultyTier) -> [HackHabit] {
        return powers.filter { power in
            switch maxDifficulty {
            case .easy: return power.difficulty == .easy
            case .medium: return power.difficulty == .easy || power.difficulty == .medium
            case .hard: return true
            }
        }
    }

    private func fillFromUniversalPool() {
        let universalPool: [AgentHabit] = [
            .noBedScrolling, .noLiquidSugar, .morningMaker, .noChairLock, .noGhostingIRL, .noRageBait
        ]

        while suggestedLoadout.agents.count < 3 {
            for agent in universalPool {
                if !suggestedLoadout.agents.contains(agent) {
                    suggestedLoadout.agents.append(agent)
                    break
                }
            }
            if suggestedLoadout.agents.count < 3 && universalPool.allSatisfy({ suggestedLoadout.agents.contains($0) }) {
                break
            }
        }
    }

    private func ensureMinimumLoadout() {
        if suggestedLoadout.hacks.isEmpty {
            suggestedLoadout.hacks = [.hydrationMax, .morningWin, .solarLoad]
        }
        while suggestedLoadout.hacks.count < 3 {
            let fallbacks: [HackHabit] = [.hydrationMax, .morningWin, .solarLoad, .phoneJail, .staticStretch, .dailyWs]
            for hack in fallbacks {
                if !suggestedLoadout.hacks.contains(hack) {
                    suggestedLoadout.hacks.append(hack)
                    break
                }
            }
        }

        if suggestedLoadout.agents.isEmpty {
            suggestedLoadout.agents = [.noBedScrolling, .noLiquidSugar, .morningMaker]
        }
    }

    private func finalizeAwakening() {
        UserDefaults.standard.set(operatorName, forKey: UserDefaultsKeys.operatorName)
        UserDefaults.standard.set(Int(operatorAge) ?? 25, forKey: UserDefaultsKeys.operatorAge)

        if suggestedLoadout.hacks.isEmpty {
            suggestedLoadout.hacks = [.touchGrass, .hydrationMax, .morningWin]
        }
        if suggestedLoadout.agents.isEmpty {
            suggestedLoadout.agents = [.noBrainRot, .noJunkMeals, .noBedScrolling]
        }

        for hack in suggestedLoadout.hacks {
            let power = Power(name: hack.habitName, icon: hack.icon)
            modelContext.insert(power)
        }

        for agent in suggestedLoadout.agents {
            let agentModel = Agent(name: agent.habitName, icon: agent.icon)
            modelContext.insert(agentModel)
        }

        do {
            try modelContext.save()
            UserProfile.completeOnboarding()
            isPresented = false
        } catch {
            ErrorLogger.logSaveFailure(error, context: "AwakeningView.finalizeAwakening")
            showSaveError = true
        }
    }
}

#Preview {
    AwakeningView(isPresented: .constant(true))
        .modelContainer(for: [Power.self, Agent.self, CheckIn.self], inMemory: true)
}

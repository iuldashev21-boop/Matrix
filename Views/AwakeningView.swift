import SwiftUI
import SwiftData

// MARK: - CRT Overlay Components

struct ScanlineOverlay: View {
    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                for y in stride(from: 0, to: size.height, by: 3) {
                    context.fill(
                        Path(CGRect(x: 0, y: y, width: size.width, height: 1)),
                        with: .color(.black.opacity(0.15))
                    )
                }
            }
        }
        .allowsHitTesting(false)
    }
}

struct VignetteOverlay: View {
    var body: some View {
        RadialGradient(
            gradient: Gradient(colors: [.clear, .black.opacity(0.6)]),
            center: .center,
            startRadius: UIScreen.main.bounds.width * 0.3,
            endRadius: UIScreen.main.bounds.width * 0.9
        )
        .allowsHitTesting(false)
    }
}

struct MatrixTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: Color.matrixGreen.opacity(0.6), radius: 4)
    }
}

extension View {
    func matrixGlow() -> some View {
        modifier(MatrixTextStyle())
    }
}

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
    @State private var neglectedDream: DreamCategory? = nil
    @State private var mentalClarity: Double = 5
    @State private var screenOverPerson: Bool? = nil
    @State private var motivationType: MotivationType? = nil
    @State private var yearProjection: YearProjectionOption? = nil
    @State private var choseRedPill: Bool = false
    @State private var suggestedLoadout: ProtocolLoadout = ProtocolLoadout()

    private let totalPhases = 14

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

            // Main content
            Group {
                switch currentPhase {
                case 0:
                    PrisonerRecordPhase(
                        operatorName: $operatorName,
                        operatorAge: $operatorAge,
                        onComplete: { advancePhase() }
                    )
                case 1:
                    HookQuestionPhase(
                        answer: $livingBelowPotential,
                        onComplete: { advancePhase() }
                    )
                case 2:
                    ProblemSelectionPhase(
                        selectedProblems: $selectedProblems,
                        onComplete: { advancePhase() }
                    )
                case 3:
                    YearsDeletedPhase(
                        age: Int(operatorAge) ?? 25,
                        hoursLost: $hoursLost,
                        onComplete: { advancePhase() }
                    )
                case 4:
                    BrokenPromisesPhase(
                        answer: $brokenPromises,
                        onComplete: { advancePhase() }
                    )
                case 5:
                    PostScrollEmotionPhase(
                        answer: $postScrollEmotion,
                        onComplete: { advancePhase() }
                    )
                case 6:
                    NeglectedDreamPhase(
                        answer: $neglectedDream,
                        onComplete: { advancePhase() }
                    )
                case 7:
                    MentalClarityPhase(
                        clarity: $mentalClarity,
                        onComplete: { advancePhase() }
                    )
                case 8:
                    ScreenOverPersonPhase(
                        answer: $screenOverPerson,
                        onComplete: { advancePhase() }
                    )
                case 9:
                    MotivationCheckPhase(
                        answer: $motivationType,
                        onComplete: { advancePhase() }
                    )
                case 10:
                    YearProjectionPhase(
                        answer: $yearProjection,
                        onComplete: { advancePhase() }
                    )
                case 11:
                    RedBluePillPhase(
                        choseRedPill: $choseRedPill,
                        onRedPill: {
                            generateLoadout()
                            advancePhase()
                        },
                        onBluePill: { handleBluePill() }
                    )
                case 12:
                    SolutionProtocolPhase(
                        loadout: $suggestedLoadout,
                        onComplete: { advancePhase() }
                    )
                case 13:
                    ContractPhase(
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
    }

    private var codeRainOpacity: Double {
        switch currentPhase {
        case 0...3: return 0.08
        case 4...7: return 0.12
        case 8...10: return 0.18
        case 11: return 0.0 // Red/Blue pill - pure black
        case 12...13: return 0.25
        default: return 0.1
        }
    }

    private var codeRainSpeed: Double {
        switch currentPhase {
        case 0...5: return 0.3
        case 6...10: return 0.5
        case 11: return 0.0
        case 12: return 1.0
        case 13: return 2.0
        default: return 0.5
        }
    }

    private func advancePhase() {
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

    private func handleBluePill() {
        // Soft exit - dismiss awakening
        withAnimation(.easeOut(duration: 1.0)) {
            transitionOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isPresented = false
        }
    }

    private func generateLoadout() {
        var allHacks: [HackHabit] = []
        var allAgents: [AgentHabit] = []

        // Collect from selected problems
        for problem in selectedProblems where problem != .allAbove {
            allHacks.append(contentsOf: problem.suggestedHacks)
            allAgents.append(contentsOf: problem.suggestedAgents)
        }

        // Remove duplicates and limit to 3 each
        let uniqueHacks = Array(Set(allHacks)).prefix(3)
        let uniqueAgents = Array(Set(allAgents)).prefix(3)

        suggestedLoadout.hacks = Array(uniqueHacks)
        suggestedLoadout.agents = Array(uniqueAgents)

        // Fallback if empty
        if suggestedLoadout.hacks.isEmpty {
            suggestedLoadout.hacks = [.walk30Min, .drink2LWater, .journal]
        }
        if suggestedLoadout.agents.isEmpty {
            suggestedLoadout.agents = [.noDoomscrolling, .noJunkFood, .noProcrastinating]
        }
    }

    private func finalizeAwakening() {
        UserDefaults.standard.set(operatorName, forKey: "operatorName")
        UserDefaults.standard.set(Int(operatorAge) ?? 25, forKey: "operatorAge")

        // Create Powers (Hacks)
        for hack in suggestedLoadout.hacks {
            let power = Power(name: hack.habitName, icon: hack.icon)
            modelContext.insert(power)
        }

        // Create Agents (Bad habits to resist)
        for agent in suggestedLoadout.agents {
            let agentModel = Agent(name: agent.habitName, icon: agent.icon)
            modelContext.insert(agentModel)
        }

        try? modelContext.save()
        UserProfile.completeOnboarding()
        isPresented = false
    }
}

// MARK: - Data Types

enum ModernProblem: String, CaseIterable, Identifiable {
    case doomscrolling = "Doomscrolling"
    case adultContent = "Adult Content"
    case vaping = "Vaping / Substances"
    case junkFood = "Junk Food / Sugar"
    case bedRotting = "Bed Rotting"
    case gamingGambling = "Gaming / Gambling"
    case anxiety = "Chronic Anxiety"
    case allAbove = "All of the Above"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .doomscrolling: return "Losing hours to TikTok, Reels, or infinite feeds."
        case .adultContent: return "Cheap dopamine that kills your drive."
        case .vaping: return "Numbing stress instead of solving it."
        case .junkFood: return "Eating for sedation, not fuel."
        case .bedRotting: return "Procrastination disguised as comfort."
        case .gamingGambling: return "Chasing the high. Whether it's a rank or a payout."
        case .anxiety: return "Overthinking and paralysis."
        case .allAbove: return "I struggle with multiple issues."
        }
    }

    // 3 Hacks (good habits to BUILD)
    var suggestedHacks: [HackHabit] {
        switch self {
        case .doomscrolling: return [.read10Pages, .walk30Min, .journal]
        case .adultContent: return [.coldShower, .gym45Min, .connectCall]
        case .vaping: return [.meditate10Min, .gym45Min, .drink2LWater]
        case .junkFood: return [.eatGreenVeg, .drink2LWater, .mealPrep]
        case .bedRotting: return [.morningSunlight, .makeBed, .coldShower]
        case .gamingGambling: return [.learnSkill30Min, .walk30Min, .planTomorrow]
        case .anxiety: return [.meditate10Min, .walk30Min, .journal]
        case .allAbove: return [.walk30Min, .drink2LWater, .journal]
        }
    }

    // 3 Agents (bad habits to RESIST)
    var suggestedAgents: [AgentHabit] {
        switch self {
        case .doomscrolling: return [.noMorningScroll, .noPhoneBed, .noProcrastinating]
        case .adultContent: return [.noPorn, .noPhoneBed, .noDoomscrolling]
        case .vaping: return [.noVaping, .noAlcohol, .noSugar]
        case .junkFood: return [.noJunkFood, .noSugar, .noSoda]
        case .bedRotting: return [.noSnooze, .noPhoneBed, .noProcrastinating]
        case .gamingGambling: return [.noGaming, .noGambling, .noImpulseBuy]
        case .anxiety: return [.noDoomscrolling, .noNegativeTalk, .noProcrastinating]
        case .allAbove: return [.noDoomscrolling, .noJunkFood, .noProcrastinating]
        }
    }
}

// MARK: - Hack Habits (Good habits to DO)

enum HackHabit: String, CaseIterable {
    case walk30Min = "Walk 30 Minutes"
    case read10Pages = "Read 10 Pages"
    case drink2LWater = "Drink 2L Water"
    case coldShower = "Cold Shower"
    case gym45Min = "Gym Session (45m)"
    case noPhoneBed = "No Phone Before Bed"
    case journal = "Journal (5 mins)"
    case meditate10Min = "Meditate 10 mins"
    case makeBed = "Make Bed"
    case morningSunlight = "Morning Sunlight"
    case connectCall = "Call Someone"
    case learnSkill30Min = "Learn Skill (30m)"
    case planTomorrow = "Plan Tomorrow"
    case eatGreenVeg = "Eat Green Vegetables"
    case mealPrep = "Meal Prep"
    case takeVitamins = "Take Vitamins"
    case stretch15Min = "Stretch (15 mins)"
    case deepWork1Hr = "Deep Work (1 hour)"

    var habitName: String { rawValue }

    var icon: String {
        switch self {
        case .walk30Min: return "figure.walk"
        case .read10Pages: return "book.fill"
        case .drink2LWater: return "drop.fill"
        case .coldShower: return "snowflake"
        case .gym45Min: return "dumbbell.fill"
        case .noPhoneBed: return "moon.zzz.fill"
        case .journal: return "pencil.and.outline"
        case .meditate10Min: return "brain.head.profile"
        case .makeBed: return "bed.double.fill"
        case .morningSunlight: return "sun.max.fill"
        case .connectCall: return "phone.fill"
        case .learnSkill30Min: return "graduationcap.fill"
        case .planTomorrow: return "list.bullet.clipboard"
        case .eatGreenVeg: return "leaf.fill"
        case .mealPrep: return "fork.knife"
        case .takeVitamins: return "pills.fill"
        case .stretch15Min: return "figure.flexibility"
        case .deepWork1Hr: return "brain"
        }
    }

    var whyItWorks: String {
        switch self {
        case .walk30Min: return "Low-friction movement; reduces anxiety through optical flow."
        case .read10Pages: return "Replaces doomscrolling with deep focus."
        case .drink2LWater: return "Baseline cognitive function requires hydration."
        case .coldShower: return "Spikes dopamine naturally for hours."
        case .gym45Min: return "Heavy resistance releases endorphins."
        case .noPhoneBed: return "Protects melatonin production."
        case .journal: return "Offloads mental RAM; reduces rumination."
        case .meditate10Min: return "Increases prefrontal cortex thickness."
        case .makeBed: return "First win of the day; builds momentum."
        case .morningSunlight: return "Sets circadian rhythm; cortisol peak."
        case .connectCall: return "Oxytocin release; combats isolation."
        case .learnSkill30Min: return "Neuroplasticity requires focused effort."
        case .planTomorrow: return "Reduces decision fatigue next morning."
        case .eatGreenVeg: return "Micronutrient density for energy."
        case .mealPrep: return "Removes decision fatigue around food."
        case .takeVitamins: return "Low effort, high compounding value."
        case .stretch15Min: return "Counteracts desk posture."
        case .deepWork1Hr: return "Flow state trigger; high-value output."
        }
    }
}

// MARK: - Agent Habits (Bad habits to RESIST)

enum AgentHabit: String, CaseIterable {
    case noPorn = "No Porn / PMO"
    case noVaping = "No Vaping / Smoking"
    case noMorningScroll = "No Morning Scroll"
    case noJunkFood = "No Junk Food"
    case noAlcohol = "No Alcohol"
    case noGambling = "No Gambling"
    case noSnooze = "No Snooze Button"
    case noSugar = "No Sugar"
    case noImpulseBuy = "No Impulse Buys"
    case noNegativeTalk = "No Negative Self-Talk"
    case noGaming = "No Video Games"
    case noSoda = "No Soda"
    case noProcrastinating = "No Procrastinating"
    case noPhoneBed = "No Phone in Bed"
    case noDoomscrolling = "No Doomscrolling"

    var habitName: String { rawValue }

    var icon: String {
        switch self {
        case .noPorn: return "eye.slash.fill"
        case .noVaping: return "lungs.fill"
        case .noMorningScroll: return "iphone.slash"
        case .noJunkFood: return "takeoutbag.and.cup.and.straw.fill"
        case .noAlcohol: return "wineglass.fill"
        case .noGambling: return "dice.fill"
        case .noSnooze: return "alarm.fill"
        case .noSugar: return "cube.fill"
        case .noImpulseBuy: return "creditcard.fill"
        case .noNegativeTalk: return "bubble.left.and.exclamationmark.bubble.right"
        case .noGaming: return "gamecontroller.fill"
        case .noSoda: return "cup.and.saucer.fill"
        case .noProcrastinating: return "clock.arrow.circlepath"
        case .noPhoneBed: return "bed.double.fill"
        case .noDoomscrolling: return "arrow.down.circle.fill"
        }
    }

    var counterTactic: String {
        switch self {
        case .noPorn: return "Urge surfing - ride the wave until it passes."
        case .noVaping: return "Physiological sigh when cravings hit."
        case .noMorningScroll: return "Phone stays in another room."
        case .noJunkFood: return "Meal prep eliminates bad decisions."
        case .noAlcohol: return "Sparkling water as replacement."
        case .noGambling: return "Delete apps, block sites."
        case .noSnooze: return "Phone across the room."
        case .noSugar: return "Fruit as sweet replacement."
        case .noImpulseBuy: return "24-hour waiting rule."
        case .noNegativeTalk: return "Reframe with gratitude."
        case .noGaming: return "Replace with analog hobby."
        case .noSoda: return "Water with lemon."
        case .noProcrastinating: return "5-minute rule to start."
        case .noPhoneBed: return "Charge phone outside bedroom."
        case .noDoomscrolling: return "Set app time limits."
        }
    }
}

enum BrokenPromisesOption: String, CaseIterable {
    case rarely = "Rarely"
    case often = "Often"
    case always = "Always"
}

enum ScrollEmotion: String, CaseIterable {
    case happy = "Happy"
    case numb = "Numb"
    case regret = "Regret"
    case anxious = "Anxious"
}

enum DreamCategory: String, CaseIterable {
    case career = "Career / Business"
    case body = "Fitness / Health"
    case relationship = "Relationship"
    case skill = "Learning a Skill"
    case creative = "Creative Project"
}

enum MotivationType: String, CaseIterable {
    case myself = "For Myself"
    case should = "Because I Should"
}

enum YearProjectionOption: String, CaseIterable {
    case better = "Better Place"
    case same = "Same Place"
    case worse = "Worse Place"
}

// Full protocol loadout with both Hacks and Agents
struct ProtocolLoadout {
    var hacks: [HackHabit] = []
    var agents: [AgentHabit] = []
}

// MARK: - Phase 0: Prisoner Record

struct PrisonerRecordPhase: View {
    @Binding var operatorName: String
    @Binding var operatorAge: String
    let onComplete: () -> Void

    @State private var phase: InputPhase = .typing
    @State private var displayedLines: [String] = []
    @State private var currentTypingLine: String = ""
    @State private var showCursor: Bool = true
    @State private var showContinue: Bool = false
    @FocusState private var nameFieldFocused: Bool
    @FocusState private var ageFieldFocused: Bool

    enum InputPhase {
        case typing, enteringName, enteringAge, complete
    }

    private let systemLines = [
        "> SYSTEM BREACH DETECTED",
        "> WAKE UP.",
        "> Identify yourself."
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Status bar
            HStack {
                Text("[ CONNECTION: UNSECURE ]")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.agentRed)
                    .matrixGlow()
                Spacer()
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.xl)
            .padding(.bottom, Spacing.lg)

            // Terminal text
            VStack(alignment: .leading, spacing: Spacing.sm) {
                ForEach(displayedLines, id: \.self) { line in
                    Text(line)
                        .font(.system(size: 20, weight: .medium, design: .monospaced))
                        .foregroundColor(Color.matrixGreen)
                        .matrixGlow()
                }

                if phase == .typing && (!currentTypingLine.isEmpty || showCursor) {
                    Text(currentTypingLine + (showCursor ? "█" : " "))
                        .font(.system(size: 20, weight: .medium, design: .monospaced))
                        .foregroundColor(Color.matrixGreen)
                        .matrixGlow()
                }

                // Name Input
                if phase == .enteringName || phase == .enteringAge || phase == .complete {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("> USERNAME:")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.matrixGreen)
                            .matrixGlow()

                        TextField("", text: $operatorName)
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()
                            .focused($nameFieldFocused)
                            .disabled(phase != .enteringName)
                            .padding(.vertical, Spacing.sm)
                            .padding(.horizontal, Spacing.md)
                            .background(Color.charcoal)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.matrixGreen, lineWidth: 2)
                                    .shadow(color: Color.matrixGreen.opacity(0.5), radius: 4)
                            )
                            .onSubmit { handleNameSubmit() }
                    }
                    .padding(.top, Spacing.lg)
                }

                // Age Input
                if phase == .enteringAge || phase == .complete {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("> AGE:")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.matrixGreen)
                            .matrixGlow()

                        TextField("", text: $operatorAge)
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .keyboardType(.numberPad)
                            .autocorrectionDisabled()
                            .focused($ageFieldFocused)
                            .disabled(phase == .complete)
                            .padding(.vertical, Spacing.sm)
                            .padding(.horizontal, Spacing.md)
                            .background(Color.charcoal)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.matrixGreen, lineWidth: 2)
                                    .shadow(color: Color.matrixGreen.opacity(0.5), radius: 4)
                            )
                            .onChange(of: operatorAge) { _, newValue in
                                let filtered = newValue.filter { $0.isNumber }
                                if filtered != newValue { operatorAge = filtered }
                                if filtered.count > 2 { operatorAge = String(filtered.prefix(2)) }
                            }
                    }
                    .padding(.top, Spacing.md)
                }

                // Response text
                if phase == .complete {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("> \(operatorAge) YEARS... CALCULATING WASTED CYCLES...")
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundColor(Color.mediumGray)
                    }
                    .padding(.top, Spacing.md)
                }
            }
            .padding(.horizontal, Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            // Continue Button - shows after name entered
            if showContinue {
                PrimaryButton(title: "CONTINUE_") {
                    if phase == .enteringName {
                        handleNameSubmit()
                    } else if phase == .enteringAge && !operatorAge.isEmpty {
                        handleAgeSubmit()
                    } else if phase == .complete {
                        onComplete()
                    }
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.xxl)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showContinue)
        .onAppear {
            startTypingSequence()
            startCursorBlink()
        }
    }

    private func startTypingSequence() {
        typeLines(systemLines) {
            phase = .enteringName
            showContinue = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { nameFieldFocused = true }
        }
    }

    private func typeLines(_ lines: [String], completion: @escaping () -> Void) {
        var lineIndex = 0
        func typeLine() {
            guard lineIndex < lines.count else { completion(); return }
            let line = lines[lineIndex]
            var charIndex = 0
            currentTypingLine = ""
            Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { timer in
                if charIndex < line.count {
                    let index = line.index(line.startIndex, offsetBy: charIndex)
                    currentTypingLine += String(line[index])
                    charIndex += 1
                } else {
                    timer.invalidate()
                    displayedLines.append(currentTypingLine)
                    currentTypingLine = ""
                    lineIndex += 1
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { typeLine() }
                }
            }
        }
        typeLine()
    }

    private func startCursorBlink() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in showCursor.toggle() }
    }

    private func handleNameSubmit() {
        guard !operatorName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        phase = .enteringAge
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { ageFieldFocused = true }
    }

    private func handleAgeSubmit() {
        guard !operatorAge.isEmpty else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        ageFieldFocused = false
        phase = .complete
    }
}

// MARK: - Phase 1: Hook Question

struct HookQuestionPhase: View {
    @Binding var answer: Bool?
    let onComplete: () -> Void

    @State private var showContent: Bool = false

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            if showContent {
                VStack(spacing: Spacing.lg) {
                    Text("DIAGNOSTIC 1/10")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.mediumGray)

                    Text("MORPHEUS:")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.matrixGreen)
                        .matrixGlow()

                    Text("Do you feel like you are living below your potential?")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.lg)

                    VStack(spacing: Spacing.md) {
                        DiagnosticButton(title: "YES", isSelected: answer == true) {
                            answer = true
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }
                        DiagnosticButton(title: "NO", isSelected: answer == false) {
                            answer = false
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }
                    }
                    .padding(.horizontal, Spacing.xl)
                }
                .transition(.opacity)
            }

            Spacer()

            if answer != nil {
                PrimaryButton(title: "CONTINUE_") { onComplete() }
                    .padding(.horizontal, Spacing.xl)
                    .padding(.bottom, Spacing.xxl)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation { showContent = true }
            }
        }
    }
}

// MARK: - Phase 2: Problem Selection

struct ProblemSelectionPhase: View {
    @Binding var selectedProblems: Set<ModernProblem>
    let onComplete: () -> Void

    @State private var showContent: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            if showContent {
                VStack(spacing: Spacing.sm) {
                    Text("DIAGNOSTIC 2/10")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.mediumGray)
                        .padding(.top, Spacing.xl)

                    Text("SYSTEM:")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.agentRed)

                    Text("Detecting control programs...")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)

                    Text("Select all that apply")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(Color.mediumGray)
                }
                .padding(.bottom, Spacing.md)

                ScrollView {
                    VStack(spacing: Spacing.sm) {
                        ForEach(ModernProblem.allCases) { problem in
                            ProblemCard(
                                problem: problem,
                                isSelected: selectedProblems.contains(problem)
                            ) {
                                toggleProblem(problem)
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.bottom, Spacing.lg)
                }
            }

            if !selectedProblems.isEmpty {
                PrimaryButton(title: "ACKNOWLEDGE CHAINS_", color: Color.agentRed) { onComplete() }
                    .padding(.horizontal, Spacing.xl)
                    .padding(.bottom, Spacing.xxl)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation { showContent = true }
            }
        }
    }

    private func toggleProblem(_ problem: ModernProblem) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if problem == .allAbove {
            if selectedProblems.contains(.allAbove) {
                selectedProblems.removeAll()
            } else {
                selectedProblems = Set(ModernProblem.allCases)
            }
        } else {
            if selectedProblems.contains(problem) {
                selectedProblems.remove(problem)
                selectedProblems.remove(.allAbove)
            } else {
                selectedProblems.insert(problem)
            }
        }
    }
}

struct ProblemCard: View {
    let problem: ModernProblem
    let isSelected: Bool
    let action: () -> Void

    @State private var jitterOffset: CGFloat = 0

    var body: some View {
        Button(action: {
            // Jitter animation
            withAnimation(.easeInOut(duration: 0.05)) { jitterOffset = 4 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation(.easeInOut(duration: 0.05)) { jitterOffset = -2 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.05)) { jitterOffset = 0 }
            }
            action()
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(problem.rawValue.uppercased())
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(isSelected ? Color.agentRed : .white)
                    Text(problem.description)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color.lightGray)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color.agentRed)
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 18))
                        .foregroundColor(Color.mediumGray)
                }
            }
            .padding(Spacing.md)
            .background(Color.charcoal)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.agentRed : Color.mediumGray.opacity(0.5), lineWidth: isSelected ? 2 : 1)
                    .shadow(color: isSelected ? Color.agentRed.opacity(0.4) : .clear, radius: 4)
            )
        }
        .offset(x: jitterOffset, y: -jitterOffset / 2)
    }
}

// MARK: - Phase 3: Years Deleted

struct YearsDeletedPhase: View {
    let age: Int
    @Binding var hoursLost: Int
    let onComplete: () -> Void

    @State private var showContent: Bool = false
    @State private var showResult: Bool = false
    @State private var animatedYears: Double = 0

    private var percentOfLife: Int {
        Int((Double(hoursLost) / 16.0) * 100)
    }

    private var yearsDeleted: Double {
        let remainingYears = Double(80 - age)
        return (Double(hoursLost) / 16.0) * remainingYears
    }

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            if showContent && !showResult {
                VStack(spacing: Spacing.lg) {
                    Text("DIAGNOSTIC 3/10")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.mediumGray)

                    Text("How many hours do you lose to these loops daily?")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.lg)

                    Text("\(hoursLost) HOURS")
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.agentRed)
                        .shadow(color: Color.agentRed.opacity(0.5), radius: 8)

                    Slider(value: Binding(
                        get: { Double(hoursLost) },
                        set: { hoursLost = Int($0) }
                    ), in: 1...8, step: 1)
                    .accentColor(Color.agentRed)
                    .padding(.horizontal, Spacing.xl)

                    HStack {
                        Text("1 hr").font(.system(size: 12, design: .monospaced)).foregroundColor(Color.mediumGray)
                        Spacer()
                        Text("8 hrs").font(.system(size: 12, design: .monospaced)).foregroundColor(Color.mediumGray)
                    }
                    .padding(.horizontal, Spacing.xl)

                    PrimaryButton(title: "CALCULATE DAMAGE", color: Color.agentRed) {
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        withAnimation { showResult = true }
                        animateYears()
                    }
                    .padding(.horizontal, Spacing.xl)
                }
                .transition(.opacity)
            }

            if showResult {
                VStack(spacing: Spacing.lg) {
                    Text("You are awake ~16 hours a day.")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(Color.mediumGray)

                    Text("\(hoursLost) hours = \(percentOfLife)% of your waking life")
                        .font(.system(size: 15, weight: .medium, design: .monospaced))
                        .foregroundColor(Color.lightGray)

                    VStack(spacing: Spacing.sm) {
                        Text("LOST POTENTIAL:")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.agentRed)

                        Text(String(format: "%.1f", animatedYears))
                            .font(.system(size: 80, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.agentRed)
                            .shadow(color: Color.agentRed.opacity(0.6), radius: 10)

                        Text("YEARS")
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.agentRed)

                        Text("by age 80")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(Color.mediumGray)
                    }

                    Text("Imagine what you could build in \(Int(yearsDeleted)) years.")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(Color.matrixGreen)
                        .matrixGlow()
                        .padding(.top, Spacing.md)
                }
                .transition(.opacity.combined(with: .scale))
            }

            Spacer()

            if showResult {
                PrimaryButton(title: "I AM ANGRY", color: Color.agentRed) { onComplete() }
                    .padding(.horizontal, Spacing.xl)
                    .padding(.bottom, Spacing.xxl)
                    .scaleEffect(1.0)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: showResult)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation { showContent = true }
            }
        }
    }

    private func animateYears() {
        let target = yearsDeleted
        let duration: Double = 2.0
        let steps = 40
        for i in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration * Double(i) / Double(steps)) {
                animatedYears = target * Double(i) / Double(steps)
            }
        }
    }
}

// MARK: - Phase 4: Broken Promises (Integrity)

struct BrokenPromisesPhase: View {
    @Binding var answer: BrokenPromisesOption?
    let onComplete: () -> Void

    @State private var showContent: Bool = false

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            if showContent {
                VStack(spacing: Spacing.lg) {
                    Text("DIAGNOSTIC 4/10")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.mediumGray)

                    Text("MORPHEUS:")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.matrixGreen)
                        .matrixGlow()

                    Text("How often do you break promises you make to yourself?")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.lg)

                    Text("If you can't trust yourself, who can?")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(Color.mediumGray)
                        .italic()

                    VStack(spacing: Spacing.sm) {
                        ForEach(BrokenPromisesOption.allCases, id: \.self) { option in
                            DiagnosticButton(title: option.rawValue.uppercased(), isSelected: answer == option) {
                                answer = option
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.xl)
                }
                .transition(.opacity)
            }

            Spacer()

            if answer != nil {
                PrimaryButton(title: "CONTINUE_") { onComplete() }
                    .padding(.horizontal, Spacing.xl)
                    .padding(.bottom, Spacing.xxl)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation { showContent = true }
            }
        }
    }
}

// MARK: - Phase 5: Post-Scroll Emotion

struct PostScrollEmotionPhase: View {
    @Binding var answer: ScrollEmotion?
    let onComplete: () -> Void

    @State private var showContent: Bool = false

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            if showContent {
                VStack(spacing: Spacing.lg) {
                    Text("DIAGNOSTIC 5/10")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.mediumGray)

                    Text("SYSTEM:")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.agentRed)

                    Text("What is your primary emotion after a long scrolling session?")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.lg)

                    VStack(spacing: Spacing.sm) {
                        ForEach(ScrollEmotion.allCases, id: \.self) { emotion in
                            DiagnosticButton(title: emotion.rawValue.uppercased(), isSelected: answer == emotion) {
                                answer = emotion
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.xl)
                }
                .transition(.opacity)
            }

            Spacer()

            if answer != nil {
                PrimaryButton(title: "CONTINUE_") { onComplete() }
                    .padding(.horizontal, Spacing.xl)
                    .padding(.bottom, Spacing.xxl)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation { showContent = true }
            }
        }
    }
}

// MARK: - Phase 6: Neglected Dream

struct NeglectedDreamPhase: View {
    @Binding var answer: DreamCategory?
    let onComplete: () -> Void

    @State private var showContent: Bool = false

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            if showContent {
                VStack(spacing: Spacing.lg) {
                    Text("DIAGNOSTIC 6/10")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.mediumGray)

                    Text("MORPHEUS:")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.matrixGreen)
                        .matrixGlow()

                    Text("What is the one dream you are neglecting right now?")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.lg)

                    VStack(spacing: Spacing.sm) {
                        ForEach(DreamCategory.allCases, id: \.self) { dream in
                            DiagnosticButton(title: dream.rawValue.uppercased(), isSelected: answer == dream) {
                                answer = dream
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.xl)
                }
                .transition(.opacity)
            }

            Spacer()

            if answer != nil {
                PrimaryButton(title: "CONTINUE_") { onComplete() }
                    .padding(.horizontal, Spacing.xl)
                    .padding(.bottom, Spacing.xxl)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation { showContent = true }
            }
        }
    }
}

// MARK: - Phase 7: Mental Clarity

struct MentalClarityPhase: View {
    @Binding var clarity: Double
    let onComplete: () -> Void

    @State private var showContent: Bool = false

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            if showContent {
                VStack(spacing: Spacing.lg) {
                    Text("DIAGNOSTIC 7/10")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.mediumGray)

                    Text("SYSTEM:")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.agentRed)

                    Text("How would you rate your mental clarity right now?")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.lg)

                    Text("\(Int(clarity))/10")
                        .font(.system(size: 56, weight: .bold, design: .monospaced))
                        .foregroundColor(clarity < 5 ? Color.agentRed : Color.matrixGreen)
                        .shadow(color: (clarity < 5 ? Color.agentRed : Color.matrixGreen).opacity(0.5), radius: 8)

                    Slider(value: $clarity, in: 1...10, step: 1)
                        .accentColor(clarity < 5 ? Color.agentRed : Color.matrixGreen)
                        .padding(.horizontal, Spacing.xl)

                    HStack {
                        Text("BRAIN FOG")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.agentRed)
                        Spacer()
                        Text("CRYSTAL CLEAR")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.matrixGreen)
                    }
                    .padding(.horizontal, Spacing.xl)
                }
                .transition(.opacity)
            }

            Spacer()

            PrimaryButton(title: "CONTINUE_") { onComplete() }
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.xxl)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation { showContent = true }
            }
        }
    }
}

// MARK: - Phase 8: Screen Over Person (Relationship)

struct ScreenOverPersonPhase: View {
    @Binding var answer: Bool?
    let onComplete: () -> Void

    @State private var showContent: Bool = false

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            if showContent {
                VStack(spacing: Spacing.lg) {
                    Text("DIAGNOSTIC 8/10")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.mediumGray)

                    Text("MORPHEUS:")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.matrixGreen)
                        .matrixGlow()

                    Text("Have you ever chosen a screen over a real person sitting next to you?")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.lg)

                    VStack(spacing: Spacing.md) {
                        DiagnosticButton(title: "YES", isSelected: answer == true) {
                            answer = true
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }
                        DiagnosticButton(title: "NO", isSelected: answer == false) {
                            answer = false
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }
                    }
                    .padding(.horizontal, Spacing.xl)
                }
                .transition(.opacity)
            }

            Spacer()

            if answer != nil {
                PrimaryButton(title: "CONTINUE_") { onComplete() }
                    .padding(.horizontal, Spacing.xl)
                    .padding(.bottom, Spacing.xxl)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation { showContent = true }
            }
        }
    }
}

// MARK: - Phase 9: Motivation Check

struct MotivationCheckPhase: View {
    @Binding var answer: MotivationType?
    let onComplete: () -> Void

    @State private var showContent: Bool = false

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            if showContent {
                VStack(spacing: Spacing.lg) {
                    Text("DIAGNOSTIC 9/10")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.mediumGray)

                    Text("SYSTEM:")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.agentRed)

                    Text("Are you doing this for yourself, or because you feel you 'should'?")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.lg)

                    VStack(spacing: Spacing.md) {
                        DiagnosticButton(title: "FOR MYSELF", isSelected: answer == .myself) {
                            answer = .myself
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }
                        DiagnosticButton(title: "BECAUSE I SHOULD", isSelected: answer == .should) {
                            answer = .should
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }
                    }
                    .padding(.horizontal, Spacing.xl)
                }
                .transition(.opacity)
            }

            Spacer()

            if answer != nil {
                PrimaryButton(title: "CONTINUE_") { onComplete() }
                    .padding(.horizontal, Spacing.xl)
                    .padding(.bottom, Spacing.xxl)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation { showContent = true }
            }
        }
    }
}

// MARK: - Phase 10: Year Projection (365 Days)

struct YearProjectionPhase: View {
    @Binding var answer: YearProjectionOption?
    let onComplete: () -> Void

    @State private var showContent: Bool = false

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            if showContent {
                VStack(spacing: Spacing.lg) {
                    Text("DIAGNOSTIC 10/10")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.mediumGray)

                    Text("MORPHEUS:")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.matrixGreen)
                        .matrixGlow()

                    Text("If you repeat your actions from today for 365 days, where will you be?")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.lg)

                    VStack(spacing: Spacing.md) {
                        ForEach(YearProjectionOption.allCases, id: \.self) { option in
                            DiagnosticButton(title: option.rawValue.uppercased(), isSelected: answer == option) {
                                answer = option
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.xl)
                }
                .transition(.opacity)
            }

            Spacer()

            if answer != nil {
                PrimaryButton(title: "CONTINUE_") { onComplete() }
                    .padding(.horizontal, Spacing.xl)
                    .padding(.bottom, Spacing.xxl)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation { showContent = true }
            }
        }
    }
}

// MARK: - Phase 11: Red/Blue Pill

struct RedBluePillPhase: View {
    @Binding var choseRedPill: Bool
    let onRedPill: () -> Void
    let onBluePill: () -> Void

    @State private var showContent: Bool = false
    @State private var selectedPill: String? = nil
    @State private var dimScreen: Bool = false
    @State private var showExitText: Bool = false

    var body: some View {
        ZStack {
            // Pure black background - no code rain
            Color.black.ignoresSafeArea()

            // Dim overlay for blue pill
            if dimScreen {
                Color.black.opacity(0.8)
                    .ignoresSafeArea()
                    .transition(.opacity)
            }

            VStack(spacing: Spacing.xxl) {
                Spacer()

                if showContent && !showExitText {
                    VStack(spacing: Spacing.lg) {
                        Text("THE CHOICE")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.matrixGreen)
                            .matrixGlow()

                        Text("The truth is not comfortable.")
                            .font(.system(size: 16, weight: .medium, design: .monospaced))
                            .foregroundColor(.white)

                        Text("Growth requires the destruction of who you are now.")
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(Color.mediumGray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Spacing.lg)

                        Text("You have a choice.")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(.top, Spacing.md)
                    }
                    .transition(.opacity)
                }

                Spacer()

                if showContent && !showExitText {
                    HStack(spacing: Spacing.xl) {
                        // Blue Pill
                        AwakeningPillButton(
                            color: .blue,
                            title: "STAY ASLEEP",
                            subtitle: "I'll change later.",
                            isSelected: selectedPill == "blue"
                        ) {
                            selectBluePill()
                        }

                        // Red Pill
                        AwakeningPillButton(
                            color: .red,
                            title: "WAKE UP",
                            subtitle: "I accept the pain.",
                            isSelected: selectedPill == "red"
                        ) {
                            selectRedPill()
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                    .transition(.opacity.combined(with: .scale))
                }

                if showExitText {
                    Text("The Matrix will always be here waiting for you.")
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundColor(Color.blue.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .transition(.opacity)
                }

                Spacer()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeIn(duration: 0.8)) { showContent = true }
            }
        }
    }

    private func selectRedPill() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        selectedPill = "red"
        choseRedPill = true

        // Flash white and proceed
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            onRedPill()
        }
    }

    private func selectBluePill() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        selectedPill = "blue"

        withAnimation(.easeOut(duration: 1.0)) {
            dimScreen = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation { showExitText = true; showContent = false }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            onBluePill()
        }
    }
}

struct AwakeningPillButton: View {
    let color: Color
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void

    @State private var isPulsing: Bool = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.md) {
                // Pill shape
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 80, height: 40)
                    .shadow(color: color.opacity(0.8), radius: isSelected ? 20 : 12)
                    .scaleEffect(isSelected ? 1.1 : (isPulsing ? 1.03 : 1.0))

                Text(title)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(color)

                Text(subtitle)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(Color.mediumGray)
            }
            .padding(Spacing.md)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}

// MARK: - Phase 12: Solution Protocol

struct SolutionProtocolPhase: View {
    @Binding var loadout: ProtocolLoadout
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
                if showContent {
                    VStack(spacing: Spacing.sm) {
                        Text("YOUR PROTOCOL")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.matrixGreen)
                            .matrixGlow()
                            .padding(.top, Spacing.xl)

                        Text("> INITIALIZING LOADOUT...")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(Color.mediumGray)
                    }
                }

                // HACKS Section (Green - things to DO)
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

                // AGENTS Section (Red - things to RESIST)
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

                // Customization note
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
        // Reveal hacks first
        for i in 0..<loadout.hacks.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6 + Double(i) * 0.4) {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                withAnimation { revealedHacks = i + 1 }
            }
        }

        // Then reveal agents
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

                Text(hack.whyItWorks)
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

// MARK: - Phase 13: Contract

struct ContractPhase: View {
    let onComplete: () -> Void

    @State private var showText: Bool = false
    @State private var showScanner: Bool = false
    @State private var holdProgress: CGFloat = 0
    @State private var isHolding: Bool = false
    @State private var showFlash: Bool = false
    @State private var showFinalText: Bool = false

    private let holdDuration: Double = 3.0

    var body: some View {
        ZStack {
            CodeRainBackground(opacity: 0.2 + Double(holdProgress) * 0.4, speed: 0.5 + Double(holdProgress) * 3.0)
                .ignoresSafeArea()

            VStack(spacing: Spacing.xxl) {
                Spacer()

                if showText {
                    VStack(spacing: Spacing.md) {
                        Text("THE CONTRACT")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.matrixGreen)
                            .matrixGlow()

                        Text("This is the Red Pill.")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)

                        Text("There is no turning back.")
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundColor(Color.lightGray)
                    }
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)
                    .transition(.opacity)
                }

                Spacer()

                if showScanner {
                    VStack(spacing: Spacing.lg) {
                        ZStack {
                            Circle()
                                .stroke(Color.matrixGreen.opacity(0.3), lineWidth: 4)
                                .frame(width: 150, height: 150)
                            Circle()
                                .trim(from: 0, to: holdProgress)
                                .stroke(Color.matrixGreen, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                .frame(width: 150, height: 150)
                                .rotationEffect(.degrees(-90))
                                .shadow(color: Color.matrixGreen.opacity(0.6), radius: 8)
                            Circle()
                                .fill(Color.charcoal)
                                .frame(width: 130, height: 130)
                            Image(systemName: "touchid")
                                .font(.system(size: 50))
                                .foregroundColor(holdProgress > 0 ? Color.matrixGreen : Color.mediumGray)
                        }
                        .scaleEffect(isHolding ? 0.95 : 1.0)
                        .animation(.easeInOut(duration: 0.1), value: isHolding)
                        .gesture(DragGesture(minimumDistance: 0).onChanged { _ in startHold() }.onEnded { _ in endHold() })

                        Text("> HOLD TO DISCONNECT FROM SIMULATION")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(Color.mediumGray)
                    }
                    .transition(.opacity.combined(with: .scale))
                }

                Spacer()
            }

            if showFlash { Color.white.ignoresSafeArea().transition(.opacity) }

            if showFinalText {
                Text("WELCOME TO THE DESERT OF THE REAL.")
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.matrixGreen)
                    .matrixGlow()
                    .multilineTextAlignment(.center)
                    .transition(.opacity)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { withAnimation { showText = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { withAnimation { showScanner = true } }
        }
    }

    private func startHold() {
        guard !isHolding && holdProgress < 1.0 else { return }
        isHolding = true
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation(.linear(duration: holdDuration)) { holdProgress = 1.0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + holdDuration) { if isHolding { completeContract() } }
        for i in 1...10 {
            DispatchQueue.main.asyncAfter(deadline: .now() + holdDuration * Double(i) / 10.0) {
                guard isHolding else { return }
                UIImpactFeedbackGenerator(style: i < 5 ? .light : (i < 8 ? .medium : .heavy)).impactOccurred()
            }
        }
    }

    private func endHold() {
        guard holdProgress < 1.0 else { return }
        isHolding = false
        withAnimation(.easeOut(duration: 0.3)) { holdProgress = 0 }
    }

    private func completeContract() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        withAnimation(.easeIn(duration: 0.1)) { showFlash = true; showText = false; showScanner = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { withAnimation(.easeOut(duration: 0.3)) { showFlash = false } }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { withAnimation { showFinalText = true } }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { onComplete() }
    }
}

// MARK: - Shared Components

struct DiagnosticButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(isSelected ? Color.deepBlack : .white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(isSelected ? Color.matrixGreen : Color.charcoal)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.matrixGreen : Color.mediumGray.opacity(0.5), lineWidth: 1)
                        .shadow(color: isSelected ? Color.matrixGreen.opacity(0.4) : .clear, radius: 4)
                )
        }
    }
}

#Preview {
    AwakeningView(isPresented: .constant(true))
        .modelContainer(for: [Power.self, Agent.self, CheckIn.self], inMemory: true)
}

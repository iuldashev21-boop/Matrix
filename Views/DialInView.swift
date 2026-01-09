import SwiftUI
import SwiftData

struct DialInView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allPowers: [Power]
    @Query private var allAgents: [Agent]

    var power: Power? = nil
    var agent: Agent? = nil

    @StateObject private var achievementManager = AchievementManager()

    // MARK: - State
    @State private var holdProgress: CGFloat = 0
    @State private var showAchievementToast: Bool = false
    @State private var isHolding: Bool = false
    @State private var isCompleted: Bool = false
    @State private var showShockwave: Bool = false
    @State private var shockwaveScale: CGFloat = 0
    @State private var shockwaveOpacity: Double = 1
    @State private var showOracleReward: Bool = false
    @State private var codeRainSpeed: Double = 0.3
    @State private var glitchOffset: CGSize = .zero
    @State private var showEMPRecovery: Bool = false
    @State private var showBreachConfirm: Bool = false
    @State private var showBreachMessage: Bool = false
    @State private var breachComplete: Bool = false

    // MARK: - Constants
    private let holdDuration: Double = 1.5
    private let oracleChance: Double = 0.20

    private var title: String {
        power?.name ?? agent?.name ?? "Unknown"
    }

    private var isPower: Bool {
        power != nil
    }

    private var currentStreak: Int {
        power?.currentStreak ?? agent?.currentStreak ?? 0
    }

    private var isAlreadyCompleted: Bool {
        if let p = power { return p.completedToday }
        if let a = agent { return a.resistedToday || a.relapsedToday }
        return false
    }

    private var hasRelapsedToday: Bool {
        agent?.relapsedToday ?? false
    }

    private var needsRecovery: Bool {
        if let p = power { return p.needsRecovery }
        if let a = agent { return a.needsRecovery }
        return false
    }

    private var accentColor: Color {
        isPower ? Color.matrixGreen : Color.agentRed
    }

    private var statusText: String {
        if isCompleted { return "SIGNAL LOCKED" }
        if breachComplete || hasRelapsedToday { return "BREACH LOGGED" }
        if isHolding { return "UPLOADING..." }
        if isAlreadyCompleted { return "ALREADY SYNCED" }
        return "HOLD TO SYNC"
    }

    var body: some View {
        ZStack {
            // Background
            Color.matrixBlack
                .ignoresSafeArea()

            // Dynamic code rain (accelerates during hold)
            CodeRainBackground(opacity: 0.15 + (holdProgress * 0.3), speed: codeRainSpeed)
                .ignoresSafeArea()

            // Shockwave effect
            if showShockwave {
                Circle()
                    .stroke(accentColor, lineWidth: 10)
                    .scaleEffect(shockwaveScale)
                    .opacity(shockwaveOpacity)
            }

            VStack(spacing: Spacing.xl) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(accentColor)
                    }
                    Spacer()

                    // Day counter
                    Text("DAY \(currentStreak)")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(accentColor)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.xs)
                        .background(Color.darkGray)
                        .cornerRadius(8)
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.lg)

                Spacer()

                // Title
                Text(title.uppercased())
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .offset(glitchOffset)

                Text(isPower ? "HACK ACTIVE" : "AGENT DETECTED")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(Color.mediumGray)

                Spacer()

                // Status text
                Text(statusText)
                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                    .foregroundColor(isCompleted ? accentColor : Color.lightGray)
                    .offset(glitchOffset)

                // Dial-In Button
                ZStack {
                    // Background circle
                    Circle()
                        .stroke(Color.darkGray, lineWidth: 4)
                        .frame(width: 140, height: 140)

                    // Progress ring
                    Circle()
                        .trim(from: 0, to: holdProgress)
                        .stroke(accentColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 140, height: 140)
                        .rotationEffect(.degrees(-90))

                    // Fill circle (shows on completion)
                    if isCompleted {
                        Circle()
                            .fill(accentColor)
                            .frame(width: 130, height: 130)
                    }

                    // Inner button
                    Circle()
                        .fill(isCompleted ? accentColor : Color.charcoal)
                        .frame(width: 120, height: 120)
                        .overlay(
                            Circle()
                                .stroke(accentColor.opacity(isHolding ? 0.8 : 0.3), lineWidth: 2)
                        )

                    // Icon
                    Image(systemName: isCompleted ? "checkmark" : "power")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundColor(isCompleted ? Color.deepBlack : accentColor)
                }
                .scaleEffect(isHolding ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isHolding)
                .gesture(
                    LongPressGesture(minimumDuration: 0.01)
                        .onChanged { _ in
                            if !isAlreadyCompleted && !isCompleted {
                                startHold()
                            }
                        }
                        .sequenced(before: DragGesture(minimumDistance: 0))
                        .onEnded { _ in
                            if !isCompleted {
                                cancelHold()
                            }
                        }
                )
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onEnded { _ in
                            if !isCompleted {
                                cancelHold()
                            }
                        }
                )
                .disabled(isAlreadyCompleted)
                .opacity(isAlreadyCompleted ? 0.5 : 1.0)

                Spacer()

                // XP earned indicator
                if isCompleted {
                    Text("+10 XP")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(accentColor)
                        .transition(.scale.combined(with: .opacity))
                }

                // Report Breach button (Agents only, hidden if already relapsed today)
                if !isPower && !isCompleted && !isAlreadyCompleted && !breachComplete && !hasRelapsedToday {
                    Button(action: { showBreachConfirm = true }) {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 14))
                            Text("REPORT BREACH")
                                .font(.system(size: 14, weight: .medium, design: .monospaced))
                        }
                        .foregroundColor(Color.danger)
                        .padding(.horizontal, Spacing.lg)
                        .padding(.vertical, Spacing.sm)
                        .background(Color.charcoal)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.danger.opacity(0.5), lineWidth: 1)
                        )
                    }
                    .padding(.top, Spacing.md)
                }

                Spacer()
            }

            // Oracle Reward Overlay
            if showOracleReward {
                OracleRewardView(isPresented: $showOracleReward)
                    .transition(.opacity)
            }

            // Breach Message Overlay
            if showBreachMessage {
                BreachMessageOverlay(isPresented: $showBreachMessage)
                    .transition(.opacity)
            }
        }
        .alert("CONFIRM BREACH", isPresented: $showBreachConfirm) {
            Button("CANCEL", role: .cancel) { }
            Button("CONFIRM", role: .destructive) {
                handleBreach()
            }
        } message: {
            Text("Reporting a breach will reset your current streak. Your longest streak will be preserved. Be honest with yourself.")
        }
        .onChange(of: isHolding) { _, holding in
            if holding {
                animateHold()
            }
        }
        .onAppear {
            // Check if recovery is needed
            if needsRecovery {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showEMPRecovery = true
                }
            }
        }
        .fullScreenCover(isPresented: $showEMPRecovery) {
            EMPRecoveryView(power: power, agent: agent)
        }
        .onAppear {
            achievementManager.setContext(modelContext)
        }
        .overlay {
            // Achievement unlock toast
            if showAchievementToast, let achievement = achievementManager.recentlyUnlocked {
                AchievementUnlockToast(
                    achievement: achievement,
                    isVisible: $showAchievementToast
                )
                .transition(.scale.combined(with: .opacity))
                .zIndex(100)
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showAchievementToast)
    }

    // MARK: - Hold Logic

    private func startHold() {
        guard !isHolding && !isCompleted else { return }
        isHolding = true

        // Start haptic
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        // Accelerate code rain dramatically
        withAnimation(.easeIn(duration: holdDuration)) {
            codeRainSpeed = 12.0
        }
    }

    private func animateHold() {
        // Animate progress
        withAnimation(.linear(duration: holdDuration)) {
            holdProgress = 1.0
        }

        // Continuous haptics during hold
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if !isHolding || isCompleted {
                timer.invalidate()
                return
            }
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred(intensity: 0.3 + (holdProgress * 0.7))
        }

        // Check for completion
        DispatchQueue.main.asyncAfter(deadline: .now() + holdDuration) {
            if isHolding && holdProgress >= 0.99 {
                completeCheckIn()
            }
        }
    }

    private func cancelHold() {
        isHolding = false

        withAnimation(.easeOut(duration: 0.3)) {
            holdProgress = 0
            codeRainSpeed = 0.3
        }
    }

    private func completeCheckIn() {
        isHolding = false
        isCompleted = true

        // Heavy haptic
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // Trigger shockwave
        triggerShockwave()

        // Glitch effect
        triggerGlitch()

        // Save check-in
        saveCheckIn()

        // Add XP
        UserProfile.addXP(10)

        // Check achievements
        checkAchievements()

        // Oracle reward chance
        if Double.random(in: 0...1) < oracleChance {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation {
                    showOracleReward = true
                }
            }
        }
    }

    private func checkAchievements() {
        // Calculate total check-ins
        let totalCheckIns = allPowers.flatMap { $0.checkIns }.count +
                           allAgents.flatMap { $0.checkIns }.count

        // Run achievement checks
        achievementManager.checkAchievementsAfterCheckIn(
            powers: allPowers,
            agents: allAgents,
            totalCheckIns: totalCheckIns
        )

        // Show toast if achievement unlocked
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if achievementManager.showUnlockAnimation {
                showAchievementToast = true
            }
        }
    }

    private func triggerShockwave() {
        showShockwave = true
        shockwaveScale = 0.5
        shockwaveOpacity = 1

        withAnimation(.easeOut(duration: 0.5)) {
            shockwaveScale = 4
            shockwaveOpacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showShockwave = false
        }
    }

    private func triggerGlitch() {
        GlitchEffect.triggerLight(offset: $glitchOffset)
    }

    private func saveCheckIn() {
        let checkIn = CheckIn(date: Date(), isSuccess: true)

        if let p = power {
            checkIn.power = p
            p.checkIns.append(checkIn)
            p.checkForUnlock()
        } else if let a = agent {
            checkIn.agent = a
            a.checkIns.append(checkIn)
            a.checkForDefeat()
        }

        modelContext.insert(checkIn)
        try? modelContext.save()
    }

    // MARK: - Breach Logic (Agent Relapse)

    private func handleBreach() {
        guard let a = agent else { return }

        // Log failed check-in
        let checkIn = CheckIn(date: Date(), isSuccess: false)
        checkIn.agent = a
        a.checkIns.append(checkIn)

        modelContext.insert(checkIn)
        try? modelContext.save()

        // Mark breach complete
        breachComplete = true

        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)

        // Glitch effect
        triggerGlitch()

        // Show encouraging message
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation {
                showBreachMessage = true
            }
        }
    }
}

// MARK: - Breach Message Overlay

struct BreachMessageOverlay: View {
    @Binding var isPresented: Bool
    @State private var glitchOffset: CGSize = .zero
    @State private var showContent: Bool = false

    private let encouragements = [
        "BREACH LOGGED.\nFIREWALL REBUILDING.\nDAY 1.",
        "AGENT INFILTRATION DETECTED.\nRESETTING DEFENSES.\nYOU ARE STILL IN CONTROL.",
        "SYSTEM COMPROMISED.\nINITIATING RECOVERY PROTOCOL.\nTHE FIGHT CONTINUES.",
        "THE MATRIX HAD YOU...\nBUT NOT FOR LONG.\nRECONNECTING TO ZION.",
        "SIGNAL LOST.\nREBOOTING RESISTANCE.\nEVERY DAY IS A NEW CHANCE.",
        "BREACH ACKNOWLEDGED.\nHONESTY IS STRENGTH.\nREBUILD STRONGER."
    ]

    private var randomEncouragement: String {
        encouragements.randomElement() ?? encouragements[0]
    }

    var body: some View {
        ZStack {
            // Dark overlay
            Color.black.opacity(0.9)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        isPresented = false
                    }
                }

            if showContent {
                VStack(spacing: Spacing.xl) {
                    // Warning icon
                    Image(systemName: "shield.slash")
                        .font(.system(size: 50))
                        .foregroundColor(Color.agentRed)
                        .offset(glitchOffset)

                    // Message
                    Text(randomEncouragement)
                        .font(.system(size: 18, weight: .medium, design: .monospaced))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.xl)
                        .offset(glitchOffset)

                    // Encouraging subtext
                    Text("Your longest streak is preserved.\nThis is not failure—it's data.")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(Color.mediumGray)
                        .multilineTextAlignment(.center)
                        .padding(.top, Spacing.sm)

                    // Dismiss button
                    Button(action: {
                        withAnimation {
                            isPresented = false
                        }
                    }) {
                        Text("CONTINUE")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.deepBlack)
                            .padding(.horizontal, Spacing.xl)
                            .padding(.vertical, Spacing.sm)
                            .background(Color.agentRed)
                            .cornerRadius(8)
                    }
                    .padding(.top, Spacing.md)
                }
            }
        }
        .onAppear {
            glitchIn()
        }
    }

    private func glitchIn() {
        // Initial glitch effect
        for i in 0..<8 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.03) {
                glitchOffset = CGSize(
                    width: CGFloat.random(in: -8...8),
                    height: CGFloat.random(in: -8...8)
                )
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(.easeOut(duration: 0.1)) {
                glitchOffset = .zero
                showContent = true
            }
        }
    }
}

// MARK: - Oracle Reward View

struct OracleRewardView: View {
    @Binding var isPresented: Bool
    @State private var glitchOffset: CGSize = .zero
    @State private var showContent: Bool = false

    private let quotes = [
        "\"There is no spoon.\"",
        "\"The Matrix cannot tell you who you are.\"",
        "\"You have to let it all go. Fear, doubt, disbelief.\"",
        "\"What you know you can't explain, but you feel it.\"",
        "\"I can only show you the door. You're the one that has to walk through it.\"",
        "\"The body cannot live without the mind.\"",
        "\"Free your mind.\"",
        "\"Everything begins with choice.\"",
        "\"You've been down there, Neo. You already know that road.\"",
        "\"Remember, all I'm offering is the truth. Nothing more.\""
    ]

    private var randomQuote: String {
        quotes.randomElement() ?? quotes[0]
    }

    var body: some View {
        ZStack {
            // Dark overlay
            Color.black.opacity(0.9)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        isPresented = false
                    }
                }

            if showContent {
                VStack(spacing: Spacing.xl) {
                    // Glitch header
                    Text("// GLITCH DETECTED")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.matrixGreen)
                        .offset(glitchOffset)

                    // Oracle icon
                    Image(systemName: "eye")
                        .font(.system(size: 50))
                        .foregroundColor(Color.matrixGreen)
                        .offset(glitchOffset)

                    // Quote
                    Text(randomQuote)
                        .font(.system(size: 18, weight: .medium, design: .monospaced))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.xl)
                        .offset(glitchOffset)

                    // Dismiss hint
                    Text("TAP TO CONTINUE")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(Color.mediumGray)
                        .padding(.top, Spacing.lg)
                }
            }
        }
        .onAppear {
            // Glitch in effect
            glitchIn()
        }
    }

    private func glitchIn() {
        // Initial glitch
        for i in 0..<8 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.03) {
                glitchOffset = CGSize(
                    width: CGFloat.random(in: -8...8),
                    height: CGFloat.random(in: -8...8)
                )
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(.easeOut(duration: 0.1)) {
                glitchOffset = .zero
                showContent = true
            }
        }
    }
}

#Preview {
    DialInView(power: nil, agent: nil)
        .modelContainer(for: [Power.self, Agent.self, CheckIn.self], inMemory: true)
}


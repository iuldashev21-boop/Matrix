import SwiftUI
import SwiftData

struct EMPRecoveryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var power: Power? = nil
    var agent: Agent? = nil

    // MARK: - State
    @State private var showDebrief: Bool = false
    @State private var debriefText: String = ""
    @State private var isBurning: Bool = false
    @State private var burnProgress: Double = 0
    @State private var showSuccess: Bool = false
    @State private var glitchOffset: CGSize = .zero
    @State private var showSaveError: Bool = false
    @State private var showNoTokensAlert: Bool = false
    @State private var empTokenCount: Int = UserProfile.empTokens

    private var title: String {
        power?.name ?? agent?.name ?? "Unknown"
    }

    private var isPower: Bool {
        power != nil
    }

    private var currentStreak: Int {
        power?.currentStreak ?? agent?.currentStreak ?? 0
    }

    private var hasTokens: Bool {
        empTokenCount > 0
    }

    var body: some View {
        ZStack {
            // Red tinted background
            Color.black.opacity(0.95)
                .ignoresSafeArea()

            // Red pulse overlay
            Color.danger.opacity(0.08)
                .ignoresSafeArea()

            // Glitch scanlines
            VStack(spacing: 4) {
                ForEach(0..<100, id: \.self) { _ in
                    Rectangle()
                        .fill(Color.danger.opacity(Double.random(in: 0.02...0.05)))
                        .frame(height: 2)
                }
            }
            .ignoresSafeArea()

            if showSuccess {
                // Success state
                successView
            } else if showDebrief {
                // Debrief input
                debriefView
            } else {
                // Main alert
                alertView
            }
        }
        .onAppear {
            triggerGlitch()
        }
        .alert("RECOVERY FAILED", isPresented: $showSaveError) {
            Button("RETRY") {
                // Retry will be handled by the action that triggered the error
            }
            Button("CANCEL", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("Failed to save recovery. Please try again.")
        }
        .alert("NO EMP TOKENS", isPresented: $showNoTokensAlert) {
            Button("UNDERSTOOD", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("You need EMP tokens to recover your streak. Earn tokens by reaching 7, 21, or 66 day milestones on any habit.")
        }
        .onAppear {
            empTokenCount = UserProfile.empTokens
        }
    }

    // MARK: - Alert View

    private var alertView: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            // Warning icon
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(Color.danger)
                .offset(glitchOffset)

            // Headline
            Text("SIGNAL CRITICAL")
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundColor(Color.danger)
                .offset(glitchOffset)

            // Habit name
            Text(title.uppercased())
                .font(.system(size: 18, weight: .medium, design: .monospaced))
                .foregroundColor(.white)

            // Body text
            VStack(spacing: Spacing.sm) {
                Text("AGENT INTERCEPTION DETECTED")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(Color.lightGray)

                Text("Signal strength compromised.")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(Color.mediumGray)

                Text("Execute Emergency Protocol?")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(Color.mediumGray)
            }
            .multilineTextAlignment(.center)
            .padding(.top, Spacing.md)

            // EMP Token Display
            HStack(spacing: Spacing.xs) {
                Image(systemName: "bolt.shield.fill")
                    .font(.system(size: 16))
                Text("\(empTokenCount) EMP TOKEN\(empTokenCount == 1 ? "" : "S") AVAILABLE")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
            }
            .foregroundColor(hasTokens ? .purple : Color.mediumGray)
            .padding(.top, Spacing.sm)

            Spacer()

            // Action buttons
            VStack(spacing: Spacing.md) {
                // Double workload button
                Button(action: {
                    if hasTokens {
                        handleDoubleWorkload()
                    } else {
                        showNoTokensAlert = true
                    }
                }) {
                    HStack {
                        Image(systemName: "bolt.fill")
                        Text("RE-INITIALIZE LINK")
                    }
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(hasTokens ? Color.danger : Color.mediumGray)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.cornerRadius)
                            .stroke(hasTokens ? Color.danger : Color.mediumGray, lineWidth: 2)
                    )
                }

                Text(hasTokens ? "(COSTS 1 EMP • 2X EFFORT TODAY)" : "(REQUIRES EMP TOKEN)")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(Color.mediumGray)

                // Debrief button
                Button(action: {
                    if hasTokens {
                        withAnimation { showDebrief = true }
                    } else {
                        showNoTokensAlert = true
                    }
                }) {
                    HStack {
                        Image(systemName: "doc.text")
                        Text("SUBMIT DEBRIEF LOG")
                    }
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(hasTokens ? Color.lightGray : Color.mediumGray.opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                }

                // Cancel
                Button(action: { dismiss() }) {
                    Text("ABORT RECOVERY")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(Color.mediumGray)
                }
                .padding(.top, Spacing.sm)
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, Spacing.xxl)
        }
    }

    // MARK: - Debrief View

    private var debriefView: some View {
        VStack(spacing: Spacing.lg) {
            // Header
            HStack {
                Button(action: { withAnimation { showDebrief = false } }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color.danger)
                }
                Spacer()
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.lg)

            Spacer()

            // Title
            Text("DEBRIEF LOG")
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundColor(Color.danger)

            Text("Record the interference for analysis.")
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(Color.mediumGray)

            // Text input
            ZStack {
                if isBurning {
                    // Burning text effect
                    Text(debriefText)
                        .font(.system(size: 16, design: .monospaced))
                        .foregroundColor(Color.danger.opacity(1 - burnProgress))
                        .blur(radius: burnProgress * 5)
                        .scaleEffect(1 + burnProgress * 0.2)
                } else {
                    TextEditor(text: $debriefText)
                        .font(.system(size: 16, design: .monospaced))
                        .foregroundColor(.white)
                        .scrollContentBackground(.hidden)
                        .background(Color.charcoal)
                        .cornerRadius(Theme.cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                                .stroke(Color.danger.opacity(0.5), lineWidth: 1)
                        )
                }
            }
            .frame(height: 150)
            .padding(.horizontal, Spacing.md)

            if !isBurning {
                Text("This log will be encrypted and purged.")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(Color.mediumGray)
            }

            Spacer()

            // Submit button
            if !debriefText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isBurning {
                Button(action: handleDebriefSubmit) {
                    HStack {
                        Image(systemName: "flame.fill")
                        Text("BURN & SUBMIT")
                    }
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.danger)
                    .cornerRadius(Theme.cornerRadius)
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.xxl)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: debriefText.isEmpty)
    }

    // MARK: - Success View

    private var successView: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            // Success icon
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 70))
                .foregroundColor(Color.warning)

            Text("LINK RE-ESTABLISHED")
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundColor(Color.warning)

            Text("Signal recovered with scar marker.")
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(Color.mediumGray)

            Text("DAY \(currentStreak) PRESERVED")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .padding(.top, Spacing.md)

            Spacer()

            Button(action: { dismiss() }) {
                Text("RETURN TO COMMAND CENTER")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.matrixGreen)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.cornerRadius)
                            .stroke(Color.matrixGreen, lineWidth: 1)
                    )
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, Spacing.xxl)
        }
    }

    // MARK: - Actions

    private func handleDoubleWorkload() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()

        if saveRecoveryCheckIn(note: "2X Effort Recovery") {
            withAnimation(.easeInOut(duration: 0.3)) {
                showSuccess = true
            }
        } else {
            showSaveError = true
        }
    }

    private func handleDebriefSubmit() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        // Start burn animation
        isBurning = true

        withAnimation(.easeIn(duration: 1.0)) {
            burnProgress = 1.0
        }

        // Save after burn completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            if saveRecoveryCheckIn(note: "Debrief: \(debriefText)") {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showSuccess = true
                }
            } else {
                isBurning = false
                burnProgress = 0
                showSaveError = true
            }
        }
    }

    private func saveRecoveryCheckIn(note: String) -> Bool {
        // Spend EMP token first
        guard UserProfile.spendEMPToken() else {
            return false
        }

        // Create a recovery check-in for yesterday
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        let checkIn = CheckIn(date: yesterday, isSuccess: true, note: note)

        if let p = power {
            checkIn.power = p
            p.checkIns.append(checkIn)
        } else if let a = agent {
            checkIn.agent = a
            a.checkIns.append(checkIn)
        }

        modelContext.insert(checkIn)
        do {
            try modelContext.save()
            // Award reduced XP for recovery
            UserProfile.addXP(5)
            // Update local token count
            empTokenCount = UserProfile.empTokens
            return true
        } catch {
            // Refund the token if save failed
            UserProfile.awardEMPTokens(1)
            empTokenCount = UserProfile.empTokens
            return false
        }
    }

    private func triggerGlitch() {
        GlitchEffect.triggerStandard(offset: $glitchOffset)
    }
}

#Preview {
    EMPRecoveryView(power: nil, agent: nil)
        .modelContainer(for: [Power.self, Agent.self, CheckIn.self], inMemory: true)
}


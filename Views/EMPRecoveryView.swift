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

    private var title: String {
        power?.name ?? agent?.name ?? "Unknown"
    }

    private var isPower: Bool {
        power != nil
    }

    private var currentStreak: Int {
        power?.currentStreak ?? agent?.currentStreak ?? 0
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

            Spacer()

            // Action buttons
            VStack(spacing: Spacing.md) {
                // Double workload button
                Button(action: handleDoubleWorkload) {
                    HStack {
                        Image(systemName: "bolt.fill")
                        Text("RE-INITIALIZE LINK")
                    }
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.danger)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.cornerRadius)
                            .stroke(Color.danger, lineWidth: 2)
                    )
                }

                Text("(2X EFFORT TODAY)")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(Color.mediumGray)

                // Debrief button
                Button(action: { withAnimation { showDebrief = true } }) {
                    HStack {
                        Image(systemName: "doc.text")
                        Text("SUBMIT DEBRIEF LOG")
                    }
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(Color.lightGray)
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

        saveRecoveryCheckIn(note: "2X Effort Recovery")

        withAnimation(.easeInOut(duration: 0.3)) {
            showSuccess = true
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
            saveRecoveryCheckIn(note: "Debrief: \(debriefText)")

            withAnimation(.easeInOut(duration: 0.3)) {
                showSuccess = true
            }
        }
    }

    private func saveRecoveryCheckIn(note: String) {
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
        try? modelContext.save()

        // Award reduced XP for recovery
        UserProfile.addXP(5)
    }

    private func triggerGlitch() {
        // Initial glitch effect
        for i in 0..<6 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.05) {
                glitchOffset = CGSize(
                    width: CGFloat.random(in: -6...6),
                    height: CGFloat.random(in: -6...6)
                )
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.1)) {
                glitchOffset = .zero
            }
        }
    }
}

#Preview {
    EMPRecoveryView(power: nil, agent: nil)
        .modelContainer(for: [Power.self, Agent.self, CheckIn.self], inMemory: true)
}

import SwiftUI
import SwiftData

struct FirstHackSetupView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isPresented: Bool

    // MARK: - State
    @State private var headerText: String = ""
    @State private var showContent: Bool = false
    @State private var selectedPreset: PresetHabit? = nil
    @State private var customHabitName: String = ""
    @State private var isUploading: Bool = false
    @State private var uploadProgress: Double = 0
    @State private var showSuccess: Bool = false
    @State private var navigateToDashboard: Bool = false

    // MARK: - Constants
    private let headerFullText = "> CONSTRUCT V1.0"
    private let presets: [PresetHabit] = [
        PresetHabit(name: "Morning Workout", icon: "figure.run", category: "Fitness"),
        PresetHabit(name: "Read 30 Minutes", icon: "book", category: "Learning"),
        PresetHabit(name: "Meditate", icon: "brain.head.profile", category: "Mindfulness"),
        PresetHabit(name: "Drink Water", icon: "drop.fill", category: "Health"),
        PresetHabit(name: "No Phone First Hour", icon: "iphone.slash", category: "Focus"),
        PresetHabit(name: "Journal", icon: "pencil.and.scribble", category: "Reflection")
    ]

    private var hasSelection: Bool {
        selectedPreset != nil || !customHabitName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var selectedHabitName: String {
        if let preset = selectedPreset {
            return preset.name
        }
        return customHabitName.trimmingCharacters(in: .whitespaces)
    }

    var body: some View {
        ZStack {
            // Background
            Color.matrixBlack
                .ignoresSafeArea()

            VStack(spacing: Spacing.lg) {
                // Back button + Header
                HStack {
                    Button(action: { isPresented = false }) {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .medium))
                            Text("BACK")
                                .font(.system(size: 14, weight: .medium, design: .monospaced))
                        }
                        .foregroundColor(Color.matrixGreen)
                    }
                    Spacer()
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.lg)

                // Header
                HStack {
                    Text(headerText + (showContent ? "" : "_"))
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundColor(Color.matrixGreen)
                    Spacer()
                }
                .padding(.horizontal, Spacing.md)

                if showContent {
                    // Subheader
                    Text("SUBJECT IDENTIFIED: OPERATIVE")
                        .font(.system(size: 14, weight: .regular, design: .monospaced))
                        .foregroundColor(Color.mediumGray)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))

                    Spacer().frame(height: Spacing.md)

                    // Instruction
                    Text("SELECT FIRST PROGRAM TO LOAD:")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))

                    // Preset Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.md) {
                        ForEach(presets) { preset in
                            PresetButton(
                                preset: preset,
                                isSelected: selectedPreset?.id == preset.id
                            ) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedPreset = preset
                                    customHabitName = ""
                                }
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.md)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))

                    // Divider
                    HStack {
                        Rectangle()
                            .fill(Color.mediumGray)
                            .frame(height: 1)
                        Text("OR")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(Color.mediumGray)
                        Rectangle()
                            .fill(Color.mediumGray)
                            .frame(height: 1)
                    }
                    .padding(.horizontal, Spacing.xl)
                    .padding(.vertical, Spacing.sm)

                    // Custom Input
                    TextField("", text: $customHabitName, prompt: Text("e.g. READ 10 PAGES").foregroundColor(Color.mediumGray))
                        .font(.system(size: 16, design: .monospaced))
                        .foregroundColor(Color.matrixGreen)
                        .padding()
                        .background(Color.charcoal)
                        .cornerRadius(Theme.cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                                .stroke(customHabitName.isEmpty ? Color.mediumGray : Color.matrixGreen, lineWidth: 1)
                        )
                        .padding(.horizontal, Spacing.md)
                        .onChange(of: customHabitName) { _, _ in
                            if !customHabitName.isEmpty {
                                selectedPreset = nil
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .bottom)))

                    Spacer()

                    // Upload Button
                    if hasSelection {
                        VStack(spacing: Spacing.md) {
                            if isUploading {
                                // Progress bar
                                VStack(spacing: Spacing.sm) {
                                    GeometryReader { geometry in
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color.darkGray)
                                                .frame(height: 8)

                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color.matrixGreen)
                                                .frame(width: geometry.size.width * uploadProgress, height: 8)
                                        }
                                    }
                                    .frame(height: 8)

                                    Text("UPLOADING PROGRAM...")
                                        .font(.system(size: 14, design: .monospaced))
                                        .foregroundColor(Color.matrixGreen)
                                }
                                .padding(.horizontal, Spacing.xl)
                            } else if showSuccess {
                                Text("PROGRAM UPLOADED.\nDAY 1 SEQUENCE INITIATED.")
                                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                                    .foregroundColor(Color.matrixGreen)
                                    .multilineTextAlignment(.center)
                            } else {
                                PrimaryButton(title: "UPLOAD TO CORE") {
                                    handleUpload()
                                }
                                .padding(.horizontal, Spacing.xl)
                            }
                        }
                        .transition(.opacity.combined(with: .scale))
                        .padding(.bottom, Spacing.xl)
                    }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: showContent)
            .animation(.easeInOut(duration: 0.2), value: hasSelection)
        }
        .onAppear {
            startTypingAnimation()
        }
        .fullScreenCover(isPresented: $navigateToDashboard) {
            MainAppView()
        }
    }

    // MARK: - Animations
    private func startTypingAnimation() {
        var charIndex = 0
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if charIndex < headerFullText.count {
                let index = headerFullText.index(headerFullText.startIndex, offsetBy: charIndex)
                headerText += String(headerFullText[index])
                charIndex += 1
            } else {
                timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        showContent = true
                    }
                }
            }
        }
    }

    // MARK: - Actions
    private func handleUpload() {
        let impact = UINotificationFeedbackGenerator()
        impact.notificationOccurred(.success)

        isUploading = true

        // Animate progress bar
        withAnimation(.easeInOut(duration: 0.5)) {
            uploadProgress = 1.0
        }

        // Create the habit
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            createHabit()

            withAnimation {
                isUploading = false
                showSuccess = true
            }

            // Navigate to dashboard
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                UserProfile.completeOnboarding()
                navigateToDashboard = true
            }
        }
    }

    private func createHabit() {
        let habitName = selectedHabitName
        let icon = selectedPreset?.icon ?? "bolt"

        let power = Power(name: habitName, icon: icon)
        modelContext.insert(power)

        try? modelContext.save()
    }
}

// MARK: - Preset Button Component

struct PresetButton: View {
    let preset: PresetHabit
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: preset.icon)
                    .font(.system(size: 18))

                Text(preset.name)
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundColor(isSelected ? Color.deepBlack : Color.matrixGreen)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(isSelected ? Color.matrixGreen : Color.clear)
            .cornerRadius(Theme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .stroke(Color.matrixGreen, lineWidth: 1)
            )
        }
    }
}

// MARK: - Main App View (Post-Onboarding)

struct MainAppView: View {
    var body: some View {
        CommandCenterView()
    }
}

#Preview {
    FirstHackSetupView(isPresented: .constant(true))
        .modelContainer(for: [Power.self, Agent.self, CheckIn.self], inMemory: true)
}


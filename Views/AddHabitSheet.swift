import SwiftUI
import SwiftData

// MARK: - Habit Suggestion Model

struct HabitSuggestion: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let scheduledDays: Set<Int>
    let frequencyLabel: String
}

// MARK: - Suggested Habits

private let hackSuggestions: [HabitSuggestion] = [
    HabitSuggestion(name: "Supplements", icon: "pill.fill", scheduledDays: Set(1...7), frequencyLabel: "Daily"),
    HabitSuggestion(name: "Gym", icon: "figure.strengthtraining.traditional", scheduledDays: Set([2, 4, 6]), frequencyLabel: "3x Week"),
    HabitSuggestion(name: "Meditation", icon: "brain.head.profile", scheduledDays: Set(1...7), frequencyLabel: "Daily"),
    HabitSuggestion(name: "Reading", icon: "book.fill", scheduledDays: Set(1...7), frequencyLabel: "Daily"),
    HabitSuggestion(name: "Hydration", icon: "drop.fill", scheduledDays: Set(1...7), frequencyLabel: "Daily"),
    HabitSuggestion(name: "Journaling", icon: "pencil.and.scribble", scheduledDays: Set(1...7), frequencyLabel: "Daily")
]

private let agentSuggestions: [HabitSuggestion] = [
    HabitSuggestion(name: "No Doom Scrolling", icon: "iphone", scheduledDays: Set(1...7), frequencyLabel: "Daily"),
    HabitSuggestion(name: "No Junk Food", icon: "fork.knife", scheduledDays: Set(1...7), frequencyLabel: "Daily"),
    HabitSuggestion(name: "No Late Nights", icon: "moon.zzz", scheduledDays: Set([2, 3, 4, 5, 6]), frequencyLabel: "Weekdays"),
    HabitSuggestion(name: "No Gaming", icon: "gamecontroller.fill", scheduledDays: Set([2, 3, 4, 5, 6]), frequencyLabel: "Weekdays"),
    HabitSuggestion(name: "No Excess Caffeine", icon: "cup.and.saucer.fill", scheduledDays: Set(1...7), frequencyLabel: "Daily"),
    HabitSuggestion(name: "No Binge Watching", icon: "tv.fill", scheduledDays: Set([2, 3, 4, 5, 6]), frequencyLabel: "Weekdays")
]

struct AddHabitSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var habitName: String = ""
    @State private var isAgent: Bool = false
    @State private var selectedIcon: String = "bolt"
    @State private var showSaveError: Bool = false
    @State private var selectedDays: Set<Int> = [] // Empty by default - user must choose
    @State private var isSaving: Bool = false

    private let maxNameLength = 30
    private let weekdays: [(id: Int, short: String)] = [
        (1, "S"), (2, "M"), (3, "T"), (4, "W"), (5, "T"), (6, "F"), (7, "S")
    ]

    private var suggestions: [HabitSuggestion] {
        isAgent ? agentSuggestions : hackSuggestions
    }

    private var trimmedName: String {
        habitName.trimmingCharacters(in: .whitespaces)
    }

    private var canUpload: Bool {
        let name = trimmedName
        return !name.isEmpty && name.count <= maxNameLength && !selectedDays.isEmpty && !isSaving
    }

    private var frequencyLabel: String {
        if selectedDays.isEmpty {
            return "SELECT SCHEDULE"
        } else if selectedDays.count == 7 {
            return "DAILY"
        } else if selectedDays == Set([2, 3, 4, 5, 6]) {
            return "WEEKDAYS"
        } else if selectedDays == Set([1, 7]) {
            return "WEEKENDS"
        } else {
            return "\(selectedDays.count) DAYS/WEEK"
        }
    }

    private let powerIcons = ["bolt", "figure.run", "book", "brain.head.profile", "drop.fill", "pencil.and.scribble"]
    private let agentIcons = ["xmark.shield", "iphone", "moon.zzz", "cup.and.saucer", "tv", "creditcard"]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.matrixBlack.ignoresSafeArea()

                VStack(spacing: Spacing.lg) {
                    // Type Toggle
                    HStack(spacing: Spacing.md) {
                        TypeToggleButton(title: "HACK", isSelected: !isAgent) {
                            isAgent = false
                            selectedIcon = "bolt"
                        }
                        TypeToggleButton(title: "AGENT", isSelected: isAgent) {
                            isAgent = true
                            selectedIcon = "xmark.shield"
                        }
                    }
                    .padding(.horizontal, Spacing.md)

                    // Quick Suggestions
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("QUICK ADD")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.lightGray)
                            .padding(.horizontal, Spacing.md)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Spacing.sm) {
                                ForEach(suggestions) { suggestion in
                                    SuggestionChip(
                                        suggestion: suggestion,
                                        accentColor: isAgent ? Color.agentRed : Color.matrixGreen
                                    ) {
                                        selectSuggestion(suggestion)
                                    }
                                }
                            }
                            .padding(.horizontal, Spacing.md)
                        }
                    }

                    // Divider
                    HStack {
                        Rectangle()
                            .fill(Color.charcoal)
                            .frame(height: 1)
                        Text("OR CREATE CUSTOM")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(Color.mediumGray)
                        Rectangle()
                            .fill(Color.charcoal)
                            .frame(height: 1)
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
                                        .cornerRadius(Theme.cornerRadiusCompact)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.md)

                    // Day Selection
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        HStack {
                            Text("FREQUENCY")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(Color.lightGray)
                            Text("*")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color.agentRed)
                        }

                        // Preset buttons
                        HStack(spacing: Spacing.sm) {
                            FrequencyPresetButton(title: "DAILY", isSelected: selectedDays.count == 7, accentColor: isAgent ? Color.agentRed : Color.matrixGreen) {
                                selectedDays = Set(1...7)
                            }
                            FrequencyPresetButton(title: "WEEKDAYS", isSelected: selectedDays == Set([2, 3, 4, 5, 6]), accentColor: isAgent ? Color.agentRed : Color.matrixGreen) {
                                selectedDays = Set([2, 3, 4, 5, 6])
                            }
                            FrequencyPresetButton(title: "CUSTOM", isSelected: !selectedDays.isEmpty && selectedDays.count != 7 && selectedDays != Set([2, 3, 4, 5, 6]), accentColor: isAgent ? Color.agentRed : Color.matrixGreen) {
                                // If already custom, keep it; otherwise start fresh
                                if selectedDays.count == 7 || selectedDays == Set([2, 3, 4, 5, 6]) {
                                    selectedDays = []
                                }
                            }
                        }

                        // Day picker (always visible for custom selection)
                        HStack(spacing: Spacing.xs) {
                            ForEach(weekdays, id: \.id) { day in
                                Button(action: {
                                    if selectedDays.contains(day.id) {
                                        selectedDays.remove(day.id)
                                    } else {
                                        selectedDays.insert(day.id)
                                    }
                                }) {
                                    Text(day.short)
                                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                                        .foregroundColor(selectedDays.contains(day.id) ? Color.deepBlack : Color.mediumGray)
                                        .frame(width: 36, height: 36)
                                        .background(selectedDays.contains(day.id) ? (isAgent ? Color.agentRed : Color.matrixGreen) : Color.charcoal)
                                        .cornerRadius(Theme.cornerRadiusCompact)
                                }
                            }
                        }

                        Text(frequencyLabel)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(selectedDays.isEmpty ? Color.agentRed : Color.mediumGray)
                    }
                    .padding(.horizontal, Spacing.md)

                    Spacer()

                    // Upload Button - only enabled when name AND frequency are set
                    VStack(spacing: Spacing.sm) {
                        if !trimmedName.isEmpty {
                            if trimmedName.count > maxNameLength {
                                Text("NAME TOO LONG (\(trimmedName.count)/\(maxNameLength))")
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(Color.agentRed)
                            } else if selectedDays.isEmpty {
                                Text("SELECT A FREQUENCY TO CONTINUE")
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(Color.agentRed)
                            }
                        }

                        PrimaryButton(title: isSaving ? "UPLOADING..." : "UPLOAD TO CORE") {
                            isSaving = true
                            if createHabit() {
                                dismiss()
                            } else {
                                isSaving = false
                                showSaveError = true
                            }
                        }
                        .opacity(canUpload ? 1.0 : 0.4)
                        .disabled(!canUpload)
                    }
                    .padding(.horizontal, Spacing.xl)
                    .padding(.bottom, Spacing.xl)
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

    private func selectSuggestion(_ suggestion: HabitSuggestion) {
        habitName = suggestion.name
        selectedIcon = suggestion.icon
        selectedDays = suggestion.scheduledDays
    }

    private func createHabit() -> Bool {
        let name = trimmedName
        let days = Array(selectedDays).sorted()
        if isAgent {
            let agent = Agent(name: name, icon: selectedIcon, scheduledDays: days)
            modelContext.insert(agent)
        } else {
            let power = Power(name: name, icon: selectedIcon, scheduledDays: days)
            modelContext.insert(power)
        }
        do {
            try modelContext.save()
            return true
        } catch {
            ErrorLogger.logSaveFailure(error, context: "AddHabitSheet.createHabit")
            return false
        }
    }
}

// MARK: - Suggestion Chip

struct SuggestionChip: View {
    let suggestion: HabitSuggestion
    let accentColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: suggestion.icon)
                    .font(.system(size: 14))
                VStack(alignment: .leading, spacing: 2) {
                    Text(suggestion.name)
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    Text(suggestion.frequencyLabel)
                        .font(.system(size: 9, design: .monospaced))
                        .opacity(0.7)
                }
            }
            .foregroundColor(accentColor)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(accentColor.opacity(0.15))
            .cornerRadius(Theme.cornerRadiusCompact)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadiusCompact)
                    .stroke(accentColor.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - Type Toggle Button

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

// MARK: - Frequency Preset Button

struct FrequencyPresetButton: View {
    let title: String
    let isSelected: Bool
    let accentColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(isSelected ? Color.deepBlack : Color.mediumGray)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, Spacing.xs)
                .background(isSelected ? accentColor : Color.charcoal)
                .cornerRadius(6)
        }
    }
}

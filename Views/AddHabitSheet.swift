import SwiftUI
import SwiftData

struct AddHabitSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var habitName: String = ""
    @State private var isAgent: Bool = false
    @State private var selectedIcon: String = "bolt"
    @State private var showSaveError: Bool = false
    @State private var selectedDays: Set<Int> = [] // Empty by default - user must choose

    private let weekdays: [(id: Int, short: String)] = [
        (1, "S"), (2, "M"), (3, "T"), (4, "W"), (5, "T"), (6, "F"), (7, "S")
    ]

    private var canUpload: Bool {
        !habitName.trimmingCharacters(in: .whitespaces).isEmpty && !selectedDays.isEmpty
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
                                        .cornerRadius(8)
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
                        if !canUpload && !habitName.trimmingCharacters(in: .whitespaces).isEmpty {
                            Text("SELECT A FREQUENCY TO CONTINUE")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(Color.agentRed)
                        }

                        PrimaryButton(title: "UPLOAD TO CORE") {
                            if createHabit() {
                                dismiss()
                            } else {
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

    private func createHabit() -> Bool {
        let name = habitName.trimmingCharacters(in: .whitespaces)
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

import SwiftUI
import SwiftData

struct EditHabitSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let power: Power?
    let agent: Agent?

    @State private var habitName: String = ""
    @State private var selectedIcon: String = "bolt"
    @State private var selectedDays: Set<Int> = []
    @State private var showSaveError: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    @State private var isSaving: Bool = false

    private let maxNameLength = 30
    private let weekdays: [(id: Int, short: String)] = [
        (1, "S"), (2, "M"), (3, "T"), (4, "W"), (5, "T"), (6, "F"), (7, "S")
    ]

    private var isAgent: Bool {
        agent != nil
    }

    private var trimmedName: String {
        habitName.trimmingCharacters(in: .whitespaces)
    }

    private var canSave: Bool {
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

                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // Name Input
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("PROGRAM NAME")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(Color.lightGray)

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
                        }
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
                                    if selectedDays.count == 7 || selectedDays == Set([2, 3, 4, 5, 6]) {
                                        selectedDays = []
                                    }
                                }
                            }

                            // Day picker
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

                        // Stats (read-only)
                        if let power = power {
                            statsSection(
                                currentStreak: power.currentStreak,
                                longestStreak: power.longestStreak,
                                totalCheckIns: power.checkIns.filter { $0.isSuccess }.count
                            )
                        } else if let agent = agent {
                            statsSection(
                                currentStreak: agent.currentStreak,
                                longestStreak: agent.longestStreak,
                                totalCheckIns: agent.checkIns.filter { $0.isSuccess }.count
                            )
                        }

                        Spacer(minLength: Spacing.xl)

                        // Save Button
                        VStack(spacing: Spacing.md) {
                            if !trimmedName.isEmpty && trimmedName.count > maxNameLength {
                                Text("NAME TOO LONG (\(trimmedName.count)/\(maxNameLength))")
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(Color.agentRed)
                            }

                            PrimaryButton(title: isSaving ? "SAVING..." : "SAVE CHANGES") {
                                isSaving = true
                                if saveChanges() {
                                    dismiss()
                                } else {
                                    isSaving = false
                                    showSaveError = true
                                }
                            }
                            .opacity(canSave ? 1.0 : 0.4)
                            .disabled(!canSave)

                            // Delete Button
                            Button(action: { showDeleteConfirmation = true }) {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("DELETE PROGRAM")
                                }
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(Color.agentRed)
                            }
                            .disabled(isSaving)
                            .padding(.top, Spacing.sm)
                        }
                        .padding(.horizontal, Spacing.xl)
                        .padding(.bottom, Spacing.xl)
                    }
                    .padding(.top, Spacing.lg)
                }
            }
            .navigationTitle(isAgent ? "EDIT AGENT" : "EDIT HACK")
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
                Text("Failed to save changes. Please try again.")
            }
            .alert("DELETE PROGRAM?", isPresented: $showDeleteConfirmation) {
                Button("DELETE", role: .destructive) {
                    deleteHabit()
                    dismiss()
                }
                Button("CANCEL", role: .cancel) { }
            } message: {
                Text("This will permanently delete this program and all its check-in history. This cannot be undone.")
            }
            .onAppear {
                loadExistingData()
            }
        }
    }

    // MARK: - Stats Section

    private func statsSection(currentStreak: Int, longestStreak: Int, totalCheckIns: Int) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("// STATS")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(Color.lightGray)

            HStack(spacing: Spacing.md) {
                EditStatBox(value: "\(currentStreak)", label: "CURRENT")
                EditStatBox(value: "\(longestStreak)", label: "BEST")
                EditStatBox(value: "\(totalCheckIns)", label: "TOTAL")
            }
        }
        .padding(.horizontal, Spacing.md)
    }

    // MARK: - Data Operations

    private func loadExistingData() {
        if let power = power {
            habitName = power.name
            selectedIcon = power.icon
            selectedDays = Set(power.scheduledDays)
        } else if let agent = agent {
            habitName = agent.name
            selectedIcon = agent.icon
            selectedDays = Set(agent.scheduledDays)
        }
    }

    private func saveChanges() -> Bool {
        let name = trimmedName
        let days = Array(selectedDays).sorted()

        if let power = power {
            power.name = name
            power.icon = selectedIcon
            power.scheduledDays = days
            power.touch()
        } else if let agent = agent {
            agent.name = name
            agent.icon = selectedIcon
            agent.scheduledDays = days
            agent.touch()
        }

        do {
            try modelContext.save()
            return true
        } catch {
            ErrorLogger.logSaveFailure(error, context: "EditHabitSheet.saveChanges")
            return false
        }
    }

    private func deleteHabit() {
        if let power = power {
            modelContext.delete(power)
        } else if let agent = agent {
            modelContext.delete(agent)
        }

        do {
            try modelContext.save()
        } catch {
            ErrorLogger.logSaveFailure(error, context: "EditHabitSheet.deleteHabit")
        }
    }
}

// MARK: - Stat Box

private struct EditStatBox: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: Spacing.xs) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(Color.matrixGreen)
            Text(label)
                .font(.system(size: 9, design: .monospaced))
                .foregroundColor(Color.mediumGray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.sm)
        .background(Color.charcoal)
        .cornerRadius(Theme.cornerRadiusCompact)
    }
}

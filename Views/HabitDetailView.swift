import SwiftUI
import SwiftData

struct HabitDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let power: Power?
    let agent: Agent?

    @State private var showDeleteAlert: Bool = false
    @State private var showEditSheet: Bool = false
    @State private var showDialIn: Bool = false
    @State private var showSaveError: Bool = false
    @StateObject private var achievementManager = AchievementManager()

    private var isPower: Bool { power != nil }
    private var name: String { power?.name ?? agent?.name ?? "Unknown" }
    private var icon: String { power?.icon ?? agent?.icon ?? "questionmark" }
    private var currentStreak: Int { power?.currentStreak ?? agent?.currentStreak ?? 0 }
    private var longestStreak: Int { power?.longestStreak ?? agent?.longestStreak ?? 0 }
    private var targetDays: Int { power?.targetDays ?? agent?.targetDays ?? Theme.habitFormationDays }
    private var createdAt: Date { power?.createdAt ?? agent?.createdAt ?? Date() }
    private var totalCheckIns: Int { power?.checkIns.count ?? agent?.checkIns.count ?? 0 }
    private var isCompletedToday: Bool {
        power?.completedToday ?? agent?.resistedToday ?? false
    }

    private var accentColor: Color {
        isPower ? Color.matrixGreen : Color.agentRed
    }

    private var progressPercent: Double {
        Double(currentStreak) / Double(targetDays)
    }

    var body: some View {
        ZStack {
            Color.matrixBlack.ignoresSafeArea()

            // Subtle code rain
            CodeRainBackground(opacity: 0.1, speed: 0.5)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                headerView

                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        // Main Stats Card
                        statsCard

                        // Progress Section
                        progressSection

                        // Actions
                        actionsSection

                        // Danger Zone
                        dangerZone

                        Spacer(minLength: 50)
                    }
                    .padding(.top, Spacing.lg)
                }
            }
        }
        .alert("PURGE PROGRAM?", isPresented: $showDeleteAlert) {
            Button("CANCEL", role: .cancel) { }
            Button("PURGE", role: .destructive) {
                deleteHabit()
            }
        } message: {
            Text("This will permanently remove \(name) and all associated data. This cannot be undone.")
        }
        .alert("DELETE FAILED", isPresented: $showSaveError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Failed to delete habit. Please try again.")
        }
        .sheet(isPresented: $showEditSheet) {
            EditHabitSheet(power: power, agent: agent)
        }
        .fullScreenCover(isPresented: $showDialIn) {
            if let p = power {
                DialInView(power: p)
            } else if let a = agent {
                DialInView(agent: a)
            }
        }
        .onAppear {
            achievementManager.setContext(modelContext)
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                    Text("BACK")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                }
                .foregroundColor(accentColor)
            }

            Spacer()

            Button(action: { showEditSheet = true }) {
                Text("EDIT")
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(accentColor)
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.md)
    }

    // MARK: - Stats Card

    private var statsCard: some View {
        VStack(spacing: Spacing.lg) {
            // Icon and Name
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.2))
                    .frame(width: 80, height: 80)

                Image(systemName: icon)
                    .font(.system(size: 36))
                    .foregroundColor(accentColor)
            }

            Text(name.uppercased())
                .font(.system(size: 22, weight: .bold, design: .monospaced))
                .foregroundColor(.white)

            Text(isPower ? "// HACK LOADED" : "// AGENT DETECTED")
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(Color.mediumGray)

            // Status Badge
            if isCompletedToday {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "checkmark.circle.fill")
                    Text(isPower ? "COMPLETED TODAY" : "RESISTED TODAY")
                }
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(accentColor)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.xs)
                .background(accentColor.opacity(0.2))
                .cornerRadius(Theme.cornerRadiusCompact)
            }
        }
        .padding(.vertical, Spacing.lg)
    }

    // MARK: - Progress Section

    private var progressSection: some View {
        VStack(spacing: Spacing.md) {
            // Progress Ring
            ZStack {
                Circle()
                    .stroke(Color.charcoal, lineWidth: 8)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: min(progressPercent, 1.0))
                    .stroke(accentColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Text("DAY")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(Color.mediumGray)
                    Text("\(currentStreak)")
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .foregroundColor(accentColor)
                    Text("OF \(targetDays)")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(Color.mediumGray)
                }
            }

            // Stats Grid
            HStack(spacing: Spacing.lg) {
                StatBox(title: "LONGEST", value: "\(longestStreak)", accent: accentColor)
                StatBox(title: "TOTAL LOGS", value: "\(totalCheckIns)", accent: accentColor)
                StatBox(title: "CREATED", value: formatDate(createdAt), accent: accentColor)
            }
            .padding(.horizontal, Spacing.md)
        }
        .padding(Spacing.lg)
        .background(Color.charcoal.opacity(0.5))
        .cornerRadius(Theme.cornerRadius)
        .padding(.horizontal, Spacing.md)
    }

    // MARK: - Actions Section

    private var actionsSection: some View {
        VStack(spacing: Spacing.md) {
            // Dial In Button
            Button(action: { showDialIn = true }) {
                HStack {
                    Image(systemName: "power")
                        .font(.system(size: 18))
                    Text(isPower ? "DIAL IN" : "RESIST AGENT")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                }
                .foregroundColor(Color.deepBlack)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(accentColor)
                .cornerRadius(Theme.cornerRadius)
            }
            .disabled(isCompletedToday)
            .opacity(isCompletedToday ? 0.5 : 1.0)
        }
        .padding(.horizontal, Spacing.md)
    }

    // MARK: - Danger Zone

    private var dangerZone: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("// DANGER ZONE")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(Color.danger)
                .padding(.horizontal, Spacing.md)

            Button(action: { showDeleteAlert = true }) {
                HStack {
                    Image(systemName: "trash")
                        .font(.system(size: 16))
                    Text(isPower ? "UNLOAD PROGRAM" : "PURGE AGENT")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                    Spacer()
                }
                .foregroundColor(Color.danger)
                .padding(Spacing.md)
                .background(Color.charcoal)
                .cornerRadius(Theme.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .stroke(Color.danger.opacity(0.5), lineWidth: 1)
                )
            }
            .padding(.horizontal, Spacing.md)
        }
        .padding(.top, Spacing.lg)
    }

    // MARK: - Helpers

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }

    private func deleteHabit() {
        if let p = power {
            modelContext.delete(p)
        } else if let a = agent {
            modelContext.delete(a)
        }

        do {
            try modelContext.save()
            // Trigger achievement
            achievementManager.checkDeleteHabitAchievement()
            dismiss()
        } catch {
            showSaveError = true
        }
    }
}

// MARK: - Stat Box

struct StatBox: View {
    let title: String
    let value: String
    let accent: Color

    var body: some View {
        VStack(spacing: Spacing.xs) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            Text(title)
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundColor(Color.mediumGray)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Edit Habit Sheet

struct EditHabitSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let power: Power?
    let agent: Agent?

    @State private var habitName: String = ""
    @State private var selectedIcon: String = ""
    @State private var showSaveError: Bool = false

    private var isPower: Bool { power != nil }
    private var accentColor: Color { isPower ? Color.matrixGreen : Color.agentRed }

    private let powerIcons = ["bolt", "figure.run", "book", "brain.head.profile", "drop.fill", "pencil.and.scribble", "dumbbell", "leaf", "sun.max", "heart"]
    private let agentIcons = ["xmark.shield", "iphone", "moon.zzz", "cup.and.saucer", "tv", "creditcard", "flame", "wineglass", "cigarette", "gamecontroller"]

    var body: some View {
        NavigationView {
            ZStack {
                Color.matrixBlack.ignoresSafeArea()

                VStack(spacing: Spacing.lg) {
                    // Name Input
                    TextField("", text: $habitName, prompt: Text("PROGRAM NAME").foregroundColor(Color.mediumGray))
                        .font(.system(size: 18, design: .monospaced))
                        .foregroundColor(accentColor)
                        .padding()
                        .background(Color.charcoal)
                        .cornerRadius(Theme.cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                                .stroke(accentColor, lineWidth: 1)
                        )
                        .padding(.horizontal, Spacing.md)

                    // Icon Selection
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("SELECT ICON")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.lightGray)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: Spacing.md) {
                            ForEach(isPower ? powerIcons : agentIcons, id: \.self) { icon in
                                Button(action: { selectedIcon = icon }) {
                                    Image(systemName: icon)
                                        .font(.system(size: 24))
                                        .foregroundColor(selectedIcon == icon ? accentColor : Color.mediumGray)
                                        .frame(width: 50, height: 50)
                                        .background(selectedIcon == icon ? Color.charcoal : Color.clear)
                                        .cornerRadius(Theme.cornerRadiusCompact)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: Theme.cornerRadiusCompact)
                                                .stroke(selectedIcon == icon ? accentColor : Color.clear, lineWidth: 1)
                                        )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.md)

                    Spacer()

                    // Save Button
                    if !habitName.trimmingCharacters(in: .whitespaces).isEmpty {
                        Button(action: saveChanges) {
                            Text("SAVE CHANGES")
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .foregroundColor(Color.deepBlack)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(accentColor)
                                .cornerRadius(Theme.cornerRadius)
                        }
                        .padding(.horizontal, Spacing.xl)
                        .padding(.bottom, Spacing.xl)
                    }
                }
                .padding(.top, Spacing.lg)
            }
            .navigationTitle("MODIFY PROGRAM")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("CANCEL") { dismiss() }
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(accentColor)
                }
            }
        }
        .onAppear {
            habitName = power?.name ?? agent?.name ?? ""
            selectedIcon = power?.icon ?? agent?.icon ?? ""
        }
        .alert("SAVE FAILED", isPresented: $showSaveError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Failed to save changes. Please try again.")
        }
    }

    private func saveChanges() {
        let name = habitName.trimmingCharacters(in: .whitespaces)

        if let p = power {
            p.name = name
            p.icon = selectedIcon
        } else if let a = agent {
            a.name = name
            a.icon = selectedIcon
        }

        do {
            try modelContext.save()
            dismiss()
        } catch {
            showSaveError = true
        }
    }
}

#Preview {
    HabitDetailView(power: nil, agent: nil)
        .modelContainer(for: [Power.self, Agent.self, CheckIn.self], inMemory: true)
}

